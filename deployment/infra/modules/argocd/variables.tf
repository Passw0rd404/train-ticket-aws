variable "cluster_name" {
  type = string
}

variable "namespace" {
  type    = string
  default = "argocd"
}

variable "admin_username" {
  description = "IAM Identity Center username that becomes Argo CD admin"
  type        = string
}
