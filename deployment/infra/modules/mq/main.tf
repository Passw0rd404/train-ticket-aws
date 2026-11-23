resource "aws_security_group" "this" {
  name        = "${var.name}-rabbitmq"
  description = "AMQPS access for ${var.name}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-rabbitmq"
  }
}

# Amazon MQ for RabbitMQ only accepts TLS connections (AMQPS on 5671)
resource "aws_vpc_security_group_ingress_rule" "amqps" {
  count = length(var.allowed_security_group_ids)

  security_group_id            = aws_security_group.this.id
  referenced_security_group_id = var.allowed_security_group_ids[count.index]
  ip_protocol                  = "tcp"
  from_port                    = 5671
  to_port                      = 5671
  description                  = "AMQPS from allowed security group"
}

resource "random_password" "admin" {
  length  = 32
  special = false
}

resource "aws_mq_broker" "this" {
  broker_name = "${var.name}-rabbitmq"

  engine_type                = "RabbitMQ"
  engine_version             = var.engine_version
  host_instance_type         = var.instance_type
  deployment_mode            = var.deployment_mode
  auto_minor_version_upgrade = true
  apply_immediately          = var.apply_immediately

  publicly_accessible = false
  security_groups     = [aws_security_group.this.id]
  subnet_ids          = [var.subnet_ids[0]]

  user {
    username = var.admin_username
    password = random_password.admin.result
  }

  logs {
    general = true
  }

  maintenance_window_start_time {
    day_of_week = "SUNDAY"
    time_of_day = "03:00"
    time_zone   = "UTC"
  }

  tags = {
    Name = "${var.name}-rabbitmq"
  }
}
