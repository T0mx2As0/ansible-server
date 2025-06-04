output "PrivateRoute" {
  value = aws_route_table.private_route.id
}


output "IP_Priv_ansible" {
  value = aws_instance.ansibles_server.private_ip
}