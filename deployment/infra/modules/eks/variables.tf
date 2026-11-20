variable "name" {
  description = "Cluster name"
  type        = string
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "Private subnets for the nodes and the control plane network interfaces"
  type        = list(string)
}

variable "instance_types" {
  description = "Node instance types"
  type        = list(string)
  default     = ["r6i.large"]
}

variable "node_count" {
  description = "Number of nodes (kept fixed: min = max = desired)"
  type        = number
  default     = 3
}

variable "node_disk_size" {
  description = "Node root volume size in GiB"
  type        = number
  default     = 50
}

variable "endpoint_public_access" {
  description = "Expose the Kubernetes API publicly (still IAM-authenticated)"
  type        = bool
  default     = false
}

variable "endpoint_public_access_cidrs" {
  description = "CIDRs allowed to reach the public API endpoint"
  type        = list(string)
  default     = []
}

variable "admin_principal_arns" {
  description = "IAM role or user ARNs that get cluster admin access, besides the identity that runs Terraform"
  type        = list(string)
  default     = []
}
