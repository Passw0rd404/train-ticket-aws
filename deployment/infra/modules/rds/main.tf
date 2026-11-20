resource "aws_security_group" "this" {
  name        = "${var.name}-mysql"
  description = "MySQL access for ${var.name}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-mysql"
  }
}

resource "aws_vpc_security_group_ingress_rule" "from_clients" {
  count = length(var.allowed_security_group_ids)

  security_group_id            = aws_security_group.this.id
  referenced_security_group_id = var.allowed_security_group_ids[count.index]
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  description                  = "MySQL from allowed security group"
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 7.2"

  identifier = "${var.name}-mysql"

  engine               = "mysql"
  engine_version       = var.engine_version
  family               = "mysql${var.engine_version}"
  major_engine_version = var.engine_version
  instance_class       = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  # RDS generates the master password and keeps it in Secrets Manager,
  # so it never appears in Terraform state or in the repo.
  username                    = "admin"
  manage_master_user_password = true
  port                        = 3306

  multi_az               = var.multi_az
  create_db_subnet_group = true
  subnet_ids             = var.subnet_ids
  vpc_security_group_ids = [aws_security_group.this.id]
  publicly_accessible    = false

  create_db_option_group    = false
  create_db_parameter_group = true
  parameters = [
    {
      name  = "character_set_server"
      value = "utf8mb4"
    },
    {
      name  = "collation_server"
      value = "utf8mb4_unicode_ci"
    },
  ]

  backup_retention_period = var.backup_retention_days
  backup_window           = "01:00-02:00"
  maintenance_window      = "Sun:02:30-Sun:03:30"

  deletion_protection              = var.deletion_protection
  skip_final_snapshot              = var.skip_final_snapshot
  final_snapshot_identifier_prefix = "${var.name}-final"

  apply_immediately          = var.apply_immediately
  auto_minor_version_upgrade = true

  performance_insights_enabled           = true
  enabled_cloudwatch_logs_exports        = ["error", "slowquery"]
  create_cloudwatch_log_group            = true
  cloudwatch_log_group_retention_in_days = 30
}
