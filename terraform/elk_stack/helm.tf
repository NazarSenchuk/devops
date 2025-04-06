  resource "kubernetes_namespace" "elastic_system" {
    metadata {
      name = "elastic-system"
    }
  }

  resource "helm_release" "eck_operator" {
    
    
    name       = "elastic-operator"
    repository = "https://helm.elastic.co"
    chart      = "eck-operator"
    version    = "2.8.0" # use the latest version
    namespace  = "elastic-system"
    
    set {
      name = "installCRDS"
      value = "true"

  }
  }
    
    
  