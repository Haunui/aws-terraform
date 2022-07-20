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
      connectivity_type = "private"
      subnet_id = aws_subnet.subnet0["subnet0"].id
    }
  }
  ni = {
    ni0sub0 = {
      subnet_id = aws_subnet.subnet0["subnet0"].id
    }
    ni0sub1 = {
      subnet_id = aws_subnet.subnet0["subnet1"].id
    }
  }
  instance = {
    instance0 = {
      ami = "ami-0f5094faf16f004eb"
      key_name = "keypair-haunui"
      network_interface = [
        {
          network_interface_id = aws_network_interface.ni0["ni0sub0"].id
          device_index = 0
        }
      ]
    }
    instance1 = {
      ami = "ami-0f5094faf16f004eb"
      key_name = "keypair-haunui"
      network_interface = [
        {
          network_interface_id = aws_network_interface.ni0["ni0sub1"].id
          device_index = 0
        }
      ]
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
}
