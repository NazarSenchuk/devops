variable "project" {
  description = "Name of project"
}

variable "vpc_name" {
  description = "Name of vpc"
  default     = "three-tier-vpc"
}


variable "number_of_frontend_subnets" {
  description = "Number of frontend subnets"
  default     = 1
}

variable "number_of_backend_subnets" {
  description = "Number of backend subnets"
  default     = 1
}

variable "number_of_database_subnets" {
  description = "Number of database subnets"
  default     = 1
}

variable "subnet_region" {
  description = "Region of subnets"
  default     = "us-central1"
}

