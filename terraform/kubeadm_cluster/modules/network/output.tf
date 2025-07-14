output "subnets_for_controlplanes" {
  value = module.vpc.public_subnets

}

output "subnets_for_worker" {
  value = module.vpc.public_subnets
}

output "vpc_id" {
  value = module.vpc.vpc_id
}


output "default_security_group_id" {
  value = aws_security_group.my_security_group.id
}
