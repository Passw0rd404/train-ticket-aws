variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "project" {
  type    = string
  default = "train-ticket"
}

variable "env" {
  type = string
}

variable "apply_immediately" {
  description = "Apply RDS and MQ changes now instead of in the maintenance window"
  type        = bool
  default     = false
}

# Network
variable "vpc_cidr" {
  type = string
}

variable "az_count" {
  type    = number
  default = 3
}

# EKS
variable "kubernetes_version" {
  type = string
}

variable "node_instance_types" {
  type = list(string)
}

variable "node_count" {
  type    = number
  default = 3
}

variable "node_disk_size" {
  type    = number
  default = 50
}

variable "endpoint_public_access" {
  type = bool
}

variable "endpoint_public_access_cidrs" {
  type    = list(string)
  default = []
}

variable "admin_principal_arns" {
  type    = list(string)
  default = []
}

# RDS
variable "db_engine_version" {
  type    = string
  default = "8.4"
}

variable "db_instance_class" {
  type = string
}

variable "db_allocated_storage" {
  type    = number
  default = 50
}

variable "db_max_allocated_storage" {
  type    = number
  default = 200
}

variable "db_multi_az" {
  type = bool
}

variable "db_backup_retention_days" {
  type = number
}

variable "db_deletion_protection" {
  type = bool
}

variable "db_skip_final_snapshot" {
  type = bool
}

# Amazon MQ
variable "mq_instance_type" {
  type = string
}

variable "mq_deployment_mode" {
  type = string
}

variable "mq_secret_recovery_days" {
  type = number
}

# Argo CD (managed by EKS, signs in through IAM Identity Center)
variable "enable_argocd" {
  type    = bool
  default = true
}

variable "argocd_admin_username" {
  description = "IAM Identity Center username that becomes Argo CD admin"
  type        = string
}

variable "db_name" {
  description = "MySQL schema all services use"
  type        = string
  default     = "ts"
}

variable "db_app_user" {
  description = "Dedicated MySQL user for the services (not the RDS master user)"
  type        = string
  default     = "tsapp"
}
