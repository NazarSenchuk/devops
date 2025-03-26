provider "vault" {
  # It is strongly recommended to configure this provider through the
  # environment variables described above, so that each user can have
  # separate credentials set in the environment.
  #
  # This will default to using $VAULT_ADDR
  # But can be set explicitly
  address = "http://localhost:8200"
  token = var.vault_token
}

data "vault_generic_secret" "database" {
  path      = "secret/webapp/config"
}

resource "local_file" "credentials_file" {
  content = "${data.vault_generic_secret.database.data["password"]}"
  filename    = "credentials.txt"
}
