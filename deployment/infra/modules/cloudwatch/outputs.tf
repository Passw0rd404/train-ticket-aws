output "alarm_names" {
  value = [
    aws_cloudwatch_metric_alarm.rds_storage_low.alarm_name,
    aws_cloudwatch_metric_alarm.rds_memory_critical.alarm_name,
    aws_cloudwatch_metric_alarm.rds_read_latency_high.alarm_name,
    aws_cloudwatch_metric_alarm.rds_write_latency_high.alarm_name,
    aws_cloudwatch_metric_alarm.mq_disk_low.alarm_name,
    aws_cloudwatch_metric_alarm.mq_backlog_high.alarm_name,
    aws_cloudwatch_metric_alarm.nat_port_allocation_error.alarm_name,
    aws_cloudwatch_metric_alarm.nat_packets_dropped.alarm_name,
  ]
}

output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}
