resource "aws_vpc" "vpc"{
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "main"

    }



}


resource "aws_subnet" "public_subnets" {
    count  = length(var.public_subnet_cidrs)
    vpc_id = aws_vpc.vpc.id
    cidr_block = element(var.public_subnet_cidrs,count.index)
  
    map_public_ip_on_launch = true
     tags = {

   Name = "Public Subnet ${count.index + 1}"

 }
}

resource "aws_subnet" "private_subnets" {
    count = length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.vpc.id
    cidr_block = element(var.private_subnet_cidrs,count.index)
     tags = {

   Name = "Private Subnet ${count.index + 1}"

 }


}


resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = aws_vpc.vpc.id

    tags = {
      Name="internet-gateway"
    }
  
}


resource "aws_route_table" "public_route_table" {

    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway.id

    }
    route {
        cidr_block="10.0.0.0/16"
        gateway_id="local"
    }


    tags = {
        Name= "public-route-table"

    }
  
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
    allocation_id = aws_eip.nat.id
    subnet_id = aws_subnet.public_subnets[0].id
    tags ={
        
        "Name"="Nat"

    }

}
resource "aws_route_table" "private_route_table" {

    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "10.0.0.0/16"
        gateway_id = "local"
    }
    route{
        cidr_block = "0.0.0.0/16"
        gateway_id = aws_nat_gateway.nat_gateway.id


    }
}

resource "aws_route_table_association" "public_subnet_associations" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_route_table_association" "private_subnet_associations" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}
