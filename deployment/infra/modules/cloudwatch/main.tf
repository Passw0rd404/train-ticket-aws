resource "aws_sns_topic" "alerts" {
  name = "${var.name}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# Symptom / saturation alarms only (indicators of real service degradation or DoS)

resource "aws_cloudwatch_metric_alarm" "rds_storage_low" {
  alarm_name          = "${var.name}-rds-free-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 5368709120 # 5 GiB -> storage full freezes writes
  alarm_description   = "RDS MySQL free storage < 5 GiB (risk of write freeze)"
  dimensions          = { DBInstanceIdentifier = var.rds_identifier }
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "rds_memory_critical" {
  alarm_name          = "${var.name}-rds-freeable-memory-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 268435456 # 256 MiB -> OOM / swap thrashing
  alarm_description   = "RDS MySQL freeable memory < 256 MiB (OOM risk)"
  dimensions          = { DBInstanceIdentifier = var.rds_identifier }
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "rds_read_latency_high" {
  alarm_name          = "${var.name}-rds-read-latency-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ReadLatency"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 0.2 # 200ms
  alarm_description   = "RDS MySQL average read latency > 200ms"
  dimensions          = { DBInstanceIdentifier = var.rds_identifier }
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "rds_write_latency_high" {
  alarm_name          = "${var.name}-rds-write-latency-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "WriteLatency"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 0.2 # 200ms
  alarm_description   = "RDS MySQL average write latency > 200ms"
  dimensions          = { DBInstanceIdentifier = var.rds_identifier }
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "mq_disk_low" {
  alarm_name          = "${var.name}-mq-disk-free-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RabbitMQDiskFree"
  namespace           = "AWS/AmazonMQ"
  period              = 300
  statistic           = "Minimum"
  threshold           = 2147483648 # 2 GiB -> low disk watermark blocks publishers
  alarm_description   = "Amazon MQ RabbitMQ free disk < 2 GiB (publisher block risk)"
  dimensions          = { Broker = var.mq_broker_name }
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "mq_backlog_high" {
  alarm_name          = "${var.name}-mq-message-backlog-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MessageReadyCount"
  namespace           = "AWS/AmazonMQ"
  period              = 300
  statistic           = "Maximum"
  threshold           = 500
  alarm_description   = "Amazon MQ RabbitMQ ready message backlog > 500"
  dimensions          = { Broker = var.mq_broker_name }
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "nat_port_allocation_error" {
  alarm_name          = "${var.name}-nat-port-allocation-error"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ErrorPortAllocation"
  namespace           = "AWS/NATGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "NAT Gateway SNAT port exhaustion errors detected"
  dimensions          = { NatGatewayId = var.nat_gateway_id }
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "nat_packets_dropped" {
  alarm_name          = "${var.name}-nat-packets-dropped"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "PacketsDropCount"
  namespace           = "AWS/NATGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "NAT Gateway is actively dropping packets"
  dimensions          = { NatGatewayId = var.nat_gateway_id }
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
}
