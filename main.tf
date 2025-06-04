data "aws_vpc" "vpc" {
    default = true
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
  route_table_id = module.Ansible.PrivateRoute
}

module "Ansible" {
    source = "./modules/ansible"

    key_name = var.key_name
    instance_type = var.instance_type
    PrivateSub = aws_subnet.PrivateSub.id
}