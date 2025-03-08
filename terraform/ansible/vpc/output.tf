output "subnet_for_ansible" {
    value = aws_subnet.public_subnets[0]
  
}
output "vpc_id"{
    value = aws_vpc.vpc.id
}
