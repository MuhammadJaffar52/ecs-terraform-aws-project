module "terraform_backend" {

  source = "../backend"

  project_name = "ecs-three-tier"

  environment = "dev"

}
