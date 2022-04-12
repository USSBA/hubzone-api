# vpc
data "aws_vpc" "selected" {
  tags = {
    Name = "${terraform.workspace}-vpc"
  }
}

# subnet ids
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  filter {
    name = "tag:Name"
    values = [
      "${terraform.workspace}-private-subnet-*"
    ]
  }
}
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  filter {
    name = "tag:Name"
    values = [
      "${terraform.workspace}-public-subnet-*"
    ]
  }
}

## hosted zone
data "aws_route53_zone" "selected" {
  name = "${local.env.fqdn_base}."
}

## acm
data "aws_acm_certificate" "selected" {
  domain      = local.env.cert_domain
  statuses    = ["ISSUED"]
  most_recent = true
}

## ecs cluster
data "aws_ecs_cluster" "selected" {
  cluster_name = terraform.workspace
}

## Elasticache Redis
#data "aws_elasticache_replication_group" "redis" {
#  replication_group_id = "${terraform.workspace}-shared-services"
#}
#data "aws_elasticache_cluster" "redis" {
#  cluster_id = tolist(data.aws_elasticache_replication_group.redis.member_clusters)[0]
#}

## RDS Postgres Instance
data "aws_db_instance" "rds" {
  db_instance_identifier = "${terraform.workspace}-hubzone-aurora"
}
#data "aws_rds_cluster" "rds" {
#  cluster_identifier = "${terraform.workspace}-hubzone-aurora"
#}

# SNS Topics
data "aws_sns_topic" "topics" {
  for_each = toset(["red", "green", "yellow", "security", "email-admins"])
  name     = "sba-notification-framework-${each.key}"
}
locals {
  sns_red          = data.aws_sns_topic.topics["red"].arn
  sns_yellow       = data.aws_sns_topic.topics["yellow"].arn
  sns_green        = data.aws_sns_topic.topics["green"].arn
  sns_security     = data.aws_sns_topic.topics["security"].arn
  sns_email_admins = data.aws_sns_topic.topics["email-admins"].arn
}
