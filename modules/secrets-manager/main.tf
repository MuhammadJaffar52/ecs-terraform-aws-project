resource "aws_secretsmanager_secret" "db_secret" {

  name = "ecs-postgres-secret"

  description = "Database credentials for ECS application"


}

resource "aws_secretsmanager_secret_version" "db_secret_version" {

  secret_id = aws_secretsmanager_secret.db_secret.id

  secret_string = jsonencode({

    username = var.db_username

    password = var.db_password

    database = var.db_name


    endpoint = var.db_endpoint

    port = var.db_port

  })

}
