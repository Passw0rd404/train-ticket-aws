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
  description = "Major.minor only (4.3 is the latest; RabbitMQ 4 runs only on mq.m7g)"
  type        = string
  default     = "4.2"
}

variable "instance_type" {
  type    = string
  default = "mq.m7g.large"
}

variable "deployment_mode" {
  description = "SINGLE_INSTANCE or CLUSTER_MULTI_AZ"
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
