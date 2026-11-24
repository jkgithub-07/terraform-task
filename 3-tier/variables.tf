##------------- Global Variable ---------------##

variable "region" {
    description = "region for resource deployment"
}

variable "environment" {
    description = "environment for resource deployment"
}

##------------- VPC configuration variables -------------##

variable "vpc_conf" {
    description = "configurations for vpc"
}

##-------------- RDS Configuration Variables --------------##

variable "rds_conf" {
    description = "configurations for rds"
}


# resource "aws_vpc" "vpc" {
#   cidr_block       = var.vpc_conf.cidr_block
#   instance_tenancy = "default"

#   tags = {
#     Name = "dev_vpc"
#   }
# }