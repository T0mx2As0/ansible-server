# retrive the public subnet so the nat gateway can reach internet
data "aws_subnet" "PublicSub1" {
  tags = {
    Name = "PublicSub1"
  }
}

# This is the NAT gateway's public IP 

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
  subnet_id = data.aws_subnet.PublicSub1.id   # Deve essere pubblica
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

# retrive Bastian Host security group ID
data "aws_security_group" "Bastian_Host_SG" {
  filter {
    name = "tag:Name"
    values = ["Bastion_SG"]
  }
}

resource "aws_security_group" "ansible_SG" {
    tags = {
      Name = "AnsibleSG"
    }
  name = "Ansible Server security group"
  description = "Ansible Server security group"
}

resource "aws_vpc_security_group_ingress_rule" "ansible_SG_ingress1" {
    security_group_id = aws_security_group.ansible_SG.id
    referenced_security_group_id = data.aws_security_group.Bastian_Host_SG.id
    ip_protocol = "tcp"
    to_port = 22
    from_port = 22
}

resource "aws_vpc_security_group_ingress_rule" "ansible_SG_ingress2" {
    security_group_id = aws_security_group.ansible_SG.id
    cidr_ipv4 = join("/",[trimspace(data.http.my_ip.response_body),"32"] )
    ip_protocol = "tcp"
    to_port = 22
    from_port = 22
}

resource "aws_vpc_security_group_egress_rule" "ansible_SG_egress1" {
    security_group_id = aws_security_group.ansible_SG.id
    cidr_ipv4 = data.aws_vpc.vpc.cidr_block
    ip_protocol = "tcp"
    to_port = 22
    from_port = 22
}

resource "aws_vpc_security_group_egress_rule" "ansible_SG_egress2" {
    security_group_id = aws_security_group.ansible_SG.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"
}

resource "aws_instance" "ansibles_server" {
    tags = {
      Name = "Server Ansible"
    }
    ami = data.aws_ssm_parameter.ami.value
    key_name = var.key_name
    instance_type = var.instance_type
    subnet_id = var.PrivateSub
    security_groups = [ aws_security_group.ansible_SG.id ]
    associate_public_ip_address = false
    user_data = file("./modules/ansible/script_ansible.sh")
}