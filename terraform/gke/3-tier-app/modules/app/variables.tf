variable "vpc" {
  description = "describe your variable"
}

variable "database_name" {
  description = "describe your variable"
  default     = "postgres"
}
variable "database_user" {
  description = "describe your variable"
  default     = "postgres"
}


variable "database_password" {
  description = "describe your variable"
  default     = "postgres"
}
variable "instance_type" {
  description = "Type of backend and frontend instance"
  default     = "e2-micro"
}

variable "zone" {
  description = "Zone where will be placed nodes"
  default     = "us-central1-a"

}

variable "frontend_subnet" {
  description = "describe your variable"
}
variable "backend_subnet" {
  description = "describe your variable"
}

