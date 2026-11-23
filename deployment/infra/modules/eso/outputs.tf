output "role_arns" {
  description = "Role ARN per key, for the service account annotations"
  value       = { for k, r in aws_iam_role.this : k => r.arn }
}
