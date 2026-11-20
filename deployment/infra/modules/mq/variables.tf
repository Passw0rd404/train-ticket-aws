variable "name" {
  description = "Name prefix; the broker is called <name>-rabbitmq"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "Private subnets; the first one is used"
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security groups that may connect over AMQPS (the EKS node security group)"
  type        = list(string)
}

variable "engine_version" {
  description = "RabbitMQ version supported by Amazon MQ"
  type        = string
  default     = "3.13"
}

variable "instance_type" {
  type    = string
  default = "mq.t3.micro"
}

variable "deployment_mode" {
  description = "SINGLE_INSTANCE or CLUSTER_MULTI_AZ (cluster needs mq.m5.large or bigger)"
  type        = string
  default     = "SINGLE_INSTANCE"

  validation {
    condition     = contains(["SINGLE_INSTANCE", "CLUSTER_MULTI_AZ"], var.deployment_mode)
    error_message = "deployment_mode must be SINGLE_INSTANCE or CLUSTER_MULTI_AZ."
  }
}

variable "admin_username" {
  type    = string
  default = "mqadmin"
}

variable "apply_immediately" {
  type    = bool
  default = false
}

variable "secret_recovery_days" {
  description = "Days a deleted credentials secret stays recoverable (0 deletes immediately)"
  type        = number
  default     = 7
}
