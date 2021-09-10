locals {
  region       = data.aws_region.current.name
  account_id   = data.aws_caller_identity.current.account_id
  account_name = contains(["stg", "prod"], terraform.workspace) ? "upper" : "lower"
  account_ids = {
    demo = "997577316207"
    stg  = "222484291001"
    prod = "222484291001"
  }
  all = {
    default = {
      service_name      = "hubzone-api"
      ecr_name          = "hubzone/hubzone-api"

      rails_port        = 3001
      task_cpu_rails    = "256"
      task_memory_rails = "512"

      # No scaling for the time being
      desired_capacity_rails = 1
    }
    demo = {
      domain_name = "demo.sba-one.net"
      cert_domain = "sba-one.net"
    }
    stg = {
      domain_name = "stg.certify.sba.gov"
    }
    prod = {
      domain_name = "certify.sba.gov"
      #TODO: Bigify this
      task_cpu    = "256"
      task_memory = "512"
    }
  }
  # Condense all config into a single `local.env.*`
  env = merge(local.all.default, try(local.all[terraform.workspace], {}))

  #TODO: Swap FQDN to non-fg url
  service_fqdn  = "${local.env.service_name}-fg.${local.env.domain_name}"
  postgres_fqdn = "hubzone-db.${local.env.domain_name}"

  # Convenience prefixes for AWS Resources
  prefix_bucket          = "arn:aws:s3:::"
  prefix_ecr             = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com"
  prefix_parameter_store = "arn:aws:ssm:${local.region}:${local.account_id}:parameter"
}
