resource "aws_db_subnet_group" "this" {

  name = "ecs-postgres-subnet-group"

  subnet_ids = [
    var.private_subnet_a_id,
    var.private_subnet_b_id
  ]


  tags = {
    Name = "ecs-postgres-subnet-group"
  }

}
resource "aws_db_instance" "postgres" {

  identifier = "ecs-postgres-db"


  engine = "postgres"

  engine_version = "16"


  instance_class = "db.t3.micro"


  allocated_storage = 20


  db_name  = var.db_name
  username = var.db_username
  password = var.db_password


  db_subnet_group_name = aws_db_subnet_group.this.name


  vpc_security_group_ids = [
    var.rds_security_group_id
  ]


  publicly_accessible = false


  storage_encrypted = true


  backup_retention_period = 7


  skip_final_snapshot = true


  tags = {

    Name = "ecs-postgres-db"

  }

}
