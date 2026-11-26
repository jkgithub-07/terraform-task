# GLOBAL VARIABLES



variable "environment" {
    description = "environment for resource deployment"
}

variable "internet_cidr"{
    description = "internet cidr"
}

#SG VARIABLES
variable "sg_conf" {
  description = "configuration for security groups"
}

variable "vpc_id"{
    description = "vpc id"
}