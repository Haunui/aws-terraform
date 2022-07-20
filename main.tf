terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}

resource "aws_vpc" "vpc0" {
  for_each = var.vpc
  cidr_block = "${each.value.cidr_block}"
  tags = {
    Name = "${var.prefix.vpc}haunui-${each.key}"
  }
}

resource "aws_subnet" "subnet0" {
  for_each = local.subnet
  vpc_id = each.value.vpc_id
  cidr_block = "${each.value.cidr_block}"
  tags = {
    Name = "${var.prefix.subnet}haunui-${each.key}"
  }
}

resource "aws_internet_gateway" "igw0" {
  for_each = local.igw
  vpc_id = each.value.vpc_id
  tags = {
    Name = "${var.prefix.igw}haunui-${each.key}"
  }
}

resource "aws_nat_gateway" "nat0" {
  for_each = local.nat
  connectivity_type = "${each.value.connectivity_type}"
  subnet_id = each.value.subnet_id
  allocation_id = each.value.allocation_id
  tags = {
    Name = "${var.prefix.nat}haunui-${each.key}"
  }
}

resource "aws_instance" "instance0" {
  for_each = local.instance
  ami = each.value.ami
  instance_type = "t2.micro"
  key_name = "${each.value.key_name}"
  subnet_id = each.value.subnet_id
  vpc_security_group_ids = each.value.vpc_security_group_ids
  associate_public_ip_address = each.value.associate_public_ip_address

  tags = {
    Name = "${var.prefix.instance}haunui-${each.key}"
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > public_ip"
  }
}

resource "aws_route_table" "rtb0" {
  for_each = local.rtb
  vpc_id = each.value.vpc_id

  tags = {
    Name = "${var.prefix.rtb}haunui-${each.key}"
  }
}

resource "aws_route_table_association" "rtba0" {
  for_each = local.rtb
  subnet_id = each.value.subnet_id
  route_table_id = aws_route_table.rtb0["${each.key}"].id
}

resource "aws_route" "route0" {
  for_each = local.route
  route_table_id = "${each.value.route_table_id}"
  destination_cidr_block = "${each.value.destination_cidr_block}"
  gateway_id = "${each.value.gateway_id}"
}

resource "aws_eip" "eip0" {
  for_each = local.eip
  vpc = each.value.vpc

  tags = {
    Name = "${var.prefix.eip}haunui-${each.key}"
  }
}

resource "aws_security_group" "sg0" {
  for_each = local.sg
  name = "haunui${each.key}"
  description = each.value.description
  vpc_id = each.value.vpc_id

}

resource "aws_security_group_rule" "sgr0" {
  for_each = local.sgr
  security_group_id = "${each.value.security_group_id}"
  source_security_group_id = try("${each.value.source_security_group_id}", null)
  type = "${each.value.type}"
  from_port = each.value.from_port
  to_port = each.value.to_port
  protocol = "${each.value.protocol}"
  cidr_blocks = try("${each.value.cidr_blocks}", null)
}
