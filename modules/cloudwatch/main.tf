#############################################
# Frontend ECS Log Group
#############################################

resource "aws_cloudwatch_log_group" "frontend" {

  name = "/ecs/${var.project_name}-${var.environment}/frontend"


  retention_in_days = 30


  tags = {

    Name = "${var.project_name}-${var.environment}-frontend-logs"

    Environment = var.environment

  }

}



#############################################
# Backend ECS Log Group
#############################################

resource "aws_cloudwatch_log_group" "backend" {

  name = "/ecs/${var.project_name}-${var.environment}/backend"


  retention_in_days = 30


  tags = {

    Name = "${var.project_name}-${var.environment}-backend-logs"

    Environment = var.environment

  }

}
