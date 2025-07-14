resource "vault_policy" "policies" {
  count  = length(var.policy_to_create)
  name   = var.policy_to_create[count.index].name
  policy = file(var.policy_to_create[count.index].path)

  depends_on = [vault_kv_secret_v2.test_secrets]
}
