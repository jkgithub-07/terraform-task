# NETWORK ARCHITECTURE

#vpc
resource "aws_vpc" "test_vpc" {
  cidr_block       = "10.0.0.0/16"
  

  tags = {
    Name = "tf_3_tier_vpc"
  }
}

# SUBNETS (2 private and 1 public)
#public
resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.test_vpc.id   # required
  cidr_block = "10.0.1.0/24"         # optional
  availability_zone = "us-east-1a"   # optional 

  tags = {
    Name = "public_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.test_vpc.id   # required
  cidr_block = "10.0.2.0/24"         # optional
  availability_zone = "us-east-1b"   # optional 

  tags = {
    Name = "public_subnet_2"
  }
}

#private(application tier)
resource "aws_subnet" "private_subnet_1a" {
  vpc_id     = aws_vpc.test_vpc.id   # required
  cidr_block = "10.0.3.0/24"         # optional
  availability_zone = "us-east-1a"   # optional 

  tags = {
    Name = "private_subnet_1a"
  }
}

resource "aws_subnet" "private_subnet_1b" {
  vpc_id     = aws_vpc.test_vpc.id   # required
  cidr_block = "10.0.4.0/24"         # optional
  availability_zone = "us-east-1b"   # optional 

  tags = {
    Name = "private_subnet_1b"
  }
}

# private(db tier)
resource "aws_subnet" "private_subnet_2a" {
  vpc_id     = aws_vpc.test_vpc.id   # required
  cidr_block = "10.0.5.0/24"         # optional
  availability_zone = "us-east-1a"   # optional 

  tags = {
    Name = "private_subnet_2a"
  }
}

resource "aws_subnet" "public_subnet_2b" {
  vpc_id     = aws_vpc.test_vpc.id   # required
  cidr_block = "10.0.6.0/24"         # optional
  availability_zone = "us-east-1b"   # optional 

  tags = {
    Name = "private_subnet_2b"
  }
}


# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.test_vpc.id

  tags = {
    Name = "tf-igw"
  }
}

# alternate way of igw setup 
# resource "aws_vpc" "example" {
#   cidr_block = "10.1.0.0/16"
# }

# resource "aws_internet_gateway" "example" {}

# resource "aws_internet_gateway_attachment" "example" {
#   internet_gateway_id = aws_internet_gateway.example.id
#   vpc_id              = aws_vpc.example.id
# }


# ROUTE TABLE
# public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"  
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "tf_public_rt"
  }
}

# associating subnets to route table
resource "aws_route_table_association" "public_rt_association_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id  #required
}

resource "aws_route_table_association" "public_rt_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id  #required
}

# NAT
# public nat with auto mode(regional nat)
resource "aws_nat_gateway" "nat" {
  vpc_id            = aws_vpc.test_vpc.id
  availability_mode = "regional"

  tags = {
    Name = "tf-nat"
  }
}

# private route table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"  
    gateway_id = aws_nat_gateway.nat.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "tf_private_rt"
  }
}

resource "aws_route_table_association" "private_rt_association_1" {
  subnet_id      = aws_subnet.private_subnet_1a.id
  route_table_id = aws_route_table.private_rt.id  #required
}

resource "aws_route_table_association" "private_rt_association_2" {
  subnet_id      = aws_subnet.private_subnet_1b.id
  route_table_id = aws_route_table.private_rt.id  #required
}


## RDS
# db subnet group
resource "aws_db_subnet_group" "tf_db_subnet" {
  name       = "tf_db_subnet_group"
  subnet_ids = [aws_subnet.private_subnet_2a , aws_subnet.public_subnet_2b]

  tags = {
    Name = "tf_db_subnet_group"
  }
}

resource "aws_db_instance" "rds_instance" {
  allocated_storage    = 8
  db_name              = "tf_mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"   # required 
  username             = "admin"
  password             = "database#12345"
  db_subnet_group_name = aws_db_subnet_group.tf_db_subnet.name
  deletion_protection = false 

  tags = {
    Name = "tf_rds"
  }

}

# SECURITY GROUPS (ALB , ASG , RDS)
# ALB 
resource "aws_security_group" "alb_sg" {
  name        = "tf_alb_sg"
  description = "Allow inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.test_vpc.id

  tags = {
    Name = "tf_alb_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_ingress_1" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}


resource "aws_vpc_security_group_egress_rule" "alb_egress" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# ASG
resource "aws_security_group" "asg_sg" {
  name        = "tf_asg_sg"
  description = "Allow inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.test_vpc.id

  tags = {
    Name = "tf_asg_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "asg_ingress_1" {
  security_group_id = aws_security_group.asg_sg.id
  referenced_security_group_id = aws_security_group.alb_sg.id  #  (Optional) Source security group that is referenced in the rule.
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}


resource "aws_vpc_security_group_egress_rule" "asg_egress" {
  security_group_id = aws_security_group.asg_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# RDS
resource "aws_security_group" "rds_sg" {
  name        = "tf_rds_sg"
  description = "Allow inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.test_vpc.id

  tags = {
    Name = "tf_rds_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_ingress_1" {
  security_group_id = aws_security_group.rds_sg.id
  referenced_security_group_id = aws_security_group.asg_sg.id
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}

resource "aws_vpc_security_group_egress_rule" "rds_egress" {
  security_group_id = aws_security_group.rds_sg.id
  referenced_security_group_id = aws_security_group.asg_sg.id
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# ASG
# launch template 
resource "aws_launch_template" "launch_template" {
  name = "tf_lt"

  iam_instance_profile {
    name = "ssm-role-test"
  }

  image_id = "ami-083dedce92603a2ad"

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = "t3.micro"

  monitoring {
    enabled = true
  }

  vpc_security_group_ids = [aws_security_group.asg_sg]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "tf_lt"
    }
  }

  user_data = filebase64("${path.module}/example.sh")
}
