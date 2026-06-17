#############################################
# ECS Assume Role Policy
#############################################

data "aws_iam_policy_document" "ecs_assume_role" {

  statement {

    effect = "Allow"

    principals {

      type = "Service"

      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]

    }

    actions = [
      "sts:AssumeRole"
    ]

  }

}


#############################################
# ECS Task Execution Role
#############################################

resource "aws_iam_role" "ecs_task_execution_role" {

  name = "${var.project_name}-${var.environment}-ecs-task-execution-role"

  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json


  tags = {

    Name = "${var.project_name}-${var.environment}-ecs-task-execution-role"

    Environment = var.environment

  }

}


#############################################
# Attach AWS Managed ECS Execution Policy
#############################################

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {

  role = aws_iam_role.ecs_task_execution_role.name


  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

}



#############################################
# ECS Task Role
#############################################

resource "aws_iam_role" "ecs_task_role" {

  name = "${var.project_name}-${var.environment}-ecs-task-role"


  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json


  tags = {

    Name = "${var.project_name}-${var.environment}-ecs-task-role"

    Environment = var.environment

  }

}



#############################################
# Secrets Manager Access Policy
#############################################

resource "aws_iam_policy" "secrets_access" {


  name = "${var.project_name}-${var.environment}-secrets-manager-access"


  description = "Allow ECS tasks to read application secrets"



  policy = jsonencode({

    Version = "2012-10-17"


    Statement = [

      {

        Effect = "Allow"


        Action = [

          "secretsmanager:GetSecretValue"

        ]


        Resource = "*"

      }

    ]

  })


}



#############################################
# Attach Secrets Policy To Execution Role
#############################################

resource "aws_iam_role_policy_attachment" "secrets_attachment" {


  role = aws_iam_role.ecs_task_execution_role.name


  policy_arn = aws_iam_policy.secrets_access.arn


}
