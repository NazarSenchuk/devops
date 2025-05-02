
data "aws_key_pair" "linux"{
  key_name = var.key_name
}

locals {
  ingress_rules = [{
    port = 22
    protocol = "TCP"
    description = "Allows ssh trafic"
  },
  {
    port = 80
    protocol = "TCP"
    description = "Allows 80 port"
  }]  
  
  egress_rules = [{
    port = 0 
    protocol = "-1"
    description = "Allows all outbound trafic"
  }]

}

resource "aws_security_group" "allow_all_trafic" {
  name        = "allow_all_trafic"
  description ="Allows all trafic"
  vpc_id      = var.vpc_id



  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ["0.0.0.0/0"]
    }
    }

  dynamic "egress" {
    for_each = local.egress_rules
    content {
      description = egress.value.description
      from_port   = egress.value.port
      to_port     = egress.value.port
      protocol    = egress.value.protocol
      cidr_blocks = ["0.0.0.0/0"]
    }
    }

  
  tags = {
    Name = "ansible"
    }
  
}



resource "aws_instance" "ansible" {
    count = 1 

    subnet_id = var.ansible_subnet
    ami = var.ami_id
    instance_type = var.instance_type
    key_name = data.aws_key_pair.linux.key_name	
    security_groups=[aws_security_group.allow_all_trafic.id]
    
    tags = {
        Name = "ansible"
    }

    user_data = filebase64("${path.module}/ansible.sh")
}
