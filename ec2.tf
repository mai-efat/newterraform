
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}



resource "aws_instance" "myec2" {
  ami                        = "ami-0658158d7ba8fd573"
  instance_type              = "t3.micro"
  subnet_id                  = aws_subnet.public.id
  security_groups            = [aws_security_group.allow_all.id]
  associate_public_ip_address = true
  key_name                   = "key1"
  
  tags = {
    Name = "ec2-created-from-terraform"
  }

  # Ignore changes to specific attributes
  lifecycle {
    ignore_changes = [
      ami,               # Ignore changes to AMI
      instance_type,     # Ignore changes to instance type
      security_groups,   # Ignore changes to security groups
      subnet_id,         # Ignore changes to subnet
    ]
  }

  # Local-exec provisioner to create an inventory.ini file with EC2 IP
  provisioner "local-exec" {
    command = "echo ${aws_instance.myec2.public_ip}>> inventory.ini"
  }
}


resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow inbound SSH and HTTP traffic"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from anywhere
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTPS from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}
output "ec2_public_ip" {
  value = aws_instance.myec2.public_ip
  description = "The public IP address of the EC2 instance"
}