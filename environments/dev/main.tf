module "vpc" {
  source = "../../modules/vpc"

  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr

  public_subnet_a_cidr = var.public_subnet_a_cidr
  public_subnet_b_cidr = var.public_subnet_b_cidr

  private_subnet_a_cidr = var.private_subnet_a_cidr
  private_subnet_b_cidr = var.private_subnet_b_cidr


}

module "security" {

  source = "../../modules/security"


  vpc_id = module.vpc.vpc_id

}

module "rds" {

  source = "../../modules/rds"


  private_subnet_a_id = module.vpc.private_subnet_a_id

  private_subnet_b_id = module.vpc.private_subnet_b_id


  rds_security_group_id = module.security.rds_sg_id


  db_name = var.db_name

  db_username = var.db_username

  db_password = var.db_password

}


module "secrets_manager" {

  source = "../../modules/secrets-manager"

  db_name = var.db_name

  db_username = var.db_username

  db_password = var.db_password

  db_endpoint = module.rds.db_endpoint

  db_port = module.rds.db_port

}


module "ecr" {
  source = "../../modules/ecr"

  project_name = var.project_name
  environment  = var.environment
}

module "iam" {

  source = "../../modules/iam"

  project_name = var.project_name

  environment = var.environment


}

module "cloudwatch" {

  source = "../../modules/cloudwatch"


  project_name = var.project_name

  environment = var.environment

}


module "ecs" {

  source = "../../modules/ecs"


  project_name = var.project_name

  environment = var.environment


  private_subnet_a_id = module.vpc.private_subnet_a_id

  private_subnet_b_id = module.vpc.private_subnet_b_id



  frontend_security_group_id = module.security.frontend_sg_id

  backend_security_group_id = module.security.backend_sg_id



  frontend_image = module.ecr.frontend_repository_url

  backend_image = module.ecr.backend_repository_url



  execution_role_arn = module.iam.execution_role_arn

  task_role_arn = module.iam.task_role_arn



  frontend_log_group_name = module.cloudwatch.frontend_log_group_name

  backend_log_group_name = module.cloudwatch.backend_log_group_name



  db_secret_arn = module.secrets_manager.secret_arn

  db_endpoint = module.rds.db_endpoint

}
