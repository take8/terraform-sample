variable "project_name" {
  type    = string
  default = "sd"
}
variable "environment" {
  type    = string
  default = "staging"
}

variable "allowed_ips" {
  default = ["153.240.3.128/32", "52.194.115.181/32", "52.198.25.184/32", "52.197.224.235/32"]
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
