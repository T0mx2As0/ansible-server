# retrive Bastian Host security group
data "aws_security_groups" "Bastian_Host_SG" {
  filter {
    name = "tag:Name"
    values = ["BastionSG"]
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
    referenced_security_group_id = data.aws_security_groups.Bastian_Host_SG.id
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

resource "aws_instance" "ansibles_server" {
    tags = {
      Name = "Server Ansible"
    }
    ami = data.aws_ssm_parameter.ami.value
    key_name = var.key_name
    instance_type = var.instance_type
    subnet_id = data.aws_subnet.PublicSub1.id
    security_groups = [ aws_security_group.ansible_SG.id ]
    associate_public_ip_address = false
}