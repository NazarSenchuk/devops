output "subnet_for_ansible" {
    value = module.vpc.public_subnets[0]
  
}

output "vpc_id"{
    value = module.vpc.vpc_id
}
