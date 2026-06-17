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
