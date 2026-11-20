output "address" {
  description = "Hostname for the JDBC and PyMySQL connections"
  value       = module.db.db_instance_address
}

output "port" {
  value = module.db.db_instance_port
}

output "master_user_secret_arn" {
  description = "Secrets Manager secret holding the generated master username and password"
  value       = module.db.db_instance_master_user_secret_arn
}

output "security_group_id" {
  value = aws_security_group.this.id
}

output "identifier" {
  value = module.db.db_instance_identifier
}
