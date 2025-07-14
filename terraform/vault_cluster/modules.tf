
module "cluster" {
  source         = "./modules/cluster"
  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key
}
