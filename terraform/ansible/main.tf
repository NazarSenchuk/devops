provider "aws" {
  region = "us-east-1"
}

module "vpc"{
  source = "./vpc"
  
}
module "ansible"{
  source = "./ansible"
  ansible_subnet=  module.vpc.subnet_for_ansible
  vpc_id = module.vpc.vpc_id
}
