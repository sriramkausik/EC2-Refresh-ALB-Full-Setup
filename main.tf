//Author Sriram and KiranRaj

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    } 
  }
}


provider "aws" {
  region = "us-east-1"
  access_key = var.AccessKeyID
  secret_key = var.SecretAccessKey
}

resource "aws_key_pair" "tf-key-pair" {
key_name = "tf-key-pair"
public_key = tls_private_key.rsa.public_key_openssh
}
resource "tls_private_key" "rsa" {
algorithm = "RSA"
rsa_bits  = 4096
}
resource "local_file" "tf-key" {
content  = tls_private_key.rsa.private_key_pem
filename = "tf-key-pair"
}

resource "aws_vpc" "VPCFROMTF" {
  cidr_block = "10.0.0.0/16" 
  tags = {
        Name = "TFVPC"
  }
}

  resource "aws_subnet" "SUBNETONEFROMTF" {
    cidr_block = var.Subnet1
    availability_zone = "us-east-1a" 
    vpc_id= aws_vpc.VPCFROMTF.id
  tags = {
        Name = "TFSUBNET1a"
  }
    
  }
resource "aws_subnet" "SUBNETFROMTF" {
  cidr_block = var.Subnet
  availability_zone = "us-east-1b" 
  vpc_id= aws_vpc.VPCFROMTF.id
  tags = {
        Name = "TFSUBNET1b"
  }
  
}

resource "aws_internet_gateway" "IGWFROMTF" {
  #Name="IGWFROMTF"
  vpc_id = aws_vpc.VPCFROMTF.id

  tags = {
    "name" = "TFIGW"
  }
  
}


//Create a IAM role with 3 policy attached.


resource "aws_iam_role" "ec2-ssm-role" {
name = "EC2SSMROLE"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
}
EOF

}


resource "aws_iam_role_policy_attachment" "AmazonSSMFullAccess" {
  role       = aws_iam_role.ec2-ssm-role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_role_policy_attachment" "AmazonSSMDirectoryServiceAccess" {
  role       = aws_iam_role.ec2-ssm-role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess"
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.ec2-ssm-role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2-ssm-role1" {
  name = "ec2-ssm-role1"
  role = aws_iam_role.ec2-ssm-role.name
}



//SG group :

resource "aws_security_group" "allow_full" {
  name        = "allow_full"
  description = "Full open"
  vpc_id      = aws_vpc.VPCFROMTF.id

  ingress {
    description      = "allow_full"
    from_port        = 0
    to_port          = 0
    protocol         = -1
      cidr_blocks      = ["0.0.0.0/0"]
  }
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

    tags = {
    Name = "allow_All"
  }
}



resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.VPCFROMTF.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGWFROMTF.id
  }

  tags = {
    Name = "RT"
  }
}


resource "aws_route_table_association" "RTA" {
  subnet_id      = aws_subnet.SUBNETFROMTF.id
  route_table_id = aws_route_table.RT.id
}

resource "aws_route_table_association" "RTA1" {
  subnet_id      = aws_subnet.SUBNETONEFROMTF.id
  route_table_id = aws_route_table.RT.id
}


resource "aws_instance" "instanceGreen" {
  count = var.Green_count
  ami = var.Green_WebServer-AMID
    subnet_id = aws_subnet.SUBNETFROMTF.id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.ec2-ssm-role1.name
  key_name = "tf-key-pair"
      user_data = <<-EOF
    #!/bin/bash
    # Use this for your user data (script from top to bottom)
    # install httpd (Linux 2 version)
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello World from Green</h1>" > /var/www/html/index.html
  EOF

  
  tags ={
  Name="Green-${count.index}"
}
}

resource "aws_instance" "instanceBlue" {
  count = var.Blue_count
  ami = var.Blue_WebServer-AMID
  subnet_id = aws_subnet.SUBNETFROMTF.id
  instance_type = "t2.micro"
   iam_instance_profile = aws_iam_instance_profile.ec2-ssm-role1.name  
   associate_public_ip_address = true
  key_name = "tf-key-pair"
      user_data = <<-EOF
    #!/bin/bash
    # Use this for your user data (script from top to bottom)
    # install httpd (Linux 2 version)
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello World from Blue</h1>" > /var/www/html/index.html
  EOF

  
  tags ={
  Name="Blue-${count.index}"
}
}


//31-0ct-2023 //ALB,TG,Listener

resource "aws_lb_target_group" "my_app_eg1" {
  name       = "my-app-eg1"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = aws_vpc.VPCFROMTF.id
  slow_start = 0

  load_balancing_algorithm_type = "round_robin"

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }

  health_check {
    enabled             = true
    port                = 80
    interval            = 30
    protocol            = "HTTP"
    path                = "/health"
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}


resource "aws_lb_target_group" "my_app_eg2" {
  name       = "my-app-eg2"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = aws_vpc.VPCFROMTF.id
  slow_start = 0

  load_balancing_algorithm_type = "round_robin"

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }

  health_check {
    enabled             = true
    port                = 80
    interval            = 30
    protocol            = "HTTP"
    path                = "/health"
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}


resource "aws_lb_target_group_attachment" "TargetgroupAttachmentGreen" {
   count = var.Green_count
   target_id = aws_instance.instanceGreen[count.index].id
   target_group_arn = aws_lb_target_group.my_app_eg2.arn
   port             = 80
}

resource "aws_lb_target_group_attachment" "TargetgroupAttachmentBlue" {
  count = var.Blue_count
  target_id = aws_instance.instanceBlue[count.index].id
   target_group_arn = aws_lb_target_group.my_app_eg1.arn
  port             = 80
}


resource "aws_lb" "ALB" {
  name               = "ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_full.id]



  subnets = [
    aws_subnet.SUBNETONEFROMTF.id,
    aws_subnet.SUBNETFROMTF.id
  ]
}


resource "aws_lb_listener" "ALBLISTEN" {
  load_balancer_arn = aws_lb.ALB.arn
  port              = "80"
  protocol          = "HTTP"

default_action   {
  type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.my_app_eg1.arn
        weight = var.Swing_percentage_Blue
      }

      target_group {
        arn    = aws_lb_target_group.my_app_eg2.arn
        weight = var.Swing_percentage_Green
      }

      stickiness {
        enabled  = false
        duration = 1
      }
    }
  }
}

resource "aws_network_interface_sg_attachment" "sg_attachment_Green" {
  count= var.Green_count
  security_group_id    = aws_security_group.allow_full.id
  network_interface_id = aws_instance.instanceGreen[count.index].primary_network_interface_id
}

resource "aws_network_interface_sg_attachment" "sg_attachment_Blue" {
  count= var.Blue_count
  security_group_id    = aws_security_group.allow_full.id
  network_interface_id = aws_instance.instanceBlue[count.index].primary_network_interface_id
}
