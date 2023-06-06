terraform {
  required_providers {
    aws = {
      version = ">= 3.69, < 5.0"
      source  = "hashicorp/aws"
    }
  }
  required_version = "~> 1.0"
}

