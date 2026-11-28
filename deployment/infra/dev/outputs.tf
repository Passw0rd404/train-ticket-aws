output "vpc_id" {
  value = module.vpc.vpc_id
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "rds_address" {
  value = module.rds.address
}

output "mq_endpoint" {
  value = module.mq.endpoint
}

output "argocd_url" {
  value = try(module.argocd[0].server_url, null)
}

output "eso_controller_role_arn" {
  value = module.eso.controller_role_arn
}

output "eso_scoped_role_arns" {
  value = module.eso.role_arns
}

output "cloudflare_tunnel_id" {
  value = module.cloudflare.tunnel_id
}

output "cloudflare_pages_url" {
  value = "https://${var.pages_domain}"
}

output "cloudflare_api_url" {
  value = "https://${var.api_hostname}"
}

output "faro_collector_url" {
  description = "Put this value in GitHub repository variable FARO_COLLECTOR_URL for Cloudflare Pages"
  value       = module.grafana.faro_collector_url
}

output "cloudwatch_alarms" {
  value = module.cloudwatch.alarm_names
}
