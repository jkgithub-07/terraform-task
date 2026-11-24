# GLOBAL VARIABLES

variable "region"{
    description = "region for resource deployment"
}

variable "environment" {
    description = "environment for resource deployment"
}

variable "internet_cidr"{
    description = "internet cidr"
}

# VPC VARIABLES
variable "vpc_conf" {
    description = "configurations for vpc"
}

# RDS VARIABLES
variable "rds_conf" {
    description = "configurations for rds"
}

#SG VARIABLES
variable "sg_conf" {
  description = "configuration for security groups"
}

#ASG VARIABLES
variable "asg_conf" {
  description = "autoscaling group variables"
}

#ALB VARIABLES
variable "alb_conf" {
  description = "alb configurations"
}
