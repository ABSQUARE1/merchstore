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
  template = file("./install-nginx.sh")

}

# Create EC2 Instance - Ubuntu 20.04 for nginx
resource "aws_instance" "my-nginx-server4" {
  ami                    = "ami-0aa2b7722dc1b5612"
  instance_type          = "t2.micro"
  availability_zone      = "us-east-1a"
  key_name               = "memorykeypair"
  vpc_security_group_ids = [aws_security_group.my_asg.id]
  
  # user_data : render the template
  user_data     = base64encode("${data.template_file.user_data1.rendered}")

  tags = {
    "Name" = "Ubuntu Nginx server 1"
  }
}




resource "aws_security_group" "my_asg" {

  name = "My ASsG"

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