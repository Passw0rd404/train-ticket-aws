variable "cluster_name" {
  type = string
}

variable "namespace" {
  type    = string
  default = "argocd"
}

variable "create_admin_user" {
  type    = bool
  default = true
}

variable "admin_username" {
  description = "IAM Identity Center username that becomes Argo CD admin"
  type        = string
}

variable "admin_display_name" {
  type    = string
  default = "Argo CD Admin"
}

variable "admin_given_name" {
  type    = string
  default = "ArgoCD"
}

variable "admin_family_name" {
  type    = string
  default = "Admin"
}

variable "admin_email" {
  type    = string
  default = "mern01555206319@gmail.com"
}
