variable "key_name" {
    type = string
}

data "aws_vpc" "vpc" {
    default = true
}

variable "instance_type" {
    type = string
}

data "aws_ssm_parameter" "ami" {
   name = "image-ami"
}

data "http" "my_ip" { # my public IP
  url = "https://ipv4.icanhazip.com"
}

variable "PrivateSub" {
  type = string
}