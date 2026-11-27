output "address" {
  description = "Hostname for the JDBC and PyMySQL connections"
  value       = module.db.db_instance_address
}

output "port" {
  value = module.db.db_instance_port
}

output "master_username" {
  value = "admin"
}

output "master_password" {
  value     = random_password.master.result
  sensitive = true
}

output "security_group_id" {
  value = aws_security_group.this.id
}

output "identifier" {
  value = module.db.db_instance_identifier
}
