variable "prefix" {
  description = "Secret names are <prefix>/mysql, <prefix>/rabbitmq and <prefix>/notification-email"
  type        = string
  default     = "production"
}

variable "recovery_window_in_days" {
  type    = number
  default = 7
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

variable "mysql_user" {
  description = "Dedicated application user (you create it in MySQL, see the steps)"
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
