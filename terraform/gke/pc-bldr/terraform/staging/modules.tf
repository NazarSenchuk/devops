
module "vpc" {
  source    = "./modules/vpc"
  project   = var.project
  workspace = var.workspace
}

module "app" {
  source          = "./modules/app"
  workspace       = var.workspace
  vpc             = module.vpc.vpc
  backend_subnet  = module.vpc.backend_subnet
  frontend_subnet = module.vpc.frontend_subnet
  backend_name    = var.backend_name
  frontend_name   = var.frontend_name
}
