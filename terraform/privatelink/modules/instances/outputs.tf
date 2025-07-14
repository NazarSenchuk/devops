output "private_instances" {
  value = aws_instance.private_instance
}

output "publicsg" {
  value = aws_security_group.publicsg
}
