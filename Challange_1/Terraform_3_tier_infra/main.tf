/*
Create a Dynamodb Table where Application will write the data
*/
resource "aws_dynamodb_table" "dyanmodb_table" {
  name         = "application_dynamodb_table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Request_ID"
  range_key    = "Time_Stamp"

  attribute {
    name = "Request_ID"
    type = "S"
  }

  attribute {
    name = "Time_Stamp"
    type = "S"
  }

  tags = {
    Name        = "application_dynamodb_table"
    Environment = "dev"
  }
}

/*
Create Application Instance Launch Configuration
*/

data "aws_ami" "application_ami" {
  provider = "aws.infra"
  filter {
    name   = "name"
    values = ["application-ami-tier3"]
  }
  owners = [var.account_number]
}
/*
Public Subnet
*/
data "aws_subnet" "public_subnet" {
  filter {
    name   = "name"
    values = ["public-subnet"]
  }
}

/*
Private Subnet
*/
data "aws_subnet" "private_subnet" {
  filter {
    name   = "name"
    values = ["private-subnet"]
  }
}

/*
Considering an Application Security group already available
where it allows inbound traffic on port 80 from Load Balancer Security group
*/
data "aws_security_group" "application_security_group" {
  provider = "aws.infra"
  filter {
    name   = "name"
    values = ["application-tier3"]
  }
}

/*
Considering an ELB Security group already available
where it allows inbound traffic on port 443 from Public and allow outbound traffic on port 80 towards
application security group
*/
data "aws_security_group" "elb_security_group" {
  provider = "aws.infra"
  filter {
    name   = "name"
    values = ["elb-application-tier3"]
  }
}

/*
Get the ACM ID from the account to attach to ELB
*/
data "aws_acm_certificate" "application_certificate" {
  domain = "application_tier3.example.com"
}

resource "aws_launch_configuration" "application_launch_config" {
  name            = "application_tier3"
  image_id        = data.aws_ami.application_ami.id
  instance_type   = "t2.micro"
  security_groups = [data.aws_security_group.application_security_group.id]
}

resource "aws_autoscaling_group" "application_asg" {
  name                 = "application_tier3"
  launch_configuration = aws_launch_configuration.application_launch_config.name
  availability_zones   = ["eu-east-1a", "eu-east-1b", "eu-east-1c"]
  vpc_zone_identifier  = [data.aws_subnet.public_subnet.id]

  load_balancers = [aws_elb.application_elb.id]
  min_size       = 3
  max_size       = 3

  depends_on = [aws_dynamodb_table.dyanmodb_table] // Create Auto Scaling Group only after Dynamodb is created

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "application_elb" {
  name               = "application_tier3"
  availability_zones = ["eu-east-1a", "eu-east-1b", "eu-east-1c"]
  security_groups    = [data.aws_security_group.elb_security_group.id]
  subnets            = [data.aws_subnet.public_subnet]
  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = data.aws_acm_certificate.application_certificate.id
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "application_tier3"
  }
}

