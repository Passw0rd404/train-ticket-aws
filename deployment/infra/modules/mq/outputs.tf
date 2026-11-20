output "broker_id" {
  value = aws_mq_broker.this.id
}

output "endpoint" {
  description = "AMQPS endpoint, amqps://<host>:5671"
  value       = aws_mq_broker.this.instances[0].endpoints[0]
}

output "console_url" {
  value = aws_mq_broker.this.instances[0].console_url
}

output "secret_arn" {
  description = "Secrets Manager secret with username, password, host and port"
  value       = aws_secretsmanager_secret.admin.arn
}

output "security_group_id" {
  value = aws_security_group.this.id
}
