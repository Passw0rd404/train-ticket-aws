variable "prefix" {
  description = "Secret names are <prefix>/mysql, <prefix>/mysql-bootstrap, <prefix>/rabbitmq, <prefix>/notification-email and <prefix>/cloudflare"
  type        = string
  default     = "production"
}

variable "recovery_window_in_days" {
  type    = number
  default = 0
}

variable "mysql_host" {
  description = "RDS endpoint hostname only, no port"
  type        = string
}

variable "mysql_port" {
  type    = number
  default = 3306
}

variable "mysql_database" {
  type = string
}

variable "mysql_admin_user" {
  type = string
}

variable "mysql_admin_password" {
  type      = string
  sensitive = true
}

variable "mysql_user" {
  description = "Dedicated application user (created by the k8s db-init Job)"
  type        = string
}

variable "rabbitmq_host" {
  description = "Broker hostname only, no amqps:// and no port"
  type        = string
}

variable "rabbitmq_user" {
  type = string
}

variable "rabbitmq_password" {
  type      = string
  sensitive = true
}

variable "cloudflare_tunnel_token" {
  type      = string
  sensitive = true
}
