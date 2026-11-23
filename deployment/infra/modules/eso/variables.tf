variable "name_prefix" {
  description = "Roles are called <name_prefix>-eso-<key>"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the cluster's IAM OIDC provider (from the eks module)"
  type        = string
}

variable "oidc_provider" {
  description = "Cluster OIDC issuer without https:// (from the eks module)"
  type        = string
}

variable "namespace" {
  type    = string
  default = "external-secrets"
}

variable "roles" {
  description = "One role per secret: the service account that may assume it and the secret it may read"
  type = map(object({
    service_account = string
    secret_arn      = string
  }))
}
