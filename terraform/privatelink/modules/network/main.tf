
locals {
  vpcs = {
    provider_vpc = {
      name            = "Provider"
      cidr            = "11.0.0.0/16"
      private_subnets = ["11.0.1.0/24", "11.0.2.0/24"]
      public_subnets  = ["11.0.3.0/24", "11.0.4.0/24"]
      azs             = ["us-east-1a", "us-east-1b"]
    }
    consumer_vpc = {
      name            = "Consumer"
      cidr            = "21.0.0.0/16"
      private_subnets = ["21.0.1.0/24", "21.0.2.0/24"]
      public_subnets  = ["21.0.3.0/24", "21.0.4.0/24"]
      azs             = ["us-east-1a", "us-east-1b"]
    }
  }
}

module "vpc" {
  for_each = local.vpcs
  source   = "terraform-aws-modules/vpc/aws"
  version  = "~> 5.0"

  name = each.value.name
  cidr = each.value.cidr
  azs  = each.value.azs

  private_subnets = each.value.private_subnets
  public_subnets  = each.value.public_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = true

  map_public_ip_on_launch = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
