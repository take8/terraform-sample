resource "aws_vpc" "sd_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "sd_subnet_a" {
  vpc_id                  = aws_vpc.sd_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sd_subnet_c" {
  vpc_id                  = aws_vpc.sd_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "sd_igw" {
  vpc_id = aws_vpc.sd_vpc.id
}

# ルートテーブル
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.sd_vpc.id

  # tags = {
  #   Name = var.resource_name
  # }
}

# ルートテーブルのエントリ
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.sd_igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# サブネットとルートテーブルの関連付け
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.sd_subnet_a.id
  route_table_id = aws_route_table.public.id
}

# SSHログインのための公開鍵を登録
resource "aws_key_pair" "administrator" {
  key_name   = "sd-staging-administrator"
  public_key = "ssh-rsa SOMETHINGHRE administrator@sd.local"

  tags = local.tags
}

# SSHログインのためのセキュリティグループを登録
resource "aws_security_group" "ssh" {
  name   = "sd-staging-ssh"
  vpc_id = aws_vpc.sd_vpc.id

  tags = local.tags
}
resource "aws_security_group_rule" "ssh_egress" {
  security_group_id = aws_security_group.ssh.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "all"
}
resource "aws_security_group_rule" "ssh_ingress" {
  security_group_id = aws_security_group.ssh.id
  type              = "ingress"
  # cidr_blocks       = ["153.240.3.128/32", "52.194.115.181/32", "52.198.25.184/32", "52.197.224.235/32"]
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
}

# Webサーバーとして2台のインスタンスを構築
resource "aws_instance" "web_1" {
  ami                    = "ami-0b9593848b0f1934e" # AL2023 x86
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.administrator.key_name
  vpc_security_group_ids = [aws_security_group.ssh.id]
  subnet_id              = aws_subnet.sd_subnet_a.id
  monitoring             = true
  root_block_device {
    volume_type = "gp3"
    volume_size = "20"
  }

  tags = local.tags
}
resource "aws_instance" "web_2" {
  ami                    = "ami-0b9593848b0f1934e" # AL2023 x86
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.administrator.key_name
  vpc_security_group_ids = [aws_security_group.ssh.id]
  subnet_id              = aws_subnet.sd_subnet_c.id
  monitoring             = true
  root_block_device {
    volume_type = "gp3"
    volume_size = "20"
  }

  tags = local.tags
}

# それぞれのEC2インスタンスにEIPを設定
resource "aws_eip" "web_1" {
  instance = aws_instance.web_1.id
  domain   = "vpc"

  tags = local.tags
}
resource "aws_eip" "web_2" {
  instance = aws_instance.web_2.id
  domain   = "vpc"

  tags = local.tags
}

locals {
  tags = {
    "project"     = "sd"
    "environment" = "staging"
    "terraform"   = true
  }
}
