variable "vpc_name" {
  description = "VPC Name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type        = string
}

variable "public_subnet_a_cidr" {
  description = "Public Subnet A CIDR"
  type        = string
}

variable "public_subnet_b_cidr" {
  description = "Public Subnet B CIDR"
  type        = string
}

variable "private_subnet_a_cidr" {
  description = "Private Subnet A CIDR"
  type        = string
}

variable "private_subnet_b_cidr" {
  description = "Private Subnet B CIDR"
  type        = string
}
