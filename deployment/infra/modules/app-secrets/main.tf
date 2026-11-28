resource "random_password" "mysql_app" {
  length  = 32
  special = false
}

resource "random_password" "mysql_readonly" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "mysql" {
  name                    = "${var.prefix}/mysql"
  description             = "MySQL connection for the application services"
  recovery_window_in_days = var.recovery_window_in_days
}

resource "aws_secretsmanager_secret_version" "mysql" {
  secret_id = aws_secretsmanager_secret.mysql.id
  secret_string = jsonencode({
    host     = var.mysql_host
    port     = tostring(var.mysql_port)
    database = var.mysql_database
    user     = var.mysql_user
    password = random_password.mysql_app.result
  })
}

resource "aws_secretsmanager_secret" "mysql_readonly" {
  name                    = "${var.prefix}/mysql-readonly"
  description             = "Read-only MySQL connection for monitoring exporters"
  recovery_window_in_days = var.recovery_window_in_days
}

resource "aws_secretsmanager_secret_version" "mysql_readonly" {
  secret_id = aws_secretsmanager_secret.mysql_readonly.id
  secret_string = jsonencode({
    host     = var.mysql_host
    port     = tostring(var.mysql_port)
    database = var.mysql_database
    user     = var.mysql_readonly_user
    password = random_password.mysql_readonly.result
  })
}

resource "aws_secretsmanager_secret" "mysql_bootstrap" {
  name                    = "${var.prefix}/mysql-bootstrap"
  description             = "RDS admin + app + readonly credentials used once by the in-cluster db-init Job"
  recovery_window_in_days = var.recovery_window_in_days
}

resource "aws_secretsmanager_secret_version" "mysql_bootstrap" {
  secret_id = aws_secretsmanager_secret.mysql_bootstrap.id
  secret_string = jsonencode({
    host              = var.mysql_host
    port              = tostring(var.mysql_port)
    database          = var.mysql_database
    admin_user        = var.mysql_admin_user
    admin_password    = var.mysql_admin_password
    app_user          = var.mysql_user
    app_password      = random_password.mysql_app.result
    readonly_user     = var.mysql_readonly_user
    readonly_password = random_password.mysql_readonly.result
  })
}

resource "aws_secretsmanager_secret" "rabbitmq" {
  name                    = "${var.prefix}/rabbitmq"
  description             = "RabbitMQ connection for the application services and exporter"
  recovery_window_in_days = var.recovery_window_in_days
}

resource "aws_secretsmanager_secret_version" "rabbitmq" {
  secret_id = aws_secretsmanager_secret.rabbitmq.id
  secret_string = jsonencode({
    host     = var.rabbitmq_host
    user     = var.rabbitmq_user
    password = var.rabbitmq_password
  })
}

resource "aws_secretsmanager_secret" "notification" {
  name                    = "${var.prefix}/notification-email"
  description             = "SMTP login for ts-notification-service"
  recovery_window_in_days = var.recovery_window_in_days
}

resource "aws_secretsmanager_secret_version" "notification" {
  secret_id = aws_secretsmanager_secret.notification.id
  secret_string = jsonencode({
    address  = "CHANGE_ME"
    password = "CHANGE_ME"
  })
  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "aws_secretsmanager_secret" "cloudflare" {
  name                    = "${var.prefix}/cloudflare"
  description             = "Cloudflare Tunnel token for cloudflared"
  recovery_window_in_days = var.recovery_window_in_days
}

resource "aws_secretsmanager_secret_version" "cloudflare" {
  secret_id = aws_secretsmanager_secret.cloudflare.id
  secret_string = jsonencode({
    tunnelToken = var.cloudflare_tunnel_token
  })
}

resource "aws_secretsmanager_secret" "grafana" {
  name                    = "${var.prefix}/grafana"
  description             = "Grafana Cloud remote_write, Loki, and OTLP credentials for Alloy"
  recovery_window_in_days = var.recovery_window_in_days
}

resource "aws_secretsmanager_secret_version" "grafana" {
  secret_id = aws_secretsmanager_secret.grafana.id
  secret_string = jsonencode({
    prometheus_url      = var.grafana_prometheus_url
    prometheus_username = var.grafana_prometheus_username
    loki_url            = var.grafana_loki_url
    loki_username       = var.grafana_loki_username
    otlp_endpoint       = var.grafana_otlp_endpoint
    otlp_username       = var.grafana_otlp_username
    api_token           = var.grafana_alloy_token
  })
}

resource "aws_secretsmanager_secret" "grafana_prom_read" {
  name                    = "${var.prefix}/grafana-prom-read"
  description             = "Read-only Grafana Cloud Prometheus query credentials for Argo Rollouts AnalysisTemplate"
  recovery_window_in_days = var.recovery_window_in_days
}

resource "aws_secretsmanager_secret_version" "grafana_prom_read" {
  secret_id = aws_secretsmanager_secret.grafana_prom_read.id
  secret_string = jsonencode({
    prom_url   = var.grafana_prom_query_url
    basic_auth = base64encode("${var.grafana_prometheus_username}:${var.grafana_prom_read_token}")
  })
}
