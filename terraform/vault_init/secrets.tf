resource "vault_mount" "kvv2" {
  path        = "kv"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_backend_v2" "kvconfig" {
  mount                = vault_mount.kvv2.path
  max_versions         = 5
  delete_version_after = 12600
}


locals {
  kv_secrets = {
    "test_secret" = {
      path = "/kv/test/secret",
      secrets = {
        username = "admin",
        password = "admin",
        zip      = "zap",
        foo      = "bar"
      }
    }
  }
}

resource "vault_kv_secret_v2" "test_secrets" {
  for_each = local.kv_secrets
  mount    = vault_mount.kvv2.path
  name     = each.key

  data_json = jsonencode(each.value.secrets)
}
