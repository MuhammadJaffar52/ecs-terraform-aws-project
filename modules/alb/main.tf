################################
# Application Load Balancer
################################

resource "aws_lb" "main" {

  name = "${var.project_name}-${var.environment}-alb"

  internal = false

  load_balancer_type = "application"


  security_groups = [
    var.alb_security_group_id
  ]


  subnets = [

    var.public_subnet_a_id,

    var.public_subnet_b_id

  ]


  enable_deletion_protection = false


  tags = {

    Name = "${var.project_name}-${var.environment}-alb"

  }

}




################################
# Frontend Target Group
################################


resource "aws_lb_target_group" "frontend" {


  name = "${var.project_name}-${var.environment}-frontend-tg"


  port = 8080


  protocol = "HTTP"


  vpc_id = var.vpc_id


  target_type = "ip"



  health_check {


    enabled = true


    path = "/"


    port = "8080"


    protocol = "HTTP"


    healthy_threshold = 2


    unhealthy_threshold = 3


    timeout = 5


    interval = 30

  }


}




################################
# Backend Target Group
################################


resource "aws_lb_target_group" "backend" {


  name = "${var.project_name}-${var.environment}-backend-tg"


  port = 8080


  protocol = "HTTP"


  vpc_id = var.vpc_id


  target_type = "ip"

  health_check {

    enabled = true

    path = "/health"

    port = "8080"

    protocol = "HTTP"

    healthy_threshold = 2

    unhealthy_threshold = 3

    timeout = 5

    interval = 30

    matcher = "200"

}



 

}






################################
# Listener
################################


resource "aws_lb_listener" "http" {


  load_balancer_arn = aws_lb.main.arn


  port = 80


  protocol = "HTTP"



  default_action {


    type = "forward"


    target_group_arn = aws_lb_target_group.frontend.arn


  }


}




################################
# Backend Routing Rule
################################


resource "aws_lb_listener_rule" "backend" {


  listener_arn = aws_lb_listener.http.arn


  priority = 10



  condition {


    path_pattern {


      values = [

        "/api/*"

      ]

    }

  }



  action {


    type = "forward"


    target_group_arn = aws_lb_target_group.backend.arn


  }

}
