resource "vault_auth_backend" "kubernetes" {
  count = var.kubernetes ? 1 : 0

  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "example" {
  count = var.kubernetes ? 1 : 0


  backend            = vault_auth_backend.kubernetes[0].path
  kubernetes_host    = var.kubernetes_ip
  kubernetes_ca_cert = file(var.kubernetes_ca_path)
  token_reviewer_jwt = var.token_reviewer_jwt
  issuer             = var.kubernetes_ip


  depends_on = [vault_auth_backend.kubernetes]
}

resource "vault_kubernetes_auth_backend_role" "example" {
  count                            = var.kubernetes ? 1 : 0
  backend                          = vault_auth_backend.kubernetes[0].path
  role_name                        = "test"
  bound_service_account_names      = ["default"]
  bound_service_account_namespaces = ["*"]
  token_ttl                        = 3600
  token_policies                   = ["test"]

  depends_on = [vault_kubernetes_auth_backend_config.example, vault_policy.policies]
}
