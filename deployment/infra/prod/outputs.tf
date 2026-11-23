output "vpc_id" {
  value = module.vpc.vpc_id
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "kubeconfig_command" {
  description = "Run this to point kubectl at the cluster"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

output "rds_address" {
  value = module.rds.address
}

output "rds_master_user_secret_arn" {
  value = module.rds.master_user_secret_arn
}

output "mq_endpoint" {
  value = module.mq.endpoint
}

output "cluster_arn" {
  description = "Goes in the Argo CD cluster Secret as server"
  value       = module.eks.cluster_arn
}

output "argocd_url" {
  value = try(module.argocd[0].server_url, null)
}

output "eso_role_arns" {
  description = "Annotation eks.amazonaws.com/role-arn for each ESO service account"
  value       = module.eso.role_arns
}
