terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}


/* resource "aws_instance" "web" {
  ami           = "ami-057752b3f1d6c4d6c"
  instance_type = "t2.micro"
  key_name = "act1"

  tags = {
    Name = "HelloWorld"
  }
} */

/* resource "aws_eip" "lb" {
  instance = aws_instance.web.id
} */

#creating mumbai resources

resource "aws_vpc" "demo-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "mumbai-VPC"
  }
}

#creating the mumbai subnet resources

resource "aws_subnet" "mumbai-subnet-1a" {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Mumbai-subnet-1a"
  }
}

resource "aws_subnet" "mumbai-subnet-1b" {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Mumbai-subnet-1b"
  }
}

resource "aws_subnet" "mumbai-subnet-1c" {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1c"

  tags = {
    Name = "Mumbai-subnet-1c"
  }
}

#creatingt the ec2 instance 

resource "aws_instance" "mumbai-instance" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"
  key_name = aws_key_pair.mumbai-keypair.id
  subnet_id = aws_subnet.mumbai-subnet-1a.id
  associate_public_ip_address  = "true"
  vpc_security_group_ids = [aws_security_group.mumbai_SG_allow_ssh_http.id]


  tags = {
    Name = "terraform-mumbai"
  }
}


resource "aws_instance" "mumbai-instance-2" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"
  key_name = aws_key_pair.mumbai-keypair.id
  subnet_id = aws_subnet.mumbai-subnet-1a.id
  associate_public_ip_address  = "true"
  vpc_security_group_ids = [aws_security_group.mumbai_SG_allow_ssh_http.id]


  tags = {
    Name = "terraform-mumbai-2"
  }
}

#creating the key-pair

resource "aws_key_pair" "mumbai-keypair" {
  key_name   = "mumbai-26-june"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCaJMRtaZ2a8S38eMWtNf4DJiNqwHT7HRlU8wNOZsZb2+ieHruOZ6UbnHC/gXU/nmXJSuEtcJUZbGgsnVWLQzX86iSzHAKNqYz5JuILyg/9LPJTf0wc3tJK77GD/0lhausJ1uB3UFgZACi5xqfPzj+0pvmmJ+2GjMEO441vugcPoaIbkawlprSW62XaNW6aXy6Z4YNAEHRXnAdJyG66eB93oyEwK1IrWlzO6RkxKOJYXjyurj88fN1aEnpZ6eah1JHZAuxehACGkOhEUHQ+mN4QU/0zjn0sNFLK1lEOXVP2vJ/ryWaRIAfIdqsUZ7CfTDjrXcR1BUvKFBBU93idhS+6JILGDggfcaloE9lu/ZvdWZsWSr8LJrVynhnw7bExC1LlvU4/jgMJ8KNnh5jmJ6N0IfjP96zLcx1q7YgHSg+nN56XCEy1vLr95/X4eCE6oFe+a5ixFQkpYfjHiYMm64tBiMyBMhGw75jBDgWuu+NKUWmkznzmLoRXByS03dgWKOE= ksree@LAPTOP-O0D3TLAS"
}


# creating the security group

resource "aws_security_group" "mumbai_SG_allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = aws_vpc.demo-vpc.id

  ingress {
    description      = "SSH from PC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP from PC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

# creating internet Gateway

resource "aws_internet_gateway" "mumbai_GW" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = {
    Name = "mumbai-IG"
  }
}

# creating the route table 

resource "aws_route_table" "mumbai-RT" {
  vpc_id = aws_vpc.demo-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mumbai_GW.id
  }


  tags = {
    Name = "mumbai-RT"
  }
}


resource "aws_route_table_association" "mumbai-RT-association-1" {
  subnet_id      = aws_subnet.mumbai-subnet-1a.id
  route_table_id = aws_route_table.mumbai-RT.id
}

resource "aws_route_table_association" "mumbai-RT-assocaition-2" {
  subnet_id      = aws_subnet.mumbai-subnet-1b.id
  route_table_id = aws_route_table.mumbai-RT.id
}

# creating target group

resource "aws_lb_target_group" "mumbai-TG" {
  name     = "cardwebsite-terraform"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.demo-vpc.id
}

resource "aws_lb_target_group_attachment" "mumbai-TG-attachment-1" {
  target_group_arn = aws_lb_target_group.mumbai-TG.arn
  target_id        = aws_instance.mumbai-instance.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "mumbai-TG-attachment-2" {
  target_group_arn = aws_lb_target_group.mumbai-TG.arn
  target_id        = aws_instance.mumbai-instance-2.id
  port             = 80
}

# creating load balancer listener

resource "aws_lb_listener" "mumbai-listener" {
  load_balancer_arn = aws_lb.mumbai-load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mumbai-TG.arn
  }
}


resource "aws_lb" "mumbai-load_balancer" {
  name               = "cardwebsite-LB-terraform"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mumbai_SG_allow_ssh_http.id]
  subnets            = [aws_subnet.mumbai-subnet-1b.id, aws_subnet.mumbai-subnet-1a.id]


  tags = {
    Environment = "production"
  }
}

# creating launch template

resource "aws_launch_template" "mumbai-RT" {
  name = "mumbai-RT"


  image_id = "ami-0f5ee92e2d63afc18"

  instance_type = "t2.micro"

  key_name = aws_key_pair.mumbai-keypair.id


  monitoring {
    enabled = true
  }

  placement {
    availability_zone = "us-west-2a"
  }

  vpc_security_group_ids = [aws_security_group.mumbai_SG_allow_ssh_http.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "mumbai-template-ASG"
    }
  }

  user_data = filebase64("userdata.sh")
}


resource "aws_autoscaling_group" "mumbai-ASG" {
  vpc_zone_identifier = [aws_subnet.mumbai-subnet-1a.id,aws_subnet.mumbai-subnet-1b.id]
  desired_capacity   = 2
  max_size           = 5
  min_size           = 2

  launch_template {
    id      = aws_launch_template.mumbai-RT.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.mumbai-TG-1.arn]
}

# ALB TG with ASG

resource "aws_lb_target_group" "mumbai-TG-1" {
  name     = "Mumbai-TG-1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.demo-vpc.id 
}

# LB Listener with ASG

resource "aws_lb_listener" "mumbai-listener-1" {
  load_balancer_arn = aws_lb.mumbai-LB-1.arn
  port              = "80"
  protocol          = "HTTP"
 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mumbai-TG-1.arn
  }
}


#load balancer with ASG

resource "aws_lb" "mumbai-LB-1" {
  name               = "Mumbai-LB-1"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mumbai_SG_allow_ssh_http.id]
  subnets            = [aws_subnet.mumbai-subnet-1b.id, aws_subnet.mumbai-subnet-1a.id]


  tags = {
    Environment = "production"
  }
}
