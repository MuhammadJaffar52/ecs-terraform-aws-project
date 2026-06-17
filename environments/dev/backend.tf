terraform {
  backend "s3" {

    bucket = "ecs-three-tier-dev-terraform-state"

    key = "ecs-three-tier/dev/terraform.tfstate"

    region = "us-east-1"

    dynamodb_table = "ecs-three-tier-dev-terraform-lock"

    encrypt = true
  }
}
