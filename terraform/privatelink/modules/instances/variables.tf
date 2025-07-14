variable "ami" {
  description = "Ami of os image"
  default     = "ami-084568db4383264d4"
}

variable "instance_type" {
  description = "Type of instance"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key-pair name"
  default     = "linux"
}

variable "vpcs" {
  description = "Provider and customer vpcs"
}
