output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_a_id" {
  value = module.vpc.public_subnet_a_id
}

output "public_subnet_b_id" {
  value = module.vpc.public_subnet_b_id
}

output "private_subnet_a_id" {
  value = module.vpc.private_subnet_a_id
}

output "private_subnet_b_id" {
  value = module.vpc.private_subnet_b_id
}

output "frontend_repository_url" {
  value = module.ecr.frontend_repository_url
}

output "backend_repository_url" {
  value = module.ecr.backend_repository_url
}
output "ecs_execution_role_arn" {

  value = module.iam.execution_role_arn

}


output "ecs_task_role_arn" {

  value = module.iam.task_role_arn

}
output "frontend_log_group_name" {

  value = module.cloudwatch.frontend_log_group_name

}


output "backend_log_group_name" {

  value = module.cloudwatch.backend_log_group_name


}


output "alb_dns_name" {

  value = module.alb.alb_dns_name

}


output "frontend_target_group_arn" {

  value = module.alb.frontend_target_group_arn

}


output "backend_target_group_arn" {

  value = module.alb.backend_target_group_arn

}
