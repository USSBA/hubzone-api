data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

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

# sns notification topics
data "aws_sns_topic" "alerts" {
  for_each = toset(["green", "yellow", "red", "security"])
  name     = "${local.account_name}-teams-${each.value}-notifications"
}

data "aws_s3_bucket" "logs" {
  bucket = "${local.account_ids[terraform.workspace]}-${local.region}-logs"
}
