variable "private_subnet_a_id" {
  type = string
}

variable "private_subnet_b_id" {
  type = string
}


variable "rds_security_group_id" {
  type = string
}


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
