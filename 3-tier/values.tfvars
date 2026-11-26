region = "us-east-1"
environment = "dev-tf"
internet_cidr = "0.0.0.0/0"

vpc_conf = {
    cidr_block = "10.0.0.0/16"
    name = "tf_3_tier_vpc"

    public_subnet_cidr_1 = "10.0.1.0/24"
    public_subnet_cidr_2 = "10.0.2.0/24"
    private_subnet_cidr_1 = "10.0.3.0/24"
    private_subnet_cidr_2 = "10.0.4.0/24"
    private_subnet_cidr_3 = "10.0.5.0/24"
    private_subnet_cidr_4 = "10.0.6.0/24"

    az1 = "us-east-1a"
    az2 = "us-east-1b"
    public_subnet_name = "public_subnet"
    private_subnet_name = "private_subnet"

    igw_name = "tf_igw"

    internet_cidr = "0.0.0.0/0"
    local_route_gw_id = "local"

    nat_availability_mode = "regional"
    

}

rds_conf = {
    db_subnet_name = "subnet_db_grp"

    allocated_storage    = 8
    db_name              = "tf_mydb"
    engine               = "mysql"
    engine_version       = "8.0"
    instance_class       = "db.t3.micro"   # required 
    username             = "admin"
    password             = "database#12345"
    deletion_protection = false
    identifier = "tf-rds"
    multi_az = false
    skip_final_snapshot = true

}

sg_conf = {
    
    desc = "Allow inbound traffic and all outbound traffic"
    alb_from_port = 80
    alb_to_port = 80
    ip_protocol = "tcp"
    all_ports = "-1"

    asg_from_port = 80
    asg_to_port = 80

    rds_from_port = 3306
    rds_to_port =3306
}

asg_conf = {
    image_id = "ami-0aacbf72109c53c0c"
    instance_initiated_shutdown_behavior = "terminate"
    instance_type = "t3.micro"
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    instance_profile_name = "ec2-ssm-role-profile-tf"

    desired_capacity   = 1
    max_size           = 1
    min_size           = 1

    launch_template_version = "$Latest"
}

alb_conf = {
    tg_port = 80
    tg_protocol = "HTTP"
    internal           = false
    load_balancer_type = "application"
    enable_deletion_protection = false

    listener_port = "80"
    listener_protocol = "HTTP"
    listener_default_action_type = "forward"

}