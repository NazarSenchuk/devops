variable "ami_id" {
  description = "Ami id of node image"
  default     = "ami-084568db4383264d4"
}

variable "instance_type_for_controlplane" {
  description = "Instance type name"
  default     = "t2.medium"
}

variable "key_name" {
  description = "Name of your key pair"
  default     = "linux"
}

variable "count_controlplane" {
  description = "Count of controlplane nodes"
  default     = 1
}

variable "subnets_for_controlplanes" {
  description = "Subnets for conrolplane  nodes"
}

variable "default_security_group_id" {
  description = "Default security group for nodes"
}
