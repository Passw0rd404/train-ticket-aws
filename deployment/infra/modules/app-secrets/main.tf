# Secret names and key names match what the service values files expect.
# Every value is a plain string.

# ---- MySQL (27 services) ----------------------------------------------------
resource "random_password" "mysql_app" {
  length  = 32
  special = false # keeps the password safe inside JDBC and URL strings
}

resource "aws_secretsmanager_secret" "mysql" {
  name                    = "${var.prefix}/mysql"
  description             = "MySQL connection for the application services"
  recovery_window_in_days = var.recovery_window_in_days
}

resource "aws_secretsmanager_secret_version" "mysql" {
  secret_id = aws_secretsmanager_secret.mysql.id

  secret_string = jsonencode({
    host     = var.mysql_host
    port     = tostring(var.mysql_port)
    database = var.mysql_database
    user     = var.mysql_user
    password = random_password.mysql_app.result
  })
}

# ---- MySQL bootstrap (k8s db-init Job creates the dedicated app user) -------
resource "aws_secretsmanager_secret" "mysql_bootstrap" {
  name                    = "${var.prefix}/mysql-bootstrap"
  description             = "RDS admin + app credentials used once by the in-cluster db-init Job"
  recovery_window_in_days = var.recovery_window_in_days
}

resource "aws_secretsmanager_secret_version" "mysql_bootstrap" {
  secret_id = aws_secretsmanager_secret.mysql_bootstrap.id

  secret_string = jsonencode({
    host           = var.mysql_host
    port           = tostring(var.mysql_port)
    database       = var.mysql_database
    admin_user     = var.mysql_admin_user
    admin_password = var.mysql_admin_password
    app_user       = var.mysql_user
    app_password   = random_password.mysql_app.result
  })
}

# ---- RabbitMQ (ts-delivery-service, ts-food-service) ------------------------
resource "aws_secretsmanager_secret" "rabbitmq" {
  name                    = "${var.prefix}/rabbitmq"
  description             = "RabbitMQ connection for the application services"
  recovery_window_in_days = var.recovery_window_in_days
}

resource "aws_secretsmanager_secret_version" "rabbitmq" {
  secret_id = aws_secretsmanager_secret.rabbitmq.id

  secret_string = jsonencode({
    host     = var.rabbitmq_host
    user     = var.rabbitmq_user
    password = var.rabbitmq_password
  })
}

# ---- Notification email (ts-notification-service) ---------------------------
resource "aws_secretsmanager_secret" "notification" {
  name                    = "${var.prefix}/notification-email"
  description             = "SMTP login for ts-notification-service"
  recovery_window_in_days = var.recovery_window_in_days
}

resource "aws_secretsmanager_secret_version" "notification" {
  secret_id = aws_secretsmanager_secret.notification.id

  secret_string = jsonencode({
    address  = "CHANGE_ME"
    password = "CHANGE_ME"
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# ---- Cloudflare Tunnel token (cloudflared) ----------------------------------
resource "aws_secretsmanager_secret" "cloudflare" {
  name                    = "${var.prefix}/cloudflare"
  description             = "Cloudflare Tunnel token for cloudflared"
  recovery_window_in_days = var.recovery_window_in_days
}

resource "aws_secretsmanager_secret_version" "cloudflare" {
  secret_id = aws_secretsmanager_secret.cloudflare.id

  secret_string = jsonencode({
    tunnelToken = var.cloudflare_tunnel_token
  })
}
