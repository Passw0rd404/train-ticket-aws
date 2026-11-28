variable "name" { type = string }
variable "env" { type = string }
variable "stack_slug" { type = string }
variable "frontend_origin" { type = string }
variable "alert_email" { type = string }
variable "prometheus_datasource_uid" {
  type    = string
  default = "grafanacloud-prom"
}
