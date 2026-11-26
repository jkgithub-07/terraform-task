variable "vpc_id"{
    description = "vpc id"
}
#ALB VARIABLES
variable "alb_conf" {
  description = "alb configurations"
}

variable "environment" {
    description = "environment for resource deployment"
}

variable "alb_sg_id"{
    description = "load balancer sg"
}

variable "public_subnet_1_id"{
    description = "public subnet id"
}

variable "public_subnet_2_id"{
    description = "public subnet id"
}