variable "aws_region" {
  description = "AWS Region."
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = "eks-cluster"
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags for AWS that will be attached to each resource."
  default = {
    "TerminationDate" = "Permanent",
    "Environment"     = "Development",
    "Team"            = "DevOps",
    "DeployedBy"      = "Terraform",
    "OwnerEmail"      = "senchuknazar6@gmail.com"
  }
}



variable "deployment_prefix" {
  description = "Prefix of the deployment."
  type        = string
  default     = "demo"
}

variable "instance_type" {
  description = "Type of instance"
  type        = string
  default     = "t3.medium"
}


variable "min_size" {
  description = "Minimum size of the cluster"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum size of the cluster"
  type        = number
  default     = 2
}

variable "desired_size" {
  description = "Desired size of the cluster"
  type        = number
  default     = 2
}

variable "addon_version" {
  description = "Version of the addon"
  type = string
  default = "v1.39.0-eksbuild.1"
}

    
