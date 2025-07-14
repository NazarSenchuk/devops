variable "server_ip" {
  description = "Vault server ip"
  default     = "https://vault:8200"

}

variable "cert_path" {
  description = "Path to cert of vault"
  default     = "/vault/tls/tls.crt"

}

variable "tls_enabled" {
  default = false

}
variable "token" {
  description = "Token for terraform actions"
  ephemeral   = true
}


variable "kubernetes" {
  description = "Condition of enabling kubernetes auth"
  default     = true

}
variable "kubernetes_ip" {
  description = "Ip of kubernetes cluster"
  default     = "https://kubernetes.default.svc.cluster.local"
}

variable "token_reviewer_jwt" {
  description = "Service account secret with auth delegator cluster role"

}

variable "kubernetes_ca_path" {
  description = "Path to cert file of your api server"

}
variable "policy_to_create" {
  description = "Paths to policies which you wanna create"
  type        = list(object({ name = string, path = string }))
  default     = [{ name = "test", path = "./policies/test_secret.hcl" }]
}
