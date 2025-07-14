
terraform {
  required_providers {
    aws = {
      version = ">= 2.7.0"
      source  = "hashicorp/aws"

    }
  }
  cloud {

    organization = "Self-studing12312"

    workspaces {
      name = "Cloud-init_example"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

data "cloudinit_config" "server_config" {
  gzip          = false
  base64_encode = true # AWS requires base64-encoded user_data

  # Part 1: Cloud-config (YAML) for system setup
  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"

    content = file("${path.root}/cloud_init.yaml")
  }
}


resource "aws_instance" "web_server" {
  ami           = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  user_data     = data.cloudinit_config.server_config.rendered # <-- Cloud-init here
  key_name      = "linux"
  tags = {
    Name = "Cloud-Init Example"
  }
}
