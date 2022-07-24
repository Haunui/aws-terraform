variable "pname" {
  type = any
  default = "haxa-assurance"
}

variable "prefix" {
  type = any
  default = {
    vpc = "vpc-"
    subnet = "subnet-"
    igw = "igw-"
    nat = "nat-"
    ni = "ni-"
    instance = "i-"
    rtb = "rtb-"
    eip = "eip-"
    sg = "sg-"
    vpc_pc = "vpc_pc-"
    nacl = "nacl-"
  }
}

variable "vpc" {
  type = any
  default = {
    central = {
      cidr_block = "172.22.0.0/16"
    }
    vpc1 = {
      cidr_block = "10.0.0.0/16"
    }
    vpc2 = {
      cidr_block = "10.1.0.0/16"
    }
  }
}

locals {
  subnet = {
    DMZ = {
      vpc_id = aws_vpc.vpc0["central"].id
      cidr_block = "172.22.0.0/24"
    }
    IB = {
      vpc_id = aws_vpc.vpc0["central"].id
      cidr_block = "172.22.1.0/24"
    }

    vpc1sub0 = {
      vpc_id = aws_vpc.vpc0["vpc1"].id
      cidr_block = "10.0.0.0/24"
    }
    vpc2sub0 = {
      vpc_id = aws_vpc.vpc0["vpc2"].id
      cidr_block = "10.1.0.0/24"
    }
  }
  igw = {
    igw0 = {
      vpc_id = aws_vpc.vpc0["central"].id
    }
  }
  nat = {}
  instance = {
    admin = {
      ami = "ami-09e513e9eacab10c1"
      key_name = "keypair-haunui-ext"
      subnet_id = aws_subnet.subnet0["DMZ"].id
      vpc_security_group_ids = ["${aws_security_group.sg0["central"].id}"]
      associate_public_ip_address = true
      private_ip = "172.22.0.100"
    }
    proxy = {
      ami = "ami-09e513e9eacab10c1"
      key_name = "keypair-haunui-int"
      subnet_id = aws_subnet.subnet0["DMZ"].id
      vpc_security_group_ids = ["${aws_security_group.sg0["central"].id}"]
      associate_public_ip_address = true
      user_data = "scripts/proxy_user_data.txt.template"
      private_ip = "172.22.0.10"
    }
    ldapserver = {
      ami = "ami-09e513e9eacab10c1"
      key_name = "keypair-haunui-int"
      subnet_id = aws_subnet.subnet0["IB"].id
      vpc_security_group_ids = ["${aws_security_group.sg0["central"].id}"]
      associate_public_ip_address = false
      user_data = "scripts/ldapserver_user_data.txt.template"
      private_ip = "172.22.1.20"
    }

    i11 = {
      ami = "ami-09e513e9eacab10c1"
      key_name = "keypair-haunui-int"
      subnet_id = aws_subnet.subnet0["vpc1sub0"].id
      vpc_security_group_ids = ["${aws_security_group.sg0["vpc1"].id}"]
      associate_public_ip_address = false
      user_data = "scripts/ldapclient_vpc1_user_data.txt.template"
      private_ip = "10.0.0.200"
    }
    i21 = {
      ami = "ami-09e513e9eacab10c1"
      key_name = "keypair-haunui-int"
      subnet_id = aws_subnet.subnet0["vpc2sub0"].id
      vpc_security_group_ids = ["${aws_security_group.sg0["vpc2"].id}"]
      associate_public_ip_address = false
      user_data = "scripts/ldapclient_vpc2_user_data.txt.template"
      private_ip = "10.1.0.200"
    }
  }

  drtb = {
    vpc1 = {
      default_route_table_id = aws_vpc.vpc0["vpc1"].default_route_table_id

      routes = [
        {
          cidr_block = "0.0.0.0/0"
          vpc_peering_connection_id = aws_vpc_peering_connection.vpc_pc0["central_vpc1"].id
        }
      ]
    }
    vpc2 = {
      default_route_table_id = aws_vpc.vpc0["vpc2"].default_route_table_id

      routes = [
        {
          cidr_block = "0.0.0.0/0"
          vpc_peering_connection_id = aws_vpc_peering_connection.vpc_pc0["central_vpc2"].id
        }
      ]
    }
  }

  rtb = {
    DMZ = {
      vpc_id = aws_vpc.vpc0["central"].id
      subnet_id = aws_subnet.subnet0["DMZ"].id
    }
    IB = {
      vpc_id = aws_vpc.vpc0["central"].id
      subnet_id = aws_subnet.subnet0["IB"].id
    }
    vpc1sub0 = {
      vpc_id = aws_vpc.vpc0["vpc1"].id
      subnet_id = aws_subnet.subnet0["vpc1sub0"].id
    }
    vpc2sub0 = {
      vpc_id = aws_vpc.vpc0["vpc2"].id
      subnet_id = aws_subnet.subnet0["vpc2sub0"].id
    }
  }
  
  route = {
    DMZ_default = {
      route_table_id = "${aws_route_table.rtb0["DMZ"].id}"
      destination_cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.igw0["igw0"].id}"
    }

    DMZ_vpc1 = {
      route_table_id = "${aws_route_table.rtb0["DMZ"].id}"
      destination_cidr_block = "10.0.0.0/16"
      vpc_peering_connection_id = aws_vpc_peering_connection.vpc_pc0["central_vpc1"].id
    }
    IB_vpc1 = {
      route_table_id = "${aws_route_table.rtb0["IB"].id}"
      destination_cidr_block = "10.0.0.0/16"
      vpc_peering_connection_id = aws_vpc_peering_connection.vpc_pc0["central_vpc1"].id
    }
    DMZ_vpc2 = {
      route_table_id = "${aws_route_table.rtb0["DMZ"].id}"
      destination_cidr_block = "10.1.0.0/16"
      vpc_peering_connection_id = aws_vpc_peering_connection.vpc_pc0["central_vpc2"].id
    }
    IB_vpc2 = {
      route_table_id = "${aws_route_table.rtb0["IB"].id}"
      destination_cidr_block = "10.1.0.0/16"
      vpc_peering_connection_id = aws_vpc_peering_connection.vpc_pc0["central_vpc2"].id
    }

    vpc1sub0_DMZ = {
      route_table_id = "${aws_route_table.rtb0["vpc1sub0"].id}"
      destination_cidr_block = "172.22.0.0/16"
      vpc_peering_connection_id = aws_vpc_peering_connection.vpc_pc0["central_vpc1"].id
    }

    vpc2sub0_DMZ = {
      route_table_id = "${aws_route_table.rtb0["vpc2sub0"].id}"
      destination_cidr_block = "172.22.0.0/16"
      vpc_peering_connection_id = aws_vpc_peering_connection.vpc_pc0["central_vpc2"].id
    }
  }

  eip = {}

  sg = {
    central = {
      description = "central"
      vpc_id = aws_vpc.vpc0["central"].id
    }
    vpc1 = {
      description = "vpc1"
      vpc_id = aws_vpc.vpc0["vpc1"].id
    }
    vpc2 = {
      description = "vpc2"
      vpc_id = aws_vpc.vpc0["vpc2"].id
    }
  }
  sgr = {
    central_i = {
      security_group_id = "${aws_security_group.sg0["central"].id}"
      type = "ingress"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    central_e = {
      security_group_id = "${aws_security_group.sg0["central"].id}"
      type = "egress"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    vpc1_i = {
      security_group_id = "${aws_security_group.sg0["vpc1"].id}"
      type = "ingress"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    vpc1_e = {
      security_group_id = "${aws_security_group.sg0["vpc1"].id}"
      type = "egress"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    vpc2_i = {
      security_group_id = "${aws_security_group.sg0["vpc2"].id}"
      type = "ingress"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    vpc2_e = {
      security_group_id = "${aws_security_group.sg0["vpc2"].id}"
      type = "egress"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  vpc_pc = {
    central_vpc1 = {
      peer_vpc_id = aws_vpc.vpc0["vpc1"].id
      vpc_id = aws_vpc.vpc0["central"].id
    }
    central_vpc2 = {
      peer_vpc_id = aws_vpc.vpc0["vpc2"].id
      vpc_id = aws_vpc.vpc0["central"].id
    }
  }
  nacl = {
    central = {
      vpc_id = aws_vpc.vpc0["central"].id
      subnet_ids = [
        aws_subnet.subnet0["DMZ"].id,
        aws_subnet.subnet0["IB"].id
      ]
    }
    vpc1 = {
      vpc_id = aws_vpc.vpc0["vpc1"].id
      subnet_ids = [
        aws_subnet.subnet0["vpc1sub0"].id
      ]
    }
    vpc2 = {
      vpc_id = aws_vpc.vpc0["vpc2"].id
      subnet_ids = [
        aws_subnet.subnet0["vpc2sub0"].id
      ]
    }
  }
  nacl_rule = {
    central_i = {
      network_acl_id = aws_network_acl.nacl0["central"].id
      rule_number = 300
      protocol = "-1"
      rule_action = "allow"
      cidr_block = "0.0.0.0/0"
      from_port = 0
      to_port = 0
    }
    central_e = {
      network_acl_id = aws_network_acl.nacl0["central"].id
      rule_number = 300
      protocol = "-1"
      rule_action = "allow"
      cidr_block = "0.0.0.0/0"
      egress = true
      from_port = 0
      to_port = 0
    }
    vpc1_i = {
      network_acl_id = aws_network_acl.nacl0["vpc1"].id
      rule_number = 300
      protocol = "-1"
      rule_action = "allow"
      cidr_block = "0.0.0.0/0"
      from_port = 0
      to_port = 0
    }
    vpc1_e = {
      network_acl_id = aws_network_acl.nacl0["vpc1"].id
      rule_number = 300
      protocol = "-1"
      rule_action = "allow"
      cidr_block = "0.0.0.0/0"
      egress = true
      from_port = 0
      to_port = 0
    }
    vpc2_i = {
      network_acl_id = aws_network_acl.nacl0["vpc2"].id
      rule_number = 300
      protocol = "-1"
      rule_action = "allow"
      cidr_block = "0.0.0.0/0"
      from_port = 0
      to_port = 0
    }
    vpc2_e = {
      network_acl_id = aws_network_acl.nacl0["vpc2"].id
      rule_number = 300
      protocol = "-1"
      rule_action = "allow"
      cidr_block = "0.0.0.0/0"
      egress = true
      from_port = 0
      to_port = 0
    }
    central_vpc1_i = {
      network_acl_id = aws_network_acl.nacl0["central"].id
      rule_number = 200
      protocol = "-1"
      rule_action = "allow"
      cidr_block = aws_vpc.vpc0["vpc1"].cidr_block
      from_port = 0
      to_port = 0
    }
    central_vpc1_e = {
      network_acl_id = aws_network_acl.nacl0["central"].id
      rule_number = 200
      protocol = "-1"
      egress = true
      rule_action = "allow"
      cidr_block = aws_vpc.vpc0["vpc1"].cidr_block
      from_port = 0
      to_port = 0
    }
    central_vpc2_i = {
      network_acl_id = aws_network_acl.nacl0["central"].id
      rule_number = 201
      protocol = "-1"
      rule_action = "allow"
      cidr_block = aws_vpc.vpc0["vpc2"].cidr_block
      from_port = 0
      to_port = 0
    }
    central_vpc2_e = {
      network_acl_id = aws_network_acl.nacl0["central"].id
      rule_number = 201
      protocol = "-1"
      egress = true
      rule_action = "allow"
      cidr_block = aws_vpc.vpc0["vpc2"].cidr_block
      from_port = 0
      to_port = 0
    }
    vpc1_central_i = {
      network_acl_id = aws_network_acl.nacl0["vpc1"].id
      rule_number = 200
      protocol = "-1"
      rule_action = "allow"
      cidr_block = aws_vpc.vpc0["central"].cidr_block
      from_port = 0
      to_port = 0
    }
    vpc1_central_e = {
      network_acl_id = aws_network_acl.nacl0["vpc1"].id
      rule_number = 200
      protocol = "-1"
      egress = true
      rule_action = "allow"
      cidr_block = aws_vpc.vpc0["central"].cidr_block
      from_port = 0
      to_port = 0
    }
    vpc2_central_i = {
      network_acl_id = aws_network_acl.nacl0["vpc2"].id
      rule_number = 200
      protocol = "-1"
      rule_action = "allow"
      cidr_block = aws_vpc.vpc0["central"].cidr_block
      from_port = 0
      to_port = 0
    }
    vpc2_central_e = {
      network_acl_id = aws_network_acl.nacl0["vpc2"].id
      rule_number = 200
      protocol = "-1"
      egress = true
      rule_action = "allow"
      cidr_block = aws_vpc.vpc0["central"].cidr_block
      from_port = 0
      to_port = 0
    }
  }
}
