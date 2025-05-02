variable "public_subnet_cidrs" {
  description = "Public Subnet CIDR values"

  type        = list(string)

  default     = ["10.0.1.0/24", "10.0.2.0/24"]

}

 

variable "private_subnet_cidrs" { 
  description = "Private Subnet CIDR values"
 
  type        = list(string)

  default     = ["10.0.4.0/24", "10.0.5.0/24"]

}

variable "regions" {
  description = "Regions where to deploy"

  type        = list(string)

  default     = ["us-east-1a" , "us-east-1b"]
  
}