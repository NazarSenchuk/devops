provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

module "network" {
  source = "./modules/network/"

}

module "instances" {
  source = "./modules/instances/"

  vpcs = module.network.vpcs
}

module "privatelink" {
  source = "./modules/privatelink/"

  vpcs              = module.network.vpcs
  private_instances = module.instances.private_instances
  publicsg          = module.instances.publicsg
}
