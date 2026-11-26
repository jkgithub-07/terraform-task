# SECURITY GROUPS (ALB , ASG , RDS)
# ALB 
resource "aws_security_group" "alb_sg" {
  name        = "${var.environment}_alb_sg"
  description = var.sg_conf.desc
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.environment}_alb_sg_alb_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_ingress_1" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = var.internet_cidr
  from_port         = var.sg_conf.alb_from_port
  ip_protocol       = var.sg_conf.ip_protocol
  to_port           = var.sg_conf.alb_to_port
}


resource "aws_vpc_security_group_egress_rule" "alb_egress" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = var.internet_cidr
  ip_protocol       = var.sg_conf.all_ports # semantically equivalent to all ports
}

# ASG
resource "aws_security_group" "asg_sg" {
  name        = "${var.environment}_asg_sg"
  description = var.sg_conf.desc
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.environment}_asg_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "asg_ingress_1" {
  security_group_id = aws_security_group.asg_sg.id
  referenced_security_group_id = aws_security_group.alb_sg.id  #  (Optional) Source security group that is referenced in the rule.
  from_port         = var.sg_conf.asg_from_port
  ip_protocol       = var.sg_conf.ip_protocol
  to_port           = var.sg_conf.asg_to_port
}


resource "aws_vpc_security_group_egress_rule" "asg_egress" {
  security_group_id = aws_security_group.asg_sg.id
  cidr_ipv4         = var.internet_cidr
  ip_protocol       = var.sg_conf.all_ports # semantically equivalent to all ports
}

# RDS
resource "aws_security_group" "rds_sg" {
  name        = "${var.environment}_rds_sg"
  description = var.sg_conf.desc
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.environment}_rds_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_ingress_1" {
  security_group_id = aws_security_group.rds_sg.id
  referenced_security_group_id = aws_security_group.asg_sg.id
  from_port         = var.sg_conf.rds_from_port
  ip_protocol       = var.sg_conf.ip_protocol
  to_port           = var.sg_conf.rds_to_port
}

resource "aws_vpc_security_group_egress_rule" "rds_egress" {
  security_group_id = aws_security_group.rds_sg.id
  referenced_security_group_id = aws_security_group.asg_sg.id
  ip_protocol       = var.sg_conf.all_ports # semantically equivalent to all ports
}