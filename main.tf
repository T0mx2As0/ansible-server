data "aws_vpc" "vpc" {
    default = true
}

resource "aws_eip" "Elastic_IP" {
  domain = "vpc"
  tags = {
    Name = "My_Elastic_IP"
  }
}
# set nat gateway to allow ansible server to navigate

resource "aws_nat_gateway" "NATGW" {
  tags = {
    Name = "NAT GW"
  }
  connectivity_type = "public"
  allocation_id     = aws_eip.Elastic_IP.id
  subnet_id = data.aws_subnet.private_sub.id
}

resource "aws_route_table" "private_route" {
  vpc_id = data.aws_vpc.vpc.id
  tags = {
     Name = "PrivateRouteTable"
  }
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATGW.id
  }
}
resource "aws_subnet" "PrivateSub" {
  tags  = {
    Name = "PrivateSub1"
  }
  vpc_id = data.aws_vpc.vpc.id
  cidr_block = "172.31.0.0/20"
}

resource "aws_route_table_association" "PrivateRoute" {
  subnet_id = aws_subnet.PrivateSub.id
  route_table_id = aws_route_table.private_route.id
}

module "Ansible" {
    source = "./modules/ansible"

    key_name = var.key_name
    instance_type = var.instance_type
}