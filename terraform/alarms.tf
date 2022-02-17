resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name          = "${terraform.workspace}-${local.env.service_name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5 #consecutive failures before reporting
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60 #seconds per period
  statistic           = "Average"
  threshold           = 80 #% cpu usage limit for failing

  alarm_description = "${terraform.workspace} ${local.env.service_name} has had its CPU over 80% for the last 5 minutes"
  alarm_actions     = local.env.fargate_alarm_targets
  ok_actions        = local.env.fargate_alarm_targets

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
  period              = 60 #seconds per period
  statistic           = "Average"
  threshold           = 80 #% cpu usage limit for failing

  alarm_description = "${terraform.workspace} ${local.env.service_name} has had its Memory over 80% for the last 5 minutes"
  alarm_actions     = local.env.fargate_alarm_targets
  ok_actions        = local.env.fargate_alarm_targets

  dimensions = {
    "ClusterName" = data.aws_ecs_cluster.selected.cluster_name
    "ServiceName" = module.api.service.name
  }
}

resource "aws_cloudwatch_metric_alarm" "rate5xx" {
  count                     = terraform.workspace == "prod" ? 1 : 0
  alarm_name                = "${terraform.workspace}-${local.env.service_name}-5xx-error-rate"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "5"
  threshold                 = "1"
  alarm_description         = "Request error rate has exceeded 1% over 25 minutes"
  alarm_actions             = local.env.fargate_alarm_targets
  ok_actions                = local.env.fargate_alarm_targets
  insufficient_data_actions = []

  metric_query {
    id          = "e1"
    expression  = "m2/m1*100"
    label       = "Error Rate"
    return_data = "true"
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "RequestCount"
      namespace   = "AWS/ApplicationELB"
      period      = "300"
      stat        = "Sum"
      unit        = "Count"
      dimensions = {
        LoadBalancer = module.api.alb.arn_suffix
      }
    }
  }

  metric_query {
    id = "m2"
    metric {
      metric_name = "HTTPCode_ELB_5XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = "300"
      stat        = "Sum"
      unit        = "Count"
      dimensions = {
        LoadBalancer = module.api.alb.arn_suffix
      }
    }
  }
}
