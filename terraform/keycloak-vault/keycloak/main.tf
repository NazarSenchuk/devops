

terraform {
  required_providers {
    keycloak = {
      source = "keycloak/keycloak"
      version = "5.5.0"
    }
  }
}

provider "keycloak" {
    client_id     = "admin-cli"
    username      = "admin"
    password      = "admin"
    url           = "http://keycloak.local.com:30080"
}

data "keycloak_realm" "realm" {
    realm = "master"
}

resource "keycloak_openid_client" "openid_client" {
    client_id = "vault"
    realm_id  = data.keycloak_realm.realm.id
    name    = "vault"
    enabled = true

    access_type           = "CONFIDENTIAL"
    standard_flow_enabled = true
    valid_redirect_uris = [
        "http://localhost:8200/*"
    ]

    login_theme = "keycloak"
     direct_access_grants_enabled = true
}


