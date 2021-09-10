data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = [local.account_ids[terraform.workspace]]
}
terraform {
  backend "s3" {
    bucket               = "sba-certify-terraform-remote-state"
    region               = "us-east-1"
    dynamodb_table       = "terraform-state-locktable"
    acl                  = "bucket-owner-full-control"
    key                  = "hubzone-api.terraform.tfstate"
    workspace_key_prefix = "hubzone-api"
  }
}
