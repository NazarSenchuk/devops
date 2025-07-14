data "template_file" "values" {
  template = file("${path.module}/values.tpl")
  vars = {
    tls_enabled      = var.tls_enabled
    followers_count  = var.followers_count
    storage_capacity = var.storage_capacity
    ca_cert          = var.ca_cert
    ca_key           = var.ca_key
    aws_access_key   = var.aws_access_key
    aws_secret_key   = var.aws_secret_key
  }
}

resource "helm_release" "vault" {
  name            = "vault"
  chart           = "${path.module}/helm/vault-cluster"
  values          = [data.template_file.values.rendered]
  cleanup_on_fail = true
}
