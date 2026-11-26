

variable "environment" {
    description = "environment for resource deployment"
}

#ASG VARIABLES
variable "asg_conf" {
  description = "autoscaling group variables"
}

variable "private_subnet_1a"{
    description = "private subnet id"
}

variable "private_subnet_1b"{
    description = "private subnet id"
}

variable "tg_arn"{
    description = "target group arn to attach in asg"
}

variable "asg_sg_id"{
    description = "security group to add in asg"
}