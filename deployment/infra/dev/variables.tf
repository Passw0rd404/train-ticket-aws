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
  default     = true
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
  type    = bool
  default = false
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

variable "db_name" {
  description = "MySQL schema all services use"
  type        = string
  default     = "ts"
}

variable "db_app_user" {
  description = "Dedicated MySQL user for the services (created by the k8s db-init Job)"
  type        = string
  default     = "tsapp"
}

# Amazon MQ
variable "mq_engine_version" {
  type    = string
  default = "4.2"
}

variable "mq_instance_type" {
  type = string
}

variable "mq_deployment_mode" {
  type = string
}

# Secrets Manager
variable "secrets_prefix" {
  description = "Matches externalSecret.key prefix in ts-*/values.yaml and cloudflared/values.yaml"
  type        = string
  default     = "production"
}

variable "secret_recovery_window_days" {
  description = "0 allows immediate delete/recreate on terraform destroy -> apply"
  type        = number
  default     = 0
}

# Cloudflare (account_id passed via TF_VAR_cloudflare_account_id in CI)
variable "cloudflare_account_id" {
  type = string
}

variable "cloudflare_zone_name" {
  type    = string
  default = "abdullahsameh.tech"
}

variable "api_hostname" {
  type    = string
  default = "api.abdullahsameh.tech"
}

variable "pages_project_name" {
  type    = string
  default = "train-ticket-ui"
}

variable "pages_domain" {
  type    = string
  default = "dev.abdullahsameh.tech"
}

variable "traefik_service_url" {
  type    = string
  default = "http://traefik.traefik.svc.cluster.local:80"
}

# Argo CD (managed by EKS, signs in through IAM Identity Center)
variable "enable_argocd" {
  type    = bool
  default = true
}

variable "argocd_create_admin_user" {
  description = "Create an IAM Identity Center user for Argo CD admin login"
  type        = bool
  default     = true
}

variable "argocd_admin_username" {
  type    = string
  default = "argocd-admin"
}

variable "argocd_admin_display_name" {
  type    = string
  default = "Argo CD Admin"
}

variable "argocd_admin_given_name" {
  type    = string
  default = "ArgoCD"
}

variable "argocd_admin_family_name" {
  type    = string
  default = "Admin"
}

variable "argocd_admin_email" {
  type    = string
  default = "mern01555206319@gmail.com"
}
