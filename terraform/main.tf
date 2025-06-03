# main.tf

provider "aws" {
  region = "ap-northeast-1"
}

# Lấy danh sách tất cả VPC, chọn VPC đầu tiên (đã có) để tạo Security Group
data "aws_vpcs" "all" {}

# Tìm AMI Amazon Linux 2 mới nhất
data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["amazon"]
}

resource "aws_security_group" "ec2_security_group" {
  name        = "ec2-security-group"
  description = "allow SSH access on port 22"
  vpc_id      = data.aws_vpcs.all.ids[0]

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
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.medium"
  key_name               = "primevideopb"
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]

  tags = {
    Name = "Monitoring_server"
  }
}
