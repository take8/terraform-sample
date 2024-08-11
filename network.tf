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
