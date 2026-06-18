#############################################
# ECS Cluster
#############################################

resource "aws_ecs_cluster" "main" {

  name = "${var.project_name}-${var.environment}-cluster"


  setting {

    name = "containerInsights"

    value = "enabled"

  }


  tags = {

    Name = "${var.project_name}-${var.environment}-cluster"

    Environment = var.environment

  }

}



#############################################
# Frontend Task Definition
#############################################

resource "aws_ecs_task_definition" "frontend" {

  family = "${var.project_name}-${var.environment}-frontend"


  network_mode = "awsvpc"


  requires_compatibilities = [
    "FARGATE"
  ]


  cpu = 256


  memory = 512


  execution_role_arn = var.execution_role_arn


  task_role_arn = var.task_role_arn



  container_definitions = jsonencode([

    {

      name = "frontend"


      image = var.frontend_image


      essential = true



      portMappings = [

        {

          containerPort = 8080

          hostPort = 8080

          protocol = "tcp"

        }

      ]



      logConfiguration = {


        logDriver = "awslogs"



        options = {

          awslogs-group = var.frontend_log_group_name

          awslogs-region = "us-east-1"

          awslogs-stream-prefix = "frontend"

        }

      }

    }

  ])

}



#############################################
# Backend Task Definition
#############################################

resource "aws_ecs_task_definition" "backend" {


  family = "${var.project_name}-${var.environment}-backend"



  network_mode = "awsvpc"



  requires_compatibilities = [

    "FARGATE"

  ]



  cpu = 256



  memory = 512



  execution_role_arn = var.execution_role_arn



  task_role_arn = var.task_role_arn




  container_definitions = jsonencode([

    {

      name = "backend"



      image = var.backend_image



      essential = true



      portMappings = [

        {

          containerPort = 8080

          hostPort = 8080

          protocol = "tcp"

        }

      ]



      environment = [

        {

          name = "PGHOST"

          value = var.db_endpoint

        }

      ]



      secrets = [

        {

          name = "PGDATABASE"

          valueFrom = "${var.db_secret_arn}:database::"

        },

        {

          name = "PGUSER"

          valueFrom = "${var.db_secret_arn}:username::"

        },

        {

          name = "PGPASSWORD"

          valueFrom = "${var.db_secret_arn}:password::"

        }

      ]



      logConfiguration = {


        logDriver = "awslogs"



        options = {

          awslogs-group = var.backend_log_group_name

          awslogs-region = "us-east-1"

          awslogs-stream-prefix = "backend"

        }

      }

    }

  ])

}





#############################################
# Frontend ECS Service
#############################################

resource "aws_ecs_service" "frontend" {


  name = "${var.project_name}-${var.environment}-frontend-service"



  cluster = aws_ecs_cluster.main.id



  task_definition = aws_ecs_task_definition.frontend.arn



  desired_count = 1



  launch_type = "FARGATE"

  load_balancer {

  target_group_arn = var.frontend_target_group_arn

  container_name = "frontend"

  container_port = 8080

}

  network_configuration {


    subnets = [

      var.private_subnet_a_id,

      var.private_subnet_b_id

    ]



    security_groups = [

      var.frontend_security_group_id

    ]



    assign_public_ip = false

  }



  depends_on = [

    aws_ecs_task_definition.frontend

  ]

}





#############################################
# Backend ECS Service
#############################################

resource "aws_ecs_service" "backend" {



  name = "${var.project_name}-${var.environment}-backend-service"




  cluster = aws_ecs_cluster.main.id




  task_definition = aws_ecs_task_definition.backend.arn




  desired_count = 1




  launch_type = "FARGATE"

   load_balancer {

  target_group_arn = var.backend_target_group_arn

  container_name = "backend"

  container_port = 8080

}


  network_configuration {



    subnets = [

      var.private_subnet_a_id,

      var.private_subnet_b_id

    ]




    security_groups = [

      var.backend_security_group_id

    ]




    assign_public_ip = false

  }




  depends_on = [

    aws_ecs_task_definition.backend

  ]

}
