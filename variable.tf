variable "project_name" {
  type    = string
  default = "sd"
}
variable "environment" {
  type    = string
  default = "staging"
}

variable "office_ips" {
  type = map(string)
  default = {
    "tokyo" = "153.240.3.128/32"
    "osaka" = "52.194.115.181/32"
  }
}

variable "vpn_ips" {
  type = map(string)
  default = {
    "tokyo" = "52.198.25.184/32"
    "osaka" = "52.197.224.235/32"
  }
}

variable "instance_type" {
  default = "t2.micro"
}
variable "root_volume_type" {
  default = "gp3"
}
variable "root_volume_size" {
  default = "20"
}
