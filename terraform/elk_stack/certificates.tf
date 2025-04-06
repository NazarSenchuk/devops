resource "kubernetes_manifest" "quickstart_es_cert" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "ca.crt" = filebase64("${var.path_to_certs}/tls.crt")
      "tls.crt" = filebase64("${var.path_to_certs}//tls.crt")
      "tls.key" = filebase64("${var.path_to_certs}//tls.key")

    }
    "kind" = "Secret"
    "metadata" = {
      "name" = "my-tls-secret"
      "namespace" = "default"
    }
    "type" = "Opaque"
  }
}
