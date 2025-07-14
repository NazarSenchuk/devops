output "certificate" {
  value = aws_acmpca_certificate.end_entity.certificate

}

output "intermidiate_certificate" {
  value = module.ca.intermediate_ca

}
