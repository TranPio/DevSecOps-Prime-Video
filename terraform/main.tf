provider "aws" {
  region = "ap-northeast-1"
}

data "aws_vpc" "devsecops" {
  id = "vpc-0a528a03289f58f60"
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.devsecops.id]
  }
  filter {
    name   = "tag:Name"
    values = ["DevSecOps-Project-subnet-public*"]
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  owners = ["amazon"]
}

resource "aws_security_group" "ec2_security_group" {
  name        = "ec2-security-group"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.devsecops.id

  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
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
  subnet_id              = data.aws_subnets.public.ids[0]
  key_name               = "primevideopb"
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]

  tags = {
    Name = "Monitoring_server"
  }
}
