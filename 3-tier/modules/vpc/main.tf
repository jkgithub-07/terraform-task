# NETWORK ARCHITECTURE

#vpc
resource "aws_vpc" "test_vpc" {
  cidr_block       = var.vpc_conf.cidr_block
  

  tags = {
    Name = var.vpc_conf.name
  }
}

# SUBNETS (2 private and 1 public)
#public
resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.test_vpc.id   # required
  cidr_block = var.vpc_conf.public_subnet_cidr_1         # optional
  availability_zone = var.vpc_conf.az1   # optional 

  tags = {
    Name = "${var.vpc_conf.public_subnet_name}_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.test_vpc.id   # required
  cidr_block =  var.vpc_conf.public_subnet_cidr_2        # optional
  availability_zone = var.vpc_conf.az2   # optional 

  tags = {
    Name = "${var.vpc_conf.public_subnet_name}_2"
  }
}

#private(application tier)
resource "aws_subnet" "private_subnet_1a" {
  vpc_id     = aws_vpc.test_vpc.id   # required
  cidr_block = var.vpc_conf.private_subnet_cidr_1         # optional
  availability_zone = var.vpc_conf.az1   # optional 

  tags = {
    Name = "${var.vpc_conf.private_subnet_name}_1a"
  }
}

resource "aws_subnet" "private_subnet_1b" {
  vpc_id     = aws_vpc.test_vpc.id   # required
  cidr_block = var.vpc_conf.private_subnet_cidr_2         # optional
  availability_zone = var.vpc_conf.az2   # optional 

  tags = {
    Name = "${var.vpc_conf.private_subnet_name}_1b"
  }
}

# private(db tier)
resource "aws_subnet" "private_subnet_2a" {
  vpc_id     = aws_vpc.test_vpc.id   # required
  cidr_block = var.vpc_conf.private_subnet_cidr_3        # optional
  availability_zone = var.vpc_conf.az1   # optional 

  tags = {
    Name = "${var.vpc_conf.private_subnet_name}_2a"
  }
}

resource "aws_subnet" "private_subnet_2b" {
  vpc_id     = aws_vpc.test_vpc.id   # required
  cidr_block = var.vpc_conf.private_subnet_cidr_4         # optional
  availability_zone = var.vpc_conf.az2   # optional 

  tags = {
    Name = "${var.vpc_conf.private_subnet_name}_2b"
  }
}


# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.test_vpc.id

  tags = {
    Name = "${var.environment}_igw"
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
    cidr_block = var.vpc_conf.internet_cidr  
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    cidr_block = var.vpc_conf.cidr_block
    gateway_id = var.vpc_conf.local_route_gw_id
  }

  tags = {
    Name = "${var.environment}_public_rt"
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
  availability_mode = var.vpc_conf.nat_availability_mode

  tags = {
    Name = "${var.environment}-nat"
  }
}

# private route table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = var.vpc_conf.internet_cidr  
    gateway_id = aws_nat_gateway.nat.id
  }

  route {
    cidr_block = var.vpc_conf.cidr_block
    gateway_id = var.vpc_conf.local_route_gw_id
  }

  tags = {
    Name = "${var.environment}_private_rt"
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