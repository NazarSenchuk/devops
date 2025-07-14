
locals {
  public_subnets = {
    "us-east-1a" = "10.0.1.0/24",
    "us-east-1b" = "10.0.2.0/24"

  }

  routes = [
    {
      cidr_block = "0.0.0.0/0",
      gateway_id = aws_internet_gateway.my_igw.id
    },
    {
      cidr_block = "10.0.0.0/16",
      gateway_id = "local"

    }
  ]

  ingress = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]

    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  ]

  egress = [
    { from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    },

  ]
}


# Creating vpc
resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr_block

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc"
  }

}

#Creating subnets
resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = each.value
  map_public_ip_on_launch = true
  availability_zone       = each.key

  tags = {
    Name = "public subnet ${each.key} ",
  Tier = "public" }
}



# Creating Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "Gateway aws_vpc.my_vpc.id"
  }
}

# Creating Route Table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  dynamic "route" {
    for_each = local.routes
    content {
      cidr_block = route.cidr_block
      gateway_id = route.gateway_id
    }
  }

  tags = {
    Name = "Route Table ${aws_vpc.my_vpc.id} "
  }
}

resource "aws_route_table_association" "public" {
  count          = length(locals.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.my_route_table.id
}



# Створення Security Group
resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.my_vpc.id

  dynamic "ingress" {
    for_each = local.ingress
    content {
      from_port   = ingress.from_port
      to_port     = ingress.to_port
      protocol    = ingress.protocol
      cidr_blocks = ingress.cidr_blocks
    }

  }

  dynamic "egress" {
    for_each = local.egress
    content {

      from_port   = egress.from_port
      to_port     = egress.to_port
      protocol    = egress.protocol
      cidr_blocks = egress.cidr_blocks
    }

  }


  tags = {
    Name = "Security Group {$aws_vpc.my_vpc.id}"
  }
}
