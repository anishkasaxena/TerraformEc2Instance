# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = "access_key"
  secret_key = "secret_key"
}

# Include VPC configuration from vpc.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.58.0"

    }
  }
}


module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "single-instance"
  ami = "ami-04a81a99f5ec58529"

  instance_type          = "t2.xlarge"
  key_name               = "tf-ec2-key-pair"
  associate_public_ip_address = true

  monitoring             = true
#   vpc_security_group_ids = [aws_security_group.ec2_instance_sg.id]
  #subnet_id              = aws_subnet.my-public-subnet-1.id
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y openjdk-11-jdk
              wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
              sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
              sudo apt-get update -y
              sudo apt-get install -y jenkins
              sudo systemctl start jenkins
              sudo systemctl enable jenkins
            EOF

}
resource "aws_security_group" "ec2_instance_sg" {
  name        = "ec2_sg"
  description = "Allow HTTP and Jenkins traffic"

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

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
output "instance_id" {
    value = module.ec2_instance.id
  
}
output "public_ip" {
  value = module.ec2_instance.public_ip
}

output "public_dns" {
  value = module.ec2_instance.public_dns
}