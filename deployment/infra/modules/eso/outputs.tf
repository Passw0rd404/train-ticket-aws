output "controller_role_arn" {
  value = aws_iam_role.controller.arn
}

output "role_arns" {
  value = { for k, r in aws_iam_role.scoped : k => r.arn }
}
