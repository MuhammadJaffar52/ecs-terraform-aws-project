variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}


variable "private_subnet_a_id" {
  type = string
}


variable "private_subnet_b_id" {
  type = string
}


variable "frontend_security_group_id" {
  type = string
}


variable "backend_security_group_id" {
  type = string
}


variable "frontend_image" {
  type = string
}


variable "backend_image" {
  type = string
}


variable "execution_role_arn" {
  type = string
}


variable "task_role_arn" {
  type = string
}


variable "frontend_log_group_name" {
  type = string
}


variable "backend_log_group_name" {
  type = string
}


variable "db_secret_arn" {
  type = string
}


variable "db_endpoint" {
  type = string
}


variable "frontend_target_group_arn" {

  type = string

}


variable "backend_target_group_arn" {

  type = string

}
