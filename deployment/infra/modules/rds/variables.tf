variable "name" {
  description = "Name prefix; the instance is called <name>-mysql"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "Database subnets (at least two availability zones)"
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security groups that may connect on 3306 (the EKS node security group)"
  type        = list(string)
}

variable "engine_version" {
  description = "MySQL major version, e.g. 8.4 (also used to pick the parameter group family)"
  type        = string
  default     = "8.4"
}

variable "instance_class" {
  type    = string
  default = "db.t4g.large"
}

variable "allocated_storage" {
  description = "Initial storage in GiB"
  type        = number
  default     = 50
}

variable "max_allocated_storage" {
  description = "Storage autoscaling ceiling in GiB"
  type        = number
  default     = 200
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "backup_retention_days" {
  type    = number
  default = 7
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "apply_immediately" {
  description = "Apply changes now instead of in the maintenance window"
  type        = bool
  default     = false
}
