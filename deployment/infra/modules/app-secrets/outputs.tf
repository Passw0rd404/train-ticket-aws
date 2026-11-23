output "mysql_arn" {
  value = aws_secretsmanager_secret.mysql.arn
}

output "rabbitmq_arn" {
  value = aws_secretsmanager_secret.rabbitmq.arn
}

output "notification_arn" {
  value = aws_secretsmanager_secret.notification.arn
}
