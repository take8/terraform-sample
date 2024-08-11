# SSHログインのための公開鍵を登録
resource "aws_key_pair" "administrator" {
  key_name   = local.key_name
  public_key = tls_private_key.keygen.public_key_openssh

  tags = local.tags
}

# SSHログインのためのセキュリティグループを登録
resource "aws_security_group" "ssh" {
  name   = format("%s-%s-ssh", var.project_name, var.environment)
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
  # cidr_blocks       = var.allowed_ips
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
}

# Webサーバーとして2台のインスタンスを構築
resource "aws_instance" "web" {
  count = 2

  ami                    = "ami-0b9593848b0f1934e" # AL2023 x86
  instance_type          = var.instance_type
  key_name               = aws_key_pair.administrator.key_name
  vpc_security_group_ids = [aws_security_group.ssh.id]
  subnet_id              = element([aws_subnet.sd_subnet_a.id, aws_subnet.sd_subnet_c.id], count.index)
  monitoring             = true

  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
  }

  tags = local.tags
}

# それぞれのEC2インスタンスにEIPを設定
resource "aws_eip" "web" {
  count = 2

  instance = element(aws_instance.web.*.id, count.index)
  domain   = "vpc"

  tags = local.tags
}

locals {
  tags = {
    "project"     = var.project_name
    "environment" = var.environment
    "terraform"   = true
  }
}
