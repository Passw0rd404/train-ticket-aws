variable "name" {
  description = "Name prefix for the VPC and everything in it"
  type        = string
}

variable "cidr" {
  description = "VPC CIDR block (a /16 is expected)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to spread subnets over"
  type        = number
  default     = 3

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 3
    error_message = "az_count must be 2 or 3."
  }
}
