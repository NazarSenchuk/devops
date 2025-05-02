terraform{
  backend "remote" {
    organization =  "Self-studing12312"

    workspaces {
      name = "ansible"  # Workspace in Terraform Cloud
    } 
  }
}

provider "aws" {
  region = "us-east-1"
  access_key= var.aws_access_key
  secret_key= var.secret_key
  
}

module "network"{
  source = "./network"
}

module "ansible"{
  source = "./ansible"

  ansible_subnet=  module.network.subnet_for_ansible
  vpc_id = module.network.vpc_id
}
