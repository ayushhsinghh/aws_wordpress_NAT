//Creating VPC
resource "aws_vpc" "MyVPC" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "MyVPC"
  }
}
//Creating Subnets
resource "aws_subnet" "PublicSubnet" {
  vpc_id     = aws_vpc.MyVPC.id
  cidr_block = "192.168.1.0/24"


  tags = {
    Name = "PublicSubnet"
  }
}
resource "aws_subnet" "PrivateSubnet" {
  vpc_id     = aws_vpc.MyVPC.id
  cidr_block = "192.168.2.0/24"


  tags = {
    Name = "PrivateSubnet"
  }
}

//Creating Internet Gateway
resource "aws_internet_gateway" "MyGateway" {
  vpc_id = aws_vpc.MyVPC.id

  tags = {
    Name = "MyGateway"
  }
}
//Routing Table Creation & Association with Internet Gatway
resource "aws_route_table" "MyRoute" {
  vpc_id = aws_vpc.MyVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.MyGateway.id
  }


  tags = {
    Name = "MyRoute"
  }
}
resource "aws_route_table_association" "pubSub" {
  subnet_id      = aws_subnet.PublicSubnet.id
  route_table_id = aws_route_table.MyRoute.id
}

// To get one static IP for NAT Gateway

resource "aws_eip" "NAT" {
	vpc	= true
}

// To create NAT Gateway 
resource "aws_nat_gateway" "MY-NAT-Gateway" {
	allocation_id	= aws_eip.NAT.id
	subnet_id	= aws_subnet.PublicSubnet.id
	tags = {
		Name = "natgateway"
	}
	depends_on	= [aws_internet_gateway.MyGateway]
}

#To create routing table for NAT Gateway
resource "aws_route_table" "myNatRoutingTable" {
	vpc_id	= aws_vpc.MyVPC.id
	route {
		cidr_block	= "0.0.0.0/0"
		nat_gateway_id	= aws_nat_gateway.MY-NAT-Gateway.id
	}
	tags = {
		Name = "routetablenatgateway"
	}
}

#To associate it with subnet
resource "aws_route_table_association" "assomysql" {
	subnet_id	= aws_subnet.PrivateSubnet.id
	route_table_id	= aws_route_table.myNatRoutingTable.id
}

