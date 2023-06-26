#Create VPC for the instance.
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "My VPC"
  }
}
#Create two public subnets that need to be further initialised to the auto-scaling group as a multi-subnet initialization.
resource "aws_subnet" "public_subnet_1a" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "Public Subnet ap-south-1a"
  }
}

resource "aws_subnet" "public_subnet_1b" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "Public Subnet ap-south-1b"
  }
}

#Create internet gateway and declare the configurations.
resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "My VPC Internet Gateway"
  }
}
#Create Route table to define all the configurations for routing.
resource "aws_route_table" "my_vpc_public" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_vpc_igw.id
  }

  tags = {
    Name = "Public Subnets Route Table for My VPC"
  }
}

resource "aws_route_table_association" "my_vpc_us_east_1a_public" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.my_vpc_public.id
}

resource "aws_route_table_association" "my_vpc_us_east_1b_public" {
  subnet_id      = aws_subnet.public_subnet_1b.id
  route_table_id = aws_route_table.my_vpc_public.id
}

#Create a security group to define and allow SSH, HTTP and egress traffic to the instance.
resource "aws_security_group" "web_server" {
  name   = "web_server"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Auto Scaling
/* 
resource "aws_launch_configuration" "web_server_as" {
  image_id        = "ami-005f9685cb30f234b"
  instance_type  = "t2.micro"
  security_groups = [aws_security_group.web_server.name]

  user_data = <<-EOF
              #!/bin/bash
              echo "<html><body><h1>Welcome back I am Sathiya Mohan G</h1></body></html>" > index.html
              nohup python -m SimpleHTTPServer 80 &
              EOF
}

resource "aws_autoscaling_group" "web_server_asg" {
  name                 = "web-server-asg"
  launch_configuration = aws_launch_configuration.web_server_as.name
  min_size             = 1
  max_size             = 3
  desired_capacity     = 2
  health_check_type    = "EC2"
  #load_balancers       = [aws_elb.web_server_lb.name]
  vpc_zone_identifier  = [aws_subnet.public_subnet_1a.id, aws_subnet.public_subnet_1b.id]
} */