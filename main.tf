# SSHログインのための公開鍵を登録
resource "aws_key_pair" "administrator" {
  key_name   = "sd-staging-administrator"
  public_key = "ssh-rsa SOMETHINGHRE administrator@sd.local"
  tags       = local.tags
}

# SSHログインのためのセキュリティグループを登録
resource "aws_security_group" "ssh" {
  name   = "sd-staging-ssh"
  vpc_id = "vpc-0fca7c8fbb8d07c5b"
  tags   = local.tags
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
  cidr_blocks       = ["153.240.3.128/32", "52.194.115.181/32", "52.198.25.184/32", "52.197.224.235/32"]
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}

# Webサーバーとして2台のインスタンスを構築
resource "aws_instance" "web_1" {
  ami                    = "ami-0b9593848b0f1934e" # AL2023 x86
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.administrator.key_name
  vpc_security_group_ids = [aws_security_group.ssh.id]
  subnet_id              = "subnet-05a36e44b59902960"
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
  subnet_id              = "subnet-038fecec7ae366e20"
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
  tags     = local.tags
}
resource "aws_eip" "web_2" {
  instance = aws_instance.web_2.id
  domain   = "vpc"
  tags     = local.tags
}

locals {
  tags = {
    "project"     = "sd"
    "environment" = "staging"
    "terraform"   = true
  }
}
