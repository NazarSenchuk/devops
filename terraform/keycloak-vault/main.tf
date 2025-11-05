module "keycloak" {
    source="./keycloak"


}


module "vault" {
    source="./vault"
    oidc_client_id=module.keycloak.client_id
    oidc_client_secret=module.keycloak.client_secret
    token = var.token
    realm =  module.keycloak.realm
}
