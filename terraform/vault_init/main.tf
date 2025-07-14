provider "vault" {
  address      = var.server_ip
  token        = var.token
  ca_cert_file = var.tls_enabled ? var.cert_path : null
}
