variable "image_tag" {
  type = string
}

locals {
  container_environment = {
    RAILS_ENV           = terraform.workspace
    HUBZONE_API_DB_HOST = local.postgres_fqdn
    RAILS_LOG_TO_STDOUT = "true"
    HUBZONE_API_DB_NAME = "hzgeo_${terraform.workspace}"
    RAILS_MAX_THREADS   = "5"
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
  version = "~> 6.3"

  # logging
  log_group_name              = "/ecs/${terraform.workspace}/${local.env.service_name}"
  log_group_retention_in_days = 90

  family                 = "${terraform.workspace}-${local.env.service_name}-fg"
  task_cpu               = local.env.task_cpu_rails
  task_memory            = local.env.task_memory_rails
  task_policy_json       = data.aws_iam_policy_document.fargate.json
  enable_execute_command = true
  #alb_idle_timeout      = 60

  # Deployment
  enable_deployment_rollbacks        = true
  wait_for_steady_state              = true
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  # Scaling and health
  desired_capacity     = local.env.desired_capacity_rails
  max_capacity         = local.env.desired_capacity_rails
  min_capacity         = local.env.desired_capacity_rails
  health_check_path    = "/api/aws-hc"
  health_check_timeout = 5

  # networking
  service_fqdn       = local.service_fqdn
  hosted_zone_id     = data.aws_route53_zone.selected.zone_id
  #public_subnet_ids  = data.aws_subnet_ids.public.ids
  private_subnet_ids = data.aws_subnet_ids.private.ids
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

data "aws_iam_policy_document" "fargate" {
  statement {
    sid = "AllResources"
    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]
    resources = ["*"]
  }
}
