provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "helm_release" "ingress" {
  name       = "nginx-ingress-controller"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"


  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

}


resource "kubernetes_pod_v1" "app1" {
  metadata {
    name = "my-app1"
    labels = {
      "app" = "app1"
    }
  }

  spec {
    container {
      image = "hashicorp/http-echo"
      name  = "my-app1"
      args  = ["-text=Hello from my app 1"]
    }
  }
}
resource "kubernetes_pod_v1" "app2" {
  metadata {
    name = "my-app2"
    labels = {
      "app" = "app2"
    }
  }

  spec {
    container {
      image = "hashicorp/http-echo"
      name  = "my-app2"
      args  = ["-text=Hello from my app 2"]
    }
  }
}


resource "kubernetes_service_v1" "app1_service" {
  metadata {
    name = "my-app1-service"
  }
  spec {
    selector = {
      app = kubernetes_pod_v1.app1.metadata.0.labels.app
    }
    port {
      port = 5678
    }
  }
}

resource "kubernetes_service_v1" "app2_service" {
  metadata {
    name = "my-app2-service"
  }
  spec {
    selector = {
      app = kubernetes_pod_v1.app2.metadata.0.labels.app
    }
    port {
      port = 5678
    }
  }
}


resource "kubernetes_ingress_v1" "ingress" {
  depends_on = [helm_release.ingress]
  wait_for_load_balancer = true
  metadata {
    name = "simple-fanout-ingress"
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      http {
        path {
          backend {
            service {
              name = "my-app1-service"
              port {
                number = 5678
              }
            }
          }

          path = "/app1"
        }

        path {
          backend {
            service {
              name = "my-app2-service"
              port {
                number = 5678
              }
            }
          }

          path = "/app2"
        }
      }
    }

  }
}

