variable "name" {
  description = "IAM role name"
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

variable "service_account" {
  type    = string
  default = "external-secrets"
}

variable "secret_arns" {
  description = "Exact Secrets Manager ARNs ESO may read"
  type        = list(string)
}
