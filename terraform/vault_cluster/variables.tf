variable "tls_enabled" {
  description = "TLS in vault cluster"
  default     = "false"
}

variable "followers_count" {
  description = "Count of followers in cluster"
  default     = 1
}
variable "storage_capacity" {
  description = "Capacity of storage on every vault node"
  default     = 1
}

variable "ca_cert" {
  description = "CA certificate for vault, if tls is enabled"
  default     = "nothing"
}
variable "ca_key" {
  description = "CA key for vault, if tls is enabled"
  default     = "nothing"
}

variable "aws_access_key" {
  description = "AWS Access key for awskms autounsealing"


}
variable "aws_secret_key" {
  description = "AWS Secret key for awskms autounsealing"

}

