# messaging to RDS
resource "aws_security_group_rule" "api_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.archive_api.security_group_id
  security_group_id        = data.aws_db_instance.rds.vpc_security_groups[0]
}

# rails to redis
#resource "aws_security_group_rule" "rails_to_redis" {
#  type                     = "ingress"
#  from_port                = 0
#  to_port                  = 65535
#  protocol                 = "tcp"
#  source_security_group_id = module.rails.security_group_id
#  security_group_id        = tolist(data.aws_elasticache_cluster.redis.security_group_ids)[0]
#}
