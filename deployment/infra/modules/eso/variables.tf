variable "name" {
  description = "IAM role name"
  type        = string
  default     = "eso-secrets-reader"
}

variable "oidc_provider_arn" {
  description = "ARN of the EKS cluster OIDC provider"
  type        = string
}

variable "namespace" {
  description = "Namespace of the ESO service account"
  type        = string
  default     = "external-secrets"
}

variable "service_account" {
  description = "Name of the ESO service account"
  type        = string
  default     = "external-secrets"
}

variable "secret_arns" {
  description = "Exact Secrets Manager ARNs ESO may read"
  type        = list(string)
}
