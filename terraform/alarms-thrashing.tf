resource "aws_cloudwatch_metric_alarm" "thrash" {

  alarm_name        = "${terraform.workspace}-hubzone-api-thrashing"
  alarm_description = <<EOF
The ECS service ${terraform.workspace}-hubzone-api-fg container(s) appear to be thrashing.

Possible issues:
- The service healthcheck is failing
- The service is crashing before reaching a steady state

What to check:
- Container Service Event Log
- CloudWatch Logs for indicators like memory or connectivity issues

Remediation:
- Manually roll the service back to a prior image using Terraform
EOF

  alarm_actions = [local.sns_alarms.red]
  ok_actions    = []

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  threshold           = 1

  metric_query {
    id          = "thrash"
    expression  = "IF(CEIL(dt) - FLOOR(rt), 1, 0) AND CEIL(dc) > 1"
    label       = "Thrashing"
    return_data = true
  }

  metric_query {
    id = "dt"
    metric {
      metric_name = "DesiredTaskCount"
      namespace   = "ECS/ContainerInsights"
      period      = 300
      stat        = "Maximum"
      dimensions = {
        ServiceName = "${terraform.workspace}-hubzone-api-fg"
        ClusterName = terraform.workspace
      }
    }
  }

  metric_query {
    id = "rt"
    metric {
      metric_name = "RunningTaskCount"
      namespace   = "ECS/ContainerInsights"
      period      = 300
      stat        = "Minimum"
      dimensions = {
        ServiceName = "${terraform.workspace}-hubzone-api-fg"
        ClusterName = terraform.workspace
      }
    }
  }

  metric_query {
    id = "dc"
    metric {
      metric_name = "DeploymentCount"
      namespace   = "ECS/ContainerInsights"
      period      = 300
      stat        = "Minimum"
      dimensions = {
        ServiceName = "${terraform.workspace}-hubzone-api-fg"
        ClusterName = terraform.workspace
      }
    }
  }
}
