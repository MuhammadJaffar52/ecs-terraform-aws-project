#################################
# ALB Security Group
#################################

resource "aws_security_group" "alb" {

  name = "ecs-alb-sg"

  description = "Allow HTTP HTTPS traffic"

  vpc_id = var.vpc_id


  ingress {

    description = "HTTP"

    from_port = 80

    to_port = 80

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }


  ingress {

    description = "HTTPS"

    from_port = 443

    to_port = 443

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }


  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }


  tags = {

    Name = "ecs-alb-sg"

  }

}




#################################
# Frontend ECS Security Group
#################################

resource "aws_security_group" "frontend" {


  name = "ecs-frontend-sg"


  description = "Frontend ECS traffic"


  vpc_id = var.vpc_id



  ingress {


    description = "Traffic from ALB"


    from_port = 8080


    to_port = 8080


    protocol = "tcp"


    security_groups = [
      aws_security_group.alb.id
    ]

  }



  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]

  }


  tags = {

    Name = "ecs-frontend-sg"

  }

}




#################################
# Backend ECS Security Group
##################################
# Backend ECS Security Group
#################################
resource "aws_security_group" "backend" {
  name = "ecs-backend-sg"
  description = "Backend API traffic"
  vpc_id = var.vpc_id

  ingress {
    description = "ALB to Backend"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_groups = [
      aws_security_group.alb.id
    ]
  }

  ingress {
    description = "Frontend to Backend"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_groups = [
      aws_security_group.frontend.id
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  tags = {
    Name = "ecs-backend-sg"
  }
}



#################################
# RDS Security Group
#################################

resource "aws_security_group" "rds" {


  name = "ecs-rds-sg"


  description = "Database access"


  vpc_id = var.vpc_id




  ingress {


    description = "PostgreSQL from Backend"


    from_port = 5432


    to_port = 5432


    protocol = "tcp"


    security_groups = [

      aws_security_group.backend.id

    ]

  }




  egress {


    from_port = 0


    to_port = 0


    protocol = "-1"


    cidr_blocks = [

      "0.0.0.0/0"

    ]

  }



  tags = {

    Name = "ecs-rds-sg"

  }

}
