output "public_ip" {
  value = "Your EC2 IP is : ${aws_instance.Monitoring_server.public_ip}"
}
