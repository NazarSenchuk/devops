variable "common_name" {
  description = "Common name for certificate"

}

variable "organization" {
  description = "Organization for certificate"
  default     = ""
}

variable "country" {
  description = "Organization for certificate"
  default     = ""

}

variable "delay_between_ca" {
  description = "Time delay beetwen creating root and intermidiate cas"
  default     = 10
}
