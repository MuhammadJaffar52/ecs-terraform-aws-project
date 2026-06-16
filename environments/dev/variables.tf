variable "vpc_name" {}
variable "vpc_cidr" {}

variable "public_subnet_a_cidr" {}
variable "public_subnet_b_cidr" {}

variable "private_subnet_a_cidr" {}
variable "private_subnet_b_cidr" {}











variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}
