
module "vpc" {
  source  = "./modules/vpc"
  project = var.project
}

module "app" {
  source          = "./modules/app"
  vpc             = module.vpc.vpc
  backend_subnet  = module.vpc.backend_subnet
  frontend_subnet = module.vpc.frontend_subnet
}
