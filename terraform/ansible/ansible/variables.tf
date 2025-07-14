variable "ansible_subnet" {
  description = "Subnet for ansible"

}
variable "vpc_id" {}

variable "instance_type" {
  description = "Instance type name"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of your key pair"
  default     = "linux"
}

variable "ami_id" {
  description = "Id of ami"
  default     = "ami-084568db4383264d4"
}
