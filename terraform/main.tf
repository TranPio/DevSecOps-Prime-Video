# main.tf

provider "aws" {
  region = "ap-northeast-1"
  # AWS_ACCESS_KEY_ID và AWS_SECRET_ACCESS_KEY sẽ tự lấy từ biến môi trường
}

# Lấy danh sách tất cả VPC trong region, rồi chọn phần tử đầu tiên
data "aws_vpcs" "all" {}

resource "aws_security_group" "ec2_security_group" {
  name        = "ec2-security-group"
  description = "allow SSH access on port 22"
  # Dùng VPC đầu tiên tìm được (thay thế cho default VPC)
  vpc_id = data.aws_vpcs.all.ids[0]

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Monitoring_server_security_group"
  }
}

resource "aws_instance" "Monitoring_server" {
  ami                    = "ami-00bb6a80f01f03502"
  instance_type          = "t2.medium"
  key_name               = "primevideopb"
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]

  tags = {
    Name = "Monitoring_server"
  }
}
