## RDS
# db subnet group
resource "aws_db_subnet_group" "tf_db_subnet" {
  name       = "${var.environment}_${var.rds_conf.db_subnet_name}"
  subnet_ids = [var.private_subnet_2a , var.private_subnet_2b]

  tags = {
    Name = "${var.environment}_${var.rds_conf.db_subnet_name}"
  }
}

resource "aws_db_instance" "rds_instance" {
  allocated_storage    = var.rds_conf.allocated_storage
  db_name              = var.rds_conf.db_name
  engine               = var.rds_conf.engine
  engine_version       = var.rds_conf.engine_version
  instance_class       = var.rds_conf.instance_class   # required 
  username             = var.rds_conf.username
  password             = var.rds_conf.password
  db_subnet_group_name = aws_db_subnet_group.tf_db_subnet.name
  deletion_protection = var.rds_conf.deletion_protection
  identifier = var.rds_conf.identifier
  multi_az = var.rds_conf.multi_az
  vpc_security_group_ids = [ var.rds_sg_id ]
  skip_final_snapshot = var.rds_conf.skip_final_snapshot
  

  tags = {
    Name = "${var.environment}_rds"
  }

}