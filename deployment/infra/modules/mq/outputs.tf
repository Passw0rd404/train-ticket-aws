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

output "host" {
  description = "Broker hostname only, no amqps:// and no port"
  value       = split(":", trimprefix(aws_mq_broker.this.instances[0].endpoints[0], "amqps://"))[0]
}

output "admin_username" {
  value = var.admin_username
}

output "admin_password" {
  value     = random_password.admin.result
  sensitive = true
}

output "security_group_id" {
  value = aws_security_group.this.id
}
