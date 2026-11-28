data "grafana_cloud_stack" "this" {
  provider = grafana.cloud
  slug     = var.stack_slug
}

# Scoped write-only access policy for in-cluster Grafana Alloy
resource "grafana_cloud_access_policy" "alloy" {
  provider     = grafana.cloud
  region       = data.grafana_cloud_stack.this.region_slug
  name         = "${var.name}-alloy"
  display_name = "${var.name}-alloy"

  scopes = [
    "metrics:write",
    "logs:write",
    "traces:write",
  ]

  realm {
    type       = "stack"
    identifier = data.grafana_cloud_stack.this.id
  }
}

resource "grafana_cloud_access_policy_token" "alloy" {
  provider         = grafana.cloud
  region           = data.grafana_cloud_stack.this.region_slug
  access_policy_id = grafana_cloud_access_policy.alloy.policy_id
  name             = "${var.name}-alloy-token"
}

# Read-only metrics access policy for Argo Rollouts ClusterAnalysisTemplate
resource "grafana_cloud_access_policy" "prom_read" {
  provider     = grafana.cloud
  region       = data.grafana_cloud_stack.this.region_slug
  name         = "${var.name}-prom-read"
  display_name = "${var.name}-prom-read"

  scopes = ["metrics:read"]

  realm {
    type       = "stack"
    identifier = data.grafana_cloud_stack.this.id
  }
}

resource "grafana_cloud_access_policy_token" "prom_read" {
  provider         = grafana.cloud
  region           = data.grafana_cloud_stack.this.region_slug
  access_policy_id = grafana_cloud_access_policy.prom_read.policy_id
  name             = "${var.name}-prom-read-token"
}

# Frontend Observability (Faro) app for Cloudflare Pages
resource "grafana_frontend_o11y_app" "frontend" {
  provider        = grafana.cloud
  stack_id        = data.grafana_cloud_stack.this.id
  name            = "${var.name}-frontend"
  allowed_origins = [var.frontend_origin]

  extra_log_attributes = {
    env     = var.env
    service = "ts-ui-dashboard"
  }

  settings = {
    combineLabData = "1"
  }
}

# Stack service account used to provision folders, dashboards and alert rules
resource "grafana_cloud_stack_service_account" "tf" {
  provider   = grafana.cloud
  stack_slug = data.grafana_cloud_stack.this.slug
  name       = "${var.name}-terraform"
  role       = "Admin"
}

resource "grafana_cloud_stack_service_account_token" "tf" {
  provider           = grafana.cloud
  stack_slug         = data.grafana_cloud_stack.this.slug
  name               = "${var.name}-terraform-token"
  service_account_id = grafana_cloud_stack_service_account.tf.id
}

resource "grafana_folder" "train_ticket" {
  provider = grafana.stack
  title    = "Train Ticket (${var.env})"
}

resource "grafana_dashboard" "overview" {
  provider = grafana.stack
  folder   = grafana_folder.train_ticket.uid

  config_json = jsonencode({
    title         = "Train Ticket Overview (${var.env})"
    uid           = "train-ticket-${var.env}-overview"
    schemaVersion = 39
    refresh       = "30s"
    panels = [
      {
        id      = 1
        title   = "Traefik Request Rate (RPS)"
        type    = "timeseries"
        gridPos = { x = 0, y = 0, w = 8, h = 8 }
        targets = [{
          refId      = "A"
          datasource = { type = "prometheus", uid = var.prometheus_datasource_uid }
          expr       = "sum(rate(traefik_service_requests_total[2m])) by (service)"
        }]
      },
      {
        id      = 2
        title   = "Traefik 5xx Error Rate"
        type    = "timeseries"
        gridPos = { x = 8, y = 0, w = 8, h = 8 }
        targets = [{
          refId      = "A"
          datasource = { type = "prometheus", uid = var.prometheus_datasource_uid }
          expr       = "sum(rate(traefik_service_requests_total{code=~\"5..\"}[2m])) by (service)"
        }]
      },
      {
        id      = 3
        title   = "Cloudflared Active Tunnel Connections"
        type    = "stat"
        gridPos = { x = 16, y = 0, w = 8, h = 8 }
        targets = [{
          refId      = "A"
          datasource = { type = "prometheus", uid = var.prometheus_datasource_uid }
          expr       = "sum(cloudflared_tunnel_ha_connections)"
        }]
      },
      {
        id      = 4
        title   = "Business Totals (Users / Orders / Vouchers)"
        type    = "stat"
        gridPos = { x = 0, y = 8, w = 12, h = 8 }
        targets = [
          {
            refId        = "A"
            datasource   = { type = "prometheus", uid = var.prometheus_datasource_uid }
            expr         = "train_ticket_users_total"
            legendFormat = "Users"
          },
          {
            refId        = "B"
            datasource   = { type = "prometheus", uid = var.prometheus_datasource_uid }
            expr         = "sum(train_ticket_orders_total)"
            legendFormat = "Orders"
          },
          {
            refId        = "C"
            datasource   = { type = "prometheus", uid = var.prometheus_datasource_uid }
            expr         = "train_ticket_vouchers_total"
            legendFormat = "Vouchers"
          }
        ]
      },
      {
        id      = 5
        title   = "RabbitMQ Queue Depth (Ready + Unacked)"
        type    = "timeseries"
        gridPos = { x = 12, y = 8, w = 12, h = 8 }
        targets = [{
          refId      = "A"
          datasource = { type = "prometheus", uid = var.prometheus_datasource_uid }
          expr       = "sum(rabbitmq_queue_messages) by (queue)"
        }]
      }
    ]
  })
}

resource "grafana_rule_group" "alerts" {
  provider         = grafana.stack
  name             = "Train Ticket DoS & Availability Alerts"
  folder_uid       = grafana_folder.train_ticket.uid
  interval_seconds = 60

  rule {
    name           = "CloudflaredTunnelDisconnected"
    condition      = "C"
    for            = "1m"
    no_data_state  = "Alerting"
    exec_err_state = "Alerting"

    data {
      ref_id         = "A"
      datasource_uid = var.prometheus_datasource_uid
      relative_time_range {
        from = 300
        to   = 0
      }
      model = jsonencode({
        expr  = "sum(cloudflared_tunnel_ha_connections)"
        refId = "A"
      })
    }
    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({ type = "reduce", expression = "A", reducer = "last" })
    }
    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({
        type       = "threshold"
        expression = "B"
        conditions = [{ evaluator = { type = "lt", params = [1] } }]
      })
    }
    labels      = { severity = "critical" }
    annotations = { summary = "Total ingress outage: cloudflared has 0 active HA connections" }
  }

  rule {
    name           = "Ingress5xxErrorRateHigh"
    condition      = "C"
    for            = "2m"
    no_data_state  = "OK"
    exec_err_state = "Alerting"

    data {
      ref_id         = "A"
      datasource_uid = var.prometheus_datasource_uid
      relative_time_range {
        from = 300
        to   = 0
      }
      model = jsonencode({
        expr  = "sum(rate(traefik_service_requests_total{code=~\"5..\"}[2m])) / clamp_min(sum(rate(traefik_service_requests_total[2m])), 0.001)"
        refId = "A"
      })
    }
    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({ type = "reduce", expression = "A", reducer = "last" })
    }
    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({
        type       = "threshold"
        expression = "B"
        conditions = [{ evaluator = { type = "gt", params = [0.05] } }]
      })
    }
    labels      = { severity = "critical" }
    annotations = { summary = "Traefik Gateway returning >5% HTTP 5xx errors" }
  }

  rule {
    name           = "IngressLatencyP95High"
    condition      = "C"
    for            = "3m"
    no_data_state  = "OK"
    exec_err_state = "Alerting"

    data {
      ref_id         = "A"
      datasource_uid = var.prometheus_datasource_uid
      relative_time_range {
        from = 300
        to   = 0
      }
      model = jsonencode({
        expr  = "histogram_quantile(0.95, sum(rate(traefik_service_request_duration_seconds_bucket[5m])) by (le, service))"
        refId = "A"
      })
    }
    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({ type = "reduce", expression = "A", reducer = "last" })
    }
    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({
        type       = "threshold"
        expression = "B"
        conditions = [{ evaluator = { type = "gt", params = [2] } }]
      })
    }
    labels      = { severity = "warning" }
    annotations = { summary = "Traefik service p95 response latency exceeded 2s" }
  }

  rule {
    name           = "ServiceCrashLooping"
    condition      = "C"
    for            = "2m"
    no_data_state  = "OK"
    exec_err_state = "Alerting"

    data {
      ref_id         = "A"
      datasource_uid = var.prometheus_datasource_uid
      relative_time_range {
        from = 300
        to   = 0
      }
      model = jsonencode({
        expr  = "max(kube_pod_container_status_waiting_reason{reason=\"CrashLoopBackOff\",namespace=~\"tt-.*|traefik|cloudflared\"}) by (namespace, pod)"
        refId = "A"
      })
    }
    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({ type = "reduce", expression = "A", reducer = "last" })
    }
    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({
        type       = "threshold"
        expression = "B"
        conditions = [{ evaluator = { type = "gt", params = [0] } }]
      })
    }
    labels      = { severity = "critical" }
    annotations = { summary = "Application or ingress pod is in CrashLoopBackOff" }
  }

  rule {
    name           = "MySQLUnreachable"
    condition      = "C"
    for            = "1m"
    no_data_state  = "Alerting"
    exec_err_state = "Alerting"

    data {
      ref_id         = "A"
      datasource_uid = var.prometheus_datasource_uid
      relative_time_range {
        from = 300
        to   = 0
      }
      model = jsonencode({
        expr  = "min(mysql_up)"
        refId = "A"
      })
    }
    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({ type = "reduce", expression = "A", reducer = "last" })
    }
    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({
        type       = "threshold"
        expression = "B"
        conditions = [{ evaluator = { type = "lt", params = [1] } }]
      })
    }
    labels      = { severity = "critical" }
    annotations = { summary = "RDS MySQL is unreachable from the cluster (mysql_up == 0)" }
  }

  rule {
    name           = "RabbitMQUnreachable"
    condition      = "C"
    for            = "1m"
    no_data_state  = "Alerting"
    exec_err_state = "Alerting"

    data {
      ref_id         = "A"
      datasource_uid = var.prometheus_datasource_uid
      relative_time_range {
        from = 300
        to   = 0
      }
      model = jsonencode({
        expr  = "min(rabbitmq_up)"
        refId = "A"
      })
    }
    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({ type = "reduce", expression = "A", reducer = "last" })
    }
    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({
        type       = "threshold"
        expression = "B"
        conditions = [{ evaluator = { type = "lt", params = [1] } }]
      })
    }
    labels      = { severity = "critical" }
    annotations = { summary = "Amazon MQ RabbitMQ is unreachable (rabbitmq_up == 0)" }
  }

  rule {
    name           = "RabbitMQStalledQueue"
    condition      = "C"
    for            = "2m"
    no_data_state  = "OK"
    exec_err_state = "Alerting"

    data {
      ref_id         = "A"
      datasource_uid = var.prometheus_datasource_uid
      relative_time_range {
        from = 300
        to   = 0
      }
      model = jsonencode({
        expr  = "(sum(rabbitmq_queue_messages_ready) by (queue) > 50) and (sum(rabbitmq_queue_consumers) by (queue) == 0)"
        refId = "A"
      })
    }
    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({ type = "reduce", expression = "A", reducer = "last" })
    }
    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({
        type       = "threshold"
        expression = "B"
        conditions = [{ evaluator = { type = "gt", params = [0] } }]
      })
    }
    labels      = { severity = "critical" }
    annotations = { summary = "RabbitMQ queue has >50 ready messages with 0 active consumers" }
  }
}

resource "grafana_contact_point" "email" {
  provider = grafana.stack
  name     = "Train Ticket Alerts Email"

  email {
    addresses = [var.alert_email]
  }
}

resource "grafana_notification_policy" "default" {
  provider        = grafana.stack
  contact_point   = grafana_contact_point.email.name
  group_by        = ["alertname", "namespace"]
  group_wait      = "30s"
  group_interval  = "5m"
  repeat_interval = "4h"
}
