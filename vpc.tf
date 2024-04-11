resource "aws_vpc" "dev" {
  cidr_block = var.cidr_block
  enable_dns_hostnames=true
  tags = {
    "Name" = var.vpc_name 
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev.id
  tags = {
    "Name" =  "${var.vpc_name}-igw"
  }
}

resource "aws_subnet" "publicsubnet" {
  count = 3
  vpc_id = aws_vpc.dev.id
  cidr_block = element(var.cidr_block_public_subnet,count.index)
  availability_zone = element(var.avzs,count.index)
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${var.vpc_name}-publicsubnet${count.index+1}"
  }
}

resource "aws_subnet" "privatesubnet" {
  count = 3
  vpc_id = aws_vpc.dev.id
  cidr_block = element(var.cidr_block_private_subnet,count.index)
  availability_zone = element(var.avzs,count.index)
  tags = {
    "Name" = "${var.vpc_name}-privatesubnet${count.index+1}"
  }
}

resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.dev.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags={
    "Name"="${var.vpc_name}-publicrt"
  }
}

resource "aws_route_table" "privatert" {
  vpc_id = aws_vpc.dev.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }
  tags={
    "Name"="${var.vpc_name}-privatert"
  }
}

resource "aws_route_table_association" "publicrtassoc" {
  count = 3
  subnet_id = element(aws_subnet.publicsubnet.*.id,count.index)
  route_table_id = aws_route_table.publicrt.id
}

resource "aws_route_table_association" "privatertassoc" {
  count = 3
  subnet_id = element(aws_subnet.privatesubnet.*.id,count.index)
  route_table_id = aws_route_table.privatert.id
}

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.dev.id
  description = "allow rules"
  name = "sg"
  ingress {
    to_port = 0
    from_port = 0
    protocol = -1
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    to_port = 0
    from_port = 0
    protocol = -1
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  tags = {
    "Name" = "${var.vpc_name}-sg"
  }
}

resource "aws_instance" "privateserver" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [ aws_security_group.sg.id ]
  subnet_id = aws_subnet.privatesubnet[0].id
  private_ip = var.private_ip
  iam_instance_profile = var.profile
tags = {
  "Name" = "${var.vpc_name}-privateserver"
}
}











