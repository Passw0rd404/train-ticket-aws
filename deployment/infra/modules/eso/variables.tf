variable "name_prefix" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "namespace" {
  type    = string
  default = "external-secrets"
}

variable "service_account" {
  type    = string
  default = "external-secrets"
}

variable "roles" {
  description = "Map of scoped IAM role name -> list of Secrets Manager ARNs it may read"
  type = map(object({
    secret_arns = list(string)
  }))
}
