#IAM ROLE FOR ASG
resource "aws_iam_role" "ec2_role"{
  name = "ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = var.asg_conf.policy_arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = var.asg_conf.instance_profile_name
  role = aws_iam_role.ec2_role.name
}

# ASG
# launch template 
resource "aws_launch_template" "launch_template" {
  name = "${var.environment}_lt"

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  image_id = var.asg_conf.image_id
  instance_initiated_shutdown_behavior = var.asg_conf.instance_initiated_shutdown_behavior
  instance_type = var.asg_conf.instance_type
  vpc_security_group_ids = [var.asg_sg_id]
  user_data = filebase64("${path.module}/user_data.sh")
}

# asg creation 
resource "aws_autoscaling_group" "tf_asg" {
  desired_capacity   = var.asg_conf.desired_capacity
  max_size           = var.asg_conf.max_size
  min_size           = var.asg_conf.min_size
  vpc_zone_identifier = [ var.private_subnet_1a, var.private_subnet_1b]
  #  Subnets automatically determine which availability zones the group will reside

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = var.asg_conf.launch_template_version
  }

  target_group_arns = [ var.tg_arn ]
}