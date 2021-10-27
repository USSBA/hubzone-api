# vpc
data "aws_vpc" "selected" {
  tags = {
    Name = "${terraform.workspace}-vpc"
  }
}

# subnet ids
data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.selected.id
  filter {
    name = "tag:Name"
    values = [
      "${terraform.workspace}-private-subnet-*"
    ]
  }
}
data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.selected.id
  filter {
    name = "tag:Name"
    values = [
      "${terraform.workspace}-public-subnet-*"
    ]
  }
}

## subnet resources
data "aws_subnet" "private" {
  for_each = data.aws_subnet_ids.private.ids
  id       = each.value
}
data "aws_subnet" "public" {
  for_each = data.aws_subnet_ids.public.ids
  id       = each.value
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

## WAF Regional
data "aws_wafv2_web_acl" "regional" {
  name  = "basic-waf-regional"
  scope = "REGIONAL"
}

