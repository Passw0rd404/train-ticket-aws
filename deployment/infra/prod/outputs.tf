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

output "mq_secret_arn" {
  value = module.mq.secret_arn
}
