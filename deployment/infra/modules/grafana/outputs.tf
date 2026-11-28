output "stack_url" {
  value = data.grafana_cloud_stack.this.url
}

output "stack_sa_token" {
  value     = grafana_cloud_stack_service_account_token.tf.key
  sensitive = true
}

output "prometheus_remote_write_url" {
  value = data.grafana_cloud_stack.this.prometheus_remote_write_endpoint
}

output "prometheus_username" {
  value = tostring(data.grafana_cloud_stack.this.prometheus_user_id)
}

output "loki_push_url" {
  value = "${data.grafana_cloud_stack.this.logs_url}/loki/api/v1/push"
}

output "loki_username" {
  value = tostring(data.grafana_cloud_stack.this.logs_user_id)
}

output "otlp_endpoint" {
  value = data.grafana_cloud_stack.this.otlp_url
}

output "otlp_username" {
  value = tostring(data.grafana_cloud_stack.this.id)
}

output "alloy_token" {
  value     = grafana_cloud_access_policy_token.alloy.token
  sensitive = true
}

output "faro_collector_url" {
  value = grafana_frontend_o11y_app.frontend.collector_endpoint
}

output "prometheus_query_url" {
  value = trimsuffix(data.grafana_cloud_stack.this.prometheus_remote_write_endpoint, "/push")
}

output "prom_read_token" {
  value     = grafana_cloud_access_policy_token.prom_read.token
  sensitive = true
}
