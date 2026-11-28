output "mysql_arn" { value = aws_secretsmanager_secret.mysql.arn }
output "mysql_readonly_arn" { value = aws_secretsmanager_secret.mysql_readonly.arn }
output "mysql_bootstrap_arn" { value = aws_secretsmanager_secret.mysql_bootstrap.arn }
output "rabbitmq_arn" { value = aws_secretsmanager_secret.rabbitmq.arn }
output "notification_arn" { value = aws_secretsmanager_secret.notification.arn }
output "cloudflare_arn" { value = aws_secretsmanager_secret.cloudflare.arn }
output "grafana_arn" { value = aws_secretsmanager_secret.grafana.arn }
output "grafana_prom_read_arn" { value = aws_secretsmanager_secret.grafana_prom_read.arn }
