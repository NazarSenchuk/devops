resource "aws_security_group" "privatesg" {
  for_each    = var.vpcs
  name        = "privatesg"
  description = "Allow inbound traffic to the endpoint"
  vpc_id      = each.value.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["11.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "PrivateSG"
  }
}

resource "aws_security_group" "publicsg" {
  for_each    = var.vpcs
  name        = "publicsg"
  description = "Allow inbound ssh traffic to the endpoint"
  vpc_id      = each.value.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "PublicSG"
  }
}




resource "aws_instance" "private_instance" {
  for_each = var.vpcs

  ami             = var.ami
  instance_type   = var.instance_type
  subnet_id       = each.value.private_subnets[0]
  key_name        = var.key_name
  user_data       = file("${path.module}/nginx.tpl")
  security_groups = [aws_security_group.privatesg[each.key].id]

  tags = {
    Name = "${each.value.name}-private-instance"
  }
}

resource "aws_instance" "public_instance" {
  for_each = var.vpcs

  ami             = var.ami
  instance_type   = var.instance_type
  key_name        = var.key_name
  subnet_id       = each.value.public_subnets[0]
  security_groups = [aws_security_group.publicsg[each.key].id]

  tags = {
    Name = "${each.value.name}-public-instance"
  }
}
