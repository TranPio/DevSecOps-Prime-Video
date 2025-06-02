# main.tf

provider "aws" {
  region = "ap-northeast-1"
}

# Lấy VPC mặc định. Nếu tài khoản không có Default VPC, bạn phải biết VPC ID thủ công
data "aws_vpc" "default" {
  default = true
}

# Security Group sử dụng VPC ID lấy từ data source ở trên
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2-security-group"
  description = "allow access on port 22"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "SSH from anywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    description      = "All outbound"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Monitoring_server_security_group"
  }
}

# EC2 instance sử dụng Security Group ở trên
resource "aws_instance" "Monitoring_server" {
  ami                    = "ami-00bb6a80f01f03502"
  instance_type          = "t2.medium"
  key_name               = "primevideopb"
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]

  tags = {
    Name = "Monitoring_server"
  }
}
