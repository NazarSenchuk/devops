output "root_ca" {

  value = aws_acmpca_certificate_authority.root_ca.certificate
}
output "intermidiate_ca" {

  value = aws_acmpca_certificate_authority.intermidiate_ca.certificate
}
output "intermidiate_arn" {
  value = aws_acmpca_certificate_authority.intermidiate_ca.intermidiate_ca

}
