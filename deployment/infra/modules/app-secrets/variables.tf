variable "prefix" {
  type    = string
  default = "production"
}

variable "recovery_window_in_days" {
  type    = number
  default = 0
}

variable "mysql_host" { type = string }
variable "mysql_port" {
  type    = number
  default = 3306
}
variable "mysql_database" { type = string }
variable "mysql_admin_user" { type = string }
variable "mysql_admin_password" {
  type      = string
  sensitive = true
}
variable "mysql_user" { type = string }
variable "mysql_readonly_user" {
  type    = string
  default = "tsmonitor"
}

variable "rabbitmq_host" { type = string }
variable "rabbitmq_user" { type = string }
variable "rabbitmq_password" {
  type      = string
  sensitive = true
}

variable "cloudflare_tunnel_token" {
  type      = string
  sensitive = true
}

variable "grafana_prometheus_url" { type = string }
variable "grafana_prometheus_username" { type = string }
variable "grafana_loki_url" { type = string }
variable "grafana_loki_username" { type = string }
variable "grafana_otlp_endpoint" { type = string }
variable "grafana_otlp_username" { type = string }
variable "grafana_alloy_token" {
  type      = string
  sensitive = true
}

variable "grafana_prom_query_url" { type = string }
variable "grafana_prom_read_token" {
  type      = string
  sensitive = true
}
