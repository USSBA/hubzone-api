resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name          = "${terraform.workspace}-${local.env.service_name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5 #consecutive failures before reporting
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 30 #seconds per period
  datapoints_to_alarm = 5

  statistic = "Average"
  threshold = 80 #% cpu usage limit for failing

  alarm_description = "${terraform.workspace} ${local.env.service_name} CPU utilization over 80% for the last 25 minutes"
  alarm_actions     = [local.sns_alarms.red]
  ok_actions        = [local.sns_alarms.green]

  dimensions = {
    "ClusterName" = data.aws_ecs_cluster.selected.cluster_name
    "ServiceName" = module.api.service.name
  }
}

resource "aws_cloudwatch_metric_alarm" "memory" {
  alarm_name          = "${terraform.workspace}-${local.env.service_name}-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300 #seconds per period
  datapoints_to_alarm = 5

  statistic = "Average"
  threshold = 80 #% cpu usage limit for failing

  alarm_description = "${terraform.workspace} ${local.env.service_name} Memory utilization over 80% for the last 25 minutes"
  alarm_actions     = [local.sns_alarms.red]
  ok_actions        = [local.sns_alarms.green]

  dimensions = {
    "ClusterName" = data.aws_ecs_cluster.selected.cluster_name
    "ServiceName" = module.api.service.name
  }
}
