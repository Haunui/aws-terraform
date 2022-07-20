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
  tags = {
    Name = "${var.prefix.nat}haunui-${each.key}"
  }
}

resource "aws_network_interface" "ni0" {
  for_each = local.ni
  subnet_id = each.value.subnet_id
  tags = {
    Name = "${var.prefix.ni}haunui-${each.key}"
  }
}

resource "aws_instance" "instance0" {
  for_each = local.instance
  ami = each.value.ami
  instance_type = "t2.micro"
  key_name = "${each.value.key_name}"

  dynamic "network_interface" {
    for_each = toset(each.value.network_interface)

    content {
      network_interface_id = network_interface.value.network_interface_id
      device_index = network_interface.value.device_index
    }
  }

  tags = {
    Name = "${var.prefix.instance}haunui-${each.key}"
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
