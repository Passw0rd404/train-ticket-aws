output "server_url" {
  value = module.capability.argocd_server_url
}

output "role_arn" {
  value = module.capability.iam_role_arn
}
