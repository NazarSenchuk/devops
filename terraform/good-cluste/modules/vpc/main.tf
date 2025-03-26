
# Створення VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {   
    Name = "my-vpc"
  }
}


resource "aws_subnet" "public1a" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch= true
  availability_zone = "us-east-1a"

  tags = {
    Name = "Main"
  }
}

resource "aws_subnet" "public2b" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch= true
  availability_zone = "us-east-1b"
  tags = {
    Name = "Main"
  }
}

# Створення Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my-igw"
  }
}

# Створення Route Table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  route {                                                                             
    cidr_block = "10.0.0.0/16"                                                         
    gateway_id = "local"                                     
  }  

  tags = {
    Name = "my-route-table"
  }
}
resource "aws_route_table_association" "public1a_association" {
  subnet_id      = aws_subnet.public1a.id
  route_table_id = aws_route_table.my_route_table.id
}
resource "aws_route_table_association" "public2b_association" {
  subnet_id      = aws_subnet.public2b.id
  route_table_id = aws_route_table.my_route_table.id
}



# Створення Security Group
resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "my-security-group"
  }
}
