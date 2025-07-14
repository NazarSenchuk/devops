
provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

module "network" {
  source = "./modules/network"
}

module "kubeadm" {
  source                    = "./modules/kubeadm_cluster/"
  default_security_group_id = module.network.default_security_group_id
  subnets_for_controlplanes = module.network.subnets_for_controlplanes
}



