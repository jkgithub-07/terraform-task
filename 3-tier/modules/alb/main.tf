# alb creation
resource "aws_lb_target_group" "tg_1" {
  name     = "${var.environment}-tg-1"
  port     = var.alb_conf.tg_port
  protocol = var.alb_conf.tg_protocol
  vpc_id   = var.vpc_id
}


resource "aws_lb" "alb" {
  name               = "${var.environment}-lb"
  internal           = var.alb_conf.internal
  load_balancer_type = var.alb_conf.load_balancer_type
  security_groups    = [var.alb_sg_id]
  subnets            = [var.public_subnet_1_id , var.public_subnet_2_id]

  enable_deletion_protection = var.alb_conf.enable_deletion_protection

}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.alb_conf.listener_port
  protocol          = var.alb_conf.listener_protocol

  default_action {
    type             = var.alb_conf.listener_default_action_type
    target_group_arn = aws_lb_target_group.tg_1.arn
  }
}

