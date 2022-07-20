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
  }
}

variable "vpc" {
  type = any
  default = {
    vpc0 = {
      cidr_block = "10.0.0.0/16"
    }
  }
}

locals {
  subnet = {
    subnet0 = {
      vpc_id = aws_vpc.vpc0["vpc0"].id
      cidr_block = "10.0.1.0/24"
    }
    subnet1 = {
      vpc_id = aws_vpc.vpc0["vpc0"].id
      cidr_block = "10.0.2.0/24"
    }
  }
  igw = {
    igw0 = {
      vpc_id = aws_vpc.vpc0["vpc0"].id
    }
  }
  nat = {
    nat0 = {
      connectivity_type = "public"
      subnet_id = aws_subnet.subnet0["subnet0"].id
      allocation_id = aws_eip.eip0["eip0"].id
    }
  }
  instance = {
    instance0 = {
      ami = "ami-09e513e9eacab10c1"
      key_name = "keypair-haunui"
      subnet_id = aws_subnet.subnet0["subnet0"].id
      vpc_security_group_ids = ["${aws_security_group.sg0["sg0"].id}"]
      associate_public_ip_address = true
    }
    instance1 = {
      ami = "ami-09e513e9eacab10c1"
      key_name = "keypair-haunui"
      subnet_id = aws_subnet.subnet0["subnet1"].id
      vpc_security_group_ids = ["${aws_security_group.sg0["sg1"].id}"]
      associate_public_ip_address = false
    }
  }

  rtb = {
    rtb0 = {
      vpc_id = aws_vpc.vpc0["vpc0"].id
      subnet_id = aws_subnet.subnet0["subnet1"].id
    }
  }
  
  route = {
    route0 = {
      route_table_id = "${aws_vpc.vpc0["vpc0"].default_route_table_id}"
      destination_cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.igw0["igw0"].id}"
    }
    route1 = {
      route_table_id = "${aws_route_table.rtb0["rtb0"].id}"
      destination_cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_nat_gateway.nat0["nat0"].id}"
    }
  }
  eip = {
    eip0 = {
      instance = aws_instance.instance0["instance0"].id
      vpc = true
    }
  }
  sg = {
    sg0 = {
      description = "public_subnet"
      vpc_id = aws_vpc.vpc0["vpc0"].id
    }
    sg1 = {
      description = "private_subnet"
      vpc_id = aws_vpc.vpc0["vpc0"].id
    }
  }
  sgr = {
    sg0r0 = {
      security_group_id = "${aws_security_group.sg0["sg0"].id}"
      type = "ingress"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    sg0r1 = {
      security_group_id = "${aws_security_group.sg0["sg0"].id}"
      type = "egress"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    sg1r0 = {
      security_group_id = "${aws_security_group.sg0["sg1"].id}"
      type = "ingress"
      from_port = 0
      to_port = 0
      protocol = "-1"
      source_security_group_id = "${aws_security_group.sg0["sg0"].id}"
    }
    sg1r1 = {
      security_group_id = "${aws_security_group.sg0["sg1"].id}"
      type = "egress"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
