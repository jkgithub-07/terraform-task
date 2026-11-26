terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}


#VPC 
module "vpc" {
  source = "./modules/vpc"
  vpc_conf = var.vpc_conf
  environment = var.environment
  internet_cidr = var.internet_cidr
  region = var.region
}

#RDS
module "rds" {
  source = "./modules/rds"
  region = var.region
  environment = var.environment
  private_subnet_2a = module.vpc.private_subnet_id_2a
  private_subnet_2b = module.vpc.private_subnet_id_2b
  rds_conf = var.rds_conf
  rds_sg_id = module.security_grp.rds_sg_id
}

# SECURITY GROUP
module "security_grp" {
  source = "./modules/security_grp"
  sg_conf = var.sg_conf
  environment = var.environment
  vpc_id = module.vpc.vpc_id
  internet_cidr = var.internet_cidr
}

# ASG
module "autoscaling_grp"{
  source = "./modules/autoscaling_grp"
  asg_sg_id = module.security_grp.asg_sg_id
  private_subnet_1a = module.vpc.private_subnet_id_1a
  private_subnet_1b = module.vpc.private_subnet_id_1b
  asg_conf = var.asg_conf
  environment = var.environment
  tg_arn = module.alb.alb_tg
}

# ALB
module "alb" {
  source = "./modules/alb"
  public_subnet_1_id = module.vpc.public_subnet_id_1
  public_subnet_2_id = module.vpc.public_subnet_id_2
  vpc_id = module.vpc.vpc_id
  environment = var.environment
  alb_conf = var.alb_conf
  alb_sg_id = module.security_grp.alb_sg_id
}

# # NETWORK ARCHITECTURE

# #vpc
# resource "aws_vpc" "test_vpc" {
#   cidr_block       = var.vpc_conf.cidr_block
  

#   tags = {
#     Name = var.vpc_conf.name
#   }
# }

# # SUBNETS (2 private and 1 public)
# #public
# resource "aws_subnet" "public_subnet_1" {
#   vpc_id     = aws_vpc.test_vpc.id   # required
#   cidr_block = var.vpc_conf.public_subnet_cidr_1         # optional
#   availability_zone = var.vpc_conf.az1   # optional 

#   tags = {
#     Name = "${var.vpc_conf.public_subnet_name}_1"
#   }
# }

# resource "aws_subnet" "public_subnet_2" {
#   vpc_id     = aws_vpc.test_vpc.id   # required
#   cidr_block =  var.vpc_conf.public_subnet_cidr_2        # optional
#   availability_zone = var.vpc_conf.az2   # optional 

#   tags = {
#     Name = "${var.vpc_conf.public_subnet_name}_2"
#   }
# }

# #private(application tier)
# resource "aws_subnet" "private_subnet_1a" {
#   vpc_id     = aws_vpc.test_vpc.id   # required
#   cidr_block = var.vpc_conf.private_subnet_cidr_1         # optional
#   availability_zone = var.vpc_conf.az1   # optional 

#   tags = {
#     Name = "${var.vpc_conf.private_subnet_name}_1a"
#   }
# }

# resource "aws_subnet" "private_subnet_1b" {
#   vpc_id     = aws_vpc.test_vpc.id   # required
#   cidr_block = var.vpc_conf.private_subnet_cidr_2         # optional
#   availability_zone = var.vpc_conf.az2   # optional 

#   tags = {
#     Name = "${var.vpc_conf.private_subnet_name}_1b"
#   }
# }

# # private(db tier)
# resource "aws_subnet" "private_subnet_2a" {
#   vpc_id     = aws_vpc.test_vpc.id   # required
#   cidr_block = var.vpc_conf.private_subnet_cidr_3        # optional
#   availability_zone = var.vpc_conf.az1   # optional 

#   tags = {
#     Name = "${var.vpc_conf.private_subnet_name}_2a"
#   }
# }

# resource "aws_subnet" "private_subnet_2b" {
#   vpc_id     = aws_vpc.test_vpc.id   # required
#   cidr_block = var.vpc_conf.private_subnet_cidr_4         # optional
#   availability_zone = var.vpc_conf.az2   # optional 

#   tags = {
#     Name = "${var.vpc_conf.private_subnet_name}_2b"
#   }
# }


# # IGW
# resource "aws_internet_gateway" "igw" {
#   vpc_id = aws_vpc.test_vpc.id

#   tags = {
#     Name = "${var.environment}_igw"
#   }
# }

# # alternate way of igw setup 
# # resource "aws_vpc" "example" {
# #   cidr_block = "10.1.0.0/16"
# # }

# # resource "aws_internet_gateway" "example" {}

# # resource "aws_internet_gateway_attachment" "example" {
# #   internet_gateway_id = aws_internet_gateway.example.id
# #   vpc_id              = aws_vpc.example.id
# # }


# # ROUTE TABLE
# # public route table
# resource "aws_route_table" "public_rt" {
#   vpc_id = aws_vpc.test_vpc.id

#   route {
#     cidr_block = var.vpc_conf.internet_cidr  
#     gateway_id = aws_internet_gateway.igw.id
#   }

#   route {
#     cidr_block = var.vpc_conf.cidr_block
#     gateway_id = var.vpc_conf.local_route_gw_id
#   }

#   tags = {
#     Name = "${var.environment}_public_rt"
#   }
# }

# # associating subnets to route table
# resource "aws_route_table_association" "public_rt_association_1" {
#   subnet_id      = aws_subnet.public_subnet_1.id
#   route_table_id = aws_route_table.public_rt.id  #required
# }

# resource "aws_route_table_association" "public_rt_association_2" {
#   subnet_id      = aws_subnet.public_subnet_2.id
#   route_table_id = aws_route_table.public_rt.id  #required
# }

# # NAT
# # public nat with auto mode(regional nat)
# resource "aws_nat_gateway" "nat" {
#   vpc_id            = aws_vpc.test_vpc.id
#   availability_mode = var.vpc_conf.nat_availability_mode

#   tags = {
#     Name = "${var.environment}-nat"
#   }
# }

# # private route table
# resource "aws_route_table" "private_rt" {
#   vpc_id = aws_vpc.test_vpc.id

#   route {
#     cidr_block = var.vpc_conf.internet_cidr  
#     gateway_id = aws_nat_gateway.nat.id
#   }

#   route {
#     cidr_block = var.vpc_conf.cidr_block
#     gateway_id = var.vpc_conf.local_route_gw_id
#   }

#   tags = {
#     Name = "${var.environment}_private_rt"
#   }
# }

# resource "aws_route_table_association" "private_rt_association_1" {
#   subnet_id      = aws_subnet.private_subnet_1a.id
#   route_table_id = aws_route_table.private_rt.id  #required
# }

# resource "aws_route_table_association" "private_rt_association_2" {
#   subnet_id      = aws_subnet.private_subnet_1b.id
#   route_table_id = aws_route_table.private_rt.id  #required
# }


# ## RDS
# # db subnet group
# resource "aws_db_subnet_group" "tf_db_subnet" {
#   name       = "${var.environment}_${var.rds_conf.db_subnet_name}"
#   subnet_ids = [aws_subnet.private_subnet_2a.id , aws_subnet.private_subnet_2b.id]

#   tags = {
#     Name = "${var.environment}_${var.rds_conf.db_subnet_name}"
#   }
# }

# resource "aws_db_instance" "rds_instance" {
#   allocated_storage    = var.rds_conf.allocated_storage
#   db_name              = var.rds_conf.db_name
#   engine               = var.rds_conf.engine
#   engine_version       = var.rds_conf.engine_version
#   instance_class       = var.rds_conf.instance_class   # required 
#   username             = var.rds_conf.username
#   password             = var.rds_conf.password
#   db_subnet_group_name = aws_db_subnet_group.tf_db_subnet.name
#   deletion_protection = var.rds_conf.deletion_protection
#   identifier = var.rds_conf.identifier
#   multi_az = var.rds_conf.multi_az
#   vpc_security_group_ids = [ aws_security_group.rds_sg.id ]
#   skip_final_snapshot = var.rds_conf.skip_final_snapshot
  

#   tags = {
#     Name = "${var.environment}_rds"
#   }

# }

# SECURITY GROUPS (ALB , ASG , RDS)
# ALB 
# resource "aws_security_group" "alb_sg" {
#   name        = "${var.environment}_alb_sg"
#   description = var.sg_conf.desc
#   vpc_id      = aws_vpc.test_vpc.id

#   tags = {
#     Name = "${var.environment}_alb_sg_alb_sg"
#   }
# }

# resource "aws_vpc_security_group_ingress_rule" "alb_ingress_1" {
#   security_group_id = aws_security_group.alb_sg.id
#   cidr_ipv4         = var.internet_cidr
#   from_port         = var.sg_conf.alb_from_port
#   ip_protocol       = var.sg_conf.ip_protocol
#   to_port           = var.sg_conf.alb_to_port
# }


# resource "aws_vpc_security_group_egress_rule" "alb_egress" {
#   security_group_id = aws_security_group.alb_sg.id
#   cidr_ipv4         = var.internet_cidr
#   ip_protocol       = var.sg_conf.all_ports # semantically equivalent to all ports
# }

# # ASG
# resource "aws_security_group" "asg_sg" {
#   name        = "${var.environment}_asg_sg"
#   description = var.sg_conf.desc
#   vpc_id      = aws_vpc.test_vpc.id

#   tags = {
#     Name = "${var.environment}_asg_sg"
#   }
# }

# resource "aws_vpc_security_group_ingress_rule" "asg_ingress_1" {
#   security_group_id = aws_security_group.asg_sg.id
#   referenced_security_group_id = aws_security_group.alb_sg.id  #  (Optional) Source security group that is referenced in the rule.
#   from_port         = var.sg_conf.asg_from_port
#   ip_protocol       = var.sg_conf.ip_protocol
#   to_port           = var.sg_conf.asg_to_port
# }


# resource "aws_vpc_security_group_egress_rule" "asg_egress" {
#   security_group_id = aws_security_group.asg_sg.id
#   cidr_ipv4         = var.internet_cidr
#   ip_protocol       = var.sg_conf.all_ports # semantically equivalent to all ports
# }

# # RDS
# resource "aws_security_group" "rds_sg" {
#   name        = "${var.environment}_rds_sg"
#   description = var.sg_conf.desc
#   vpc_id      = aws_vpc.test_vpc.id

#   tags = {
#     Name = "${var.environment}_rds_sg"
#   }
# }

# resource "aws_vpc_security_group_ingress_rule" "rds_ingress_1" {
#   security_group_id = aws_security_group.rds_sg.id
#   referenced_security_group_id = aws_security_group.asg_sg.id
#   from_port         = var.sg_conf.rds_from_port
#   ip_protocol       = var.sg_conf.ip_protocol
#   to_port           = var.sg_conf.rds_to_port
# }

# resource "aws_vpc_security_group_egress_rule" "rds_egress" {
#   security_group_id = aws_security_group.rds_sg.id
#   referenced_security_group_id = aws_security_group.asg_sg.id
#   ip_protocol       = var.sg_conf.all_ports # semantically equivalent to all ports
# }

# #IAM ROLE FOR ASG
# resource "aws_iam_role" "ec2_role"{
#   name = "ec2-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       },
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
#   role       = aws_iam_role.ec2_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

# resource "aws_iam_instance_profile" "ec2_profile" {
#   name = "ec2-instance-profile"
#   role = aws_iam_role.ec2_role.name
# }

# # ASG
# # launch template 
# resource "aws_launch_template" "launch_template" {
#   name = "${var.environment}_lt"

#   iam_instance_profile {
#     name = aws_iam_instance_profile.ec2_profile.name
#   }

#   image_id = var.asg_conf.image_id
#   instance_initiated_shutdown_behavior = var.asg_conf.instance_initiated_shutdown_behavior
#   instance_type = var.asg_conf.instance_type
#   vpc_security_group_ids = [aws_security_group.asg_sg.id]
#   user_data = filebase64("${path.module}/user_data.sh")
# }

# # asg creation 
# resource "aws_autoscaling_group" "tf_asg" {
#   desired_capacity   = var.asg_conf.desired_capacity
#   max_size           = var.asg_conf.max_size
#   min_size           = var.asg_conf.min_size
#   vpc_zone_identifier = [aws_subnet.private_subnet_1a.id, aws_subnet.private_subnet_1b.id]
#   #  Subnets automatically determine which availability zones the group will reside

#   launch_template {
#     id      = aws_launch_template.launch_template.id
#     version = var.asg_conf.launch_template_version
#   }

#   target_group_arns = [ aws_lb_target_group.tg_1.arn ]
# }

# # alb creation
# resource "aws_lb_target_group" "tg_1" {
#   name     = "${var.environment}-tg-1"
#   port     = var.alb_conf.tg_port
#   protocol = var.alb_conf.tg_protocol
#   vpc_id   = aws_vpc.test_vpc.id
# }


# resource "aws_lb" "alb" {
#   name               = "${var.environment}-lb"
#   internal           = var.alb_conf.internal
#   load_balancer_type = var.alb_conf.load_balancer_type
#   security_groups    = [aws_security_group.alb_sg.id]
#   subnets            = [aws_subnet.public_subnet_1.id , aws_subnet.public_subnet_2.id]

#   enable_deletion_protection = var.alb_conf.enable_deletion_protection

# }

# resource "aws_lb_listener" "alb_listener" {
#   load_balancer_arn = aws_lb.alb.arn
#   port              = var.alb_conf.listener_port
#   protocol          = var.alb_conf.listener_protocol

#   default_action {
#     type             = var.alb_conf.listener_default_action_type
#     target_group_arn = aws_lb_target_group.tg_1.arn
#   }
# }

