provider "vault" {

    address =  "http://localhost:8200"
    token = var.token
}


resource "vault_jwt_auth_backend" "oidc" {
    description              = "My OIDC auth config"
    type                     = "oidc"
    path                     = "oidc"
    
    oidc_client_id           = var.oidc_client_id
    oidc_client_secret       = var.oidc_client_secret
    oidc_discovery_url       = "http://192.168.49.2:30080/realms/${var.realm}"
}


resource "vault_jwt_auth_backend_role" "example" {
  backend         = vault_jwt_auth_backend.oidc.path
  role_name       = "viewer"

  user_claim            = "preferred_username"
  role_type             = "oidc"
  token_policies  = [vault_policy.readonly.name]
  allowed_redirect_uris = ["http://localhost:8200/ui/vault/auth/oidc/oidc/callback"]
  bound_audiences = ["vault"] 
  bound_claims = {
    "groups" = "/viewer"
  }
}


resource "vault_jwt_auth_backend_role" "admin" {
  backend         = vault_jwt_auth_backend.oidc.path
  role_name       = "admin"

  user_claim            = "preferred_username"
  role_type             = "oidc"
  token_policies  = [vault_policy.admin.name]
  bound_audiences = ["vault"] 
  allowed_redirect_uris = ["http://localhost:8200/ui/vault/auth/oidc/oidc/callback"]
  bound_claims = {
    "groups" = "/admin"
  }
}

resource "vault_mount" "kvv2" {
  path        = "kvv2"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_backend_v2" "kv-engine" {
  mount                = vault_mount.kvv2.path
  max_versions         = 5
  delete_version_after = 12600
  cas_required         = true
}



resource "vault_policy" "readonly" {
  name = "readonly"

  policy = <<EOT
path "secret/*" {
  capabilities = ["read" , "list"]
}

path "kvv2/*" {
  capabilities = ["read" , "list"]
}
EOT
}



resource "vault_policy" "admin" {
  name = "admin"

  policy = <<EOT

path "identity/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "sys/mounts/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "sys/policies/acl/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "database/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}


path "secret/*" {
  capabilities = ["read" , "list" , "create" ,"update", "delete"]
}

path "kvv2/*" {
  capabilities = ["read" , "list", "create" ,"update", "delete"]
}

EOT
}