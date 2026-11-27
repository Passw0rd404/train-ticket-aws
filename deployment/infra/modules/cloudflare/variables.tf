variable "name" {
  type = string
}

variable "account_id" {
  type = string
}

variable "zone_name" {
  type = string
}

variable "api_hostname" {
  type = string
}

variable "pages_project_name" {
  type = string
}

variable "pages_domain" {
  type = string
}

variable "traefik_service_url" {
  type    = string
  default = "http://traefik.traefik.svc.cluster.local:80"
}
