

# 1) Khai báo provider AWS
provider "aws" {
  region = "ap-northeast-1"
}



data "aws_vpc" "devsecops" {
  id = "vpc-0a528a03289f58f60"
}


# 3) Lấy danh sách Subnet “public” trong VPC đó (lọc theo tag:Name chứa "DevSecOps-Project-subnet-public*")
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [ data.aws_vpc.devsecops.id ]
  }
  filter {
    name   = "tag:Name"
    values = [ "DevSecOps-Project-subnet-public*" ]
  }
}


# 4) Lấy AMI Amazon Linux 2 mới nhất (ami-hvm-*-x86_64-gp2) do Amazon phát hành
data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  owners = ["amazon"]
}


# 5) Tạo Security Group trong VPC đó
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2-security-group"
  description = "Allow SSH (22) & HTTP (80) from anywhere"
  vpc_id      = data.aws_vpc.devsecops.id

  # Cho phép SSH từ 0.0.0.0/0 (mọi nơi)
  ingress {
    description = "SSH từ mọi nơi"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Cho phép HTTP (port 80) từ 0.0.0.0/0 (nếu bạn muốn mở cổng web)
  ingress {
    description = "HTTP từ mọi nơi"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Cho phép tất cả outbound
  egress {
    description = "Tất cả outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Monitoring_server_security_group"
  }
}


# 6) Tạo EC2 Instance trong public subnet đầu tiên (nếu có nhiều public subnet, nó sẽ chọn index 0)
resource "aws_instance" "Monitoring_server" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.medium"
  subnet_id              = data.aws_subnets.public.ids[0]         # Chọn subnet public
  key_name               = "primevideopb"                         # Phải tồn tại trong region này
  vpc_security_group_ids = [ aws_security_group.ec2_security_group.id ]

  tags = {
    Name = "Monitoring_server"
  }
}
