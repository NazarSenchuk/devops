terraform {
  required_version = ">= 1.0.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.72"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4"
    }
  }
}
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.default_tags
  }
}
