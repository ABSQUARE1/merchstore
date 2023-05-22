terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
  bucket = "absquare-bucket"
  key    = "aws/terraform/terraform.tfstate"
  region = "us-east-1"
}
}

#Configure the AWS Provider.
provider "aws" {
  region = "us-east-1"
}



# Refer to the template file - install_nginx.sh
data "template_file" "user_data1" {
  template = "${file("install-nginx.sh")}"

}

# Create EC2 Instance - Ubuntu 20.04 for nginx
resource "aws_instance" "my-nginx-server4" {
  ami                    = "ami-0aa2b7722dc1b5612"
  instance_type          = "t2.micro"
  availability_zone      = "us-east-1a"
  key_name               = "memorykeypair"
  vpc_security_group_ids = ["${aws_security_group.my_asg.id}"]
  
  # user_data : render the template
  user_data     = base64encode("${data.template_file.user_data1.rendered}")

  tags = {
    "Name" = "Ubuntu Nginx server 1"
  }
}

# Create EC2 Instance - Ubuntu 20.04 for nginx
# resource "aws_instance" "my-nginx-server5" {
#   ami                    = "ami-0aa2b7722dc1b5612"
#   instance_type          = "t2.micro"
#   availability_zone      = "us-east-1a"
#   key_name               = "memorykeypair"
#   vpc_security_group_ids = ["${aws_security_group.my_asg.id}"]
  
#   # user_data : render the template
#   user_data     = base64encode("${data.template_file.user_data1.rendered}")

#   tags = {
#     "Name" = "Ubuntu Nginx server 2"
#   }
# }


# Create a VPC
resource "aws_vpc" "my_test_vpc1" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    name = "dev"
  }
}

# creating a subnet
resource "aws_subnet" "my_test_vpc1_PublicSubnet1" {
  vpc_id                  = aws_vpc.my_test_vpc1.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "Public Subnet 1"
  }
}
# creating a subnet
resource "aws_subnet" "my_test_vpc1_PublicSubnet2" {
  vpc_id                  = aws_vpc.my_test_vpc1.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "Public Subnet 2"
  }
}


# create internet gateway
resource "aws_internet_gateway" "my_test_vpc1_Internetgateway" {
  vpc_id = aws_vpc.my_test_vpc1.id

  tags = {
    Name = "Gateway"
  }
}
# created a  route table to accept traffic from anywhere on the internet
resource "aws_route_table" "vpc_route" {
  vpc_id = aws_vpc.my_test_vpc1.id

  tags = {
    Name = "public-route"
  }
}

resource "aws_route" "route-inline" {
  route_table_id         = aws_route_table.vpc_route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_test_vpc1_Internetgateway.id

}


resource "aws_security_group" "my_asg" {

  name = "My ASG"
  vpc_id = aws_vpc.my_test_vpc1.id

  # Allow inbound HTTP requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow inbound HTTPS requests
  ingress {
    description = "Allow Port 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH Traffic
  ingress {
    description = "Allow Port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


output "instance-ip" {
  value = aws_instance.my-nginx-server4.public_ip
  sensitive = true
  
}