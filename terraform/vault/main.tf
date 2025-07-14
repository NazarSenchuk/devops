provider "vault" {
  # It is strongly recommended to configure this provider through the
  # environment variables described above, so that each user can have
  # separate credentials set in the environment.
  #
  # This will default to using $VAULT_ADDR
  # But can be set explicitly
  address = "http://localhost:1234"
  token   = var.vault_token
}

data "vault_generic_secret" "database" {
  path = "secret/aws"
}

resource "local_file" "credentials_file" {
  content  = "Access Key: ${data.vault_generic_secret.database.data["access_key"]}\nSecret Key: ${data.vault_generic_secret.database.data["secret_key"]}"
  filename = "credentials.txt"
}
