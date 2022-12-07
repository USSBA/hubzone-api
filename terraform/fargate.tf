variable "image_tag" {
  type = string
}

locals {
  container_environment = {
    RAILS_ENV           = local.env.rails_env
    RAILS_LOG_TO_STDOUT = "true"
    RAILS_MAX_THREADS   = "5"
    HUBZONE_API_DB_HOST = "hubzone-db.demo.sba-one.net"
  }
  container_secrets_parameterstore = {
    HUBZONE_API_DB_USER     = "${terraform.workspace}/hubzone/rds/username"
    HUBZONE_API_DB_PASSWORD = "${terraform.workspace}/hubzone/rds/password"
    HUBZONE_GOOGLE_API_KEY  = "${terraform.workspace}/hubzone/api/google_api_key"
    SECRET_KEY_BASE         = "${terraform.workspace}/hubzone/api/secret_key_base"
  }
}

module "api" {
  source  = "USSBA/easy-fargate-service/aws"
  version = "~> 7.0"

  # cloudwatch logging
  log_group_name              = "/ecs/${terraform.workspace}/${local.env.service_name}"
  log_group_retention_in_days = 90

  # access logs
  # note: bucket permission may need to be adjusted
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions
  alb_log_bucket_name = local.env.log_bucket
  alb_log_prefix      = "${terraform.workspace}/alb/${local.env.service_name}"

  family                 = "${terraform.workspace}-${local.env.service_name}-fg"
  task_cpu               = local.env.task_cpu_rails
  task_memory            = local.env.task_memory_rails
  enable_execute_command = true
  #alb_idle_timeout      = 60

  ## If the ecs task needs to access AWS API for any reason, grant
  ## it permissions with this parameter and the policy resource below
  #task_policy_json       = data.aws_iam_policy_document.fargate.json

  # Deployment
  enable_deployment_rollbacks        = true
  wait_for_steady_state              = true
  deployment_maximum_percent         = 400
  deployment_minimum_healthy_percent = 100

  # Scaling and health
  desired_capacity                 = local.env.desired_container_count_rails
  max_capacity                     = local.env.max_container_count_rails
  min_capacity                     = local.env.min_container_count_rails
  scaling_metric                   = local.env.scaling_metric
  scaling_threshold                = local.env.scaling_threshold
  scheduled_actions                = try(local.env.scheduled_actions, [])
  scheduled_actions_timezone       = try(local.env.scheduled_actions_timezone, "UTC")
  health_check_path                = local.env.health_check_path
  health_check_timeout             = 5
  health_check_interval            = 20
  health_check_healthy_threshold   = 2
  health_check_unhealthy_threshold = 9

  # networking
  service_fqdn       = local.service_fqdn
  hosted_zone_id     = data.aws_route53_zone.selected.zone_id
  private_subnet_ids = data.aws_subnets.private.ids
  vpc_id             = data.aws_vpc.selected.id
  certificate_arn    = data.aws_acm_certificate.selected.arn

  # container(s)
  cluster_name   = data.aws_ecs_cluster.selected.cluster_name
  container_port = local.env.rails_port
  container_definitions = [
    {
      name        = "api"
      image       = "${local.prefix_ecr}/${local.env.ecr_name}:${var.image_tag}"
      environment = [for k, v in local.container_environment : { name = k, value = v }]
      secrets     = [for k, v in local.container_secrets_parameterstore : { name = k, valueFrom = "${local.prefix_parameter_store}/${v}" }]
    },
  ]
}

## If the ecs task needs to access AWS API for any reason, grant it permissions with this
#
#data "aws_iam_policy_document" "fargate" {
#  statement {
#    sid = "AllResources"
#    actions = [
#      "s3:ListAllMyBuckets",
#      "s3:GetBucketLocation",
#    ]
#    resources = ["*"]
#  }
#}
