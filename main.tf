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
  private_ip = each.value.private_ip

  user_data = fileexists(try("${each.value.user_data}", "does_not_exist")) ? file("${each.value.user_data}") : null

  tags = {
    Name = "${var.prefix.instance}haunui-${each.key}"
  }

  provisioner "local-exec" {
    command = "mkdir -p instances; echo ${self.public_ip} > instances/${each.key}-public_ip"
  }

  provisioner "local-exec" {
    command = "mkdir -p instances; echo ${self.private_ip} > instances/${each.key}-private_ip"
  }
}

resource "aws_default_route_table" "drtb0" {
  for_each = local.drtb
  default_route_table_id = each.value.default_route_table_id
  
  dynamic "route" {
    for_each = toset(each.value.routes)

    content {
      cidr_block = route.value.cidr_block
      vpc_peering_connection_id = route.value.vpc_peering_connection_id
    }
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
  gateway_id = try("${each.value.gateway_id}", null)
  nat_gateway_id = try("${each.value.nat_gateway_id}", null)
  vpc_peering_connection_id = try("${each.value.vpc_peering_connection_id}", null)

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

  tags = {
    Name = "${var.prefix.sg}haunui-${each.key}"
  }
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

resource "aws_vpc_peering_connection" "vpc_pc0" {
  for_each = local.vpc_pc
  peer_owner_id = each.value.peer_owner_id
  peer_vpc_id   = each.value.peer_vpc_id
  vpc_id        = each.value.vpc_id
  peer_region   = try(each.value.peer_region, null)
  auto_accept   = true

  tags = {
    Name = "${var.prefix.vpc_pc}haunui-${each.key}"
  }
}

resource "aws_network_acl" "nacl0" {
  for_each = local.nacl
  vpc_id = each.value.vpc_id
  subnet_ids = try(each.value.subnet_ids, null)

  tags = {
    Name = "${var.prefix.nacl}haunui-${each.key}"
  }
}

resource "aws_network_acl_rule" "nacl_rule0" {
  for_each = local.nacl_rule
  network_acl_id = each.value.network_acl_id
  rule_number = each.value.rule_number
  protocol = each.value.protocol
  egress = try(each.value.egress, null)
  rule_action = each.value.rule_action
  cidr_block = each.value.cidr_block
  from_port = try(each.value.from_port, null)
  to_port = try(each.value.to_port, null)
}
