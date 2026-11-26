# GLOBAL VARIABLES

variable "region"{
    description = "region for resource deployment"
}

variable "environment" {
    description = "environment for resource deployment"
}

variable "private_subnet_2a"{
    description = "db subnet"
}
variable "private_subnet_2b"{
    description = "db subnet"
}

variable "rds_conf" {
  description = "rds configuration"
}

variable "rds_sg_id"{
    description = "rds security group"
}