provider "aws" {
  region = "ap-south-1"
  profile = "mayank"
}

resource "aws_iam_role" "ssm_role" {
  name = "ec2_ssm_custom_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com",
        },
        Action = "sts:AssumeRole",
      },
    ],
  }
  
  )
}

resource "aws_iam_role_policy_attachment" "ssm_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "s3_ssm_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}


data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]  # This is the AWS account ID for Amazon-owned AMI
}


resource "aws_instance" "ssm_instance" {
  ami           = data.aws_ami.latest_amazon_linux.id  # Update with the appropriate AMI for your region
  instance_type = "t2.micro"
  subnet_id     = "subnet-44f0e02c"  # Specify your subnet ID here

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name = "SSM-Managed-Instance"
  }
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm_instance_profile"
  role = aws_iam_role.ssm_role.name
}


resource "aws_security_group" "ssm_sg" {
  name        = "ssm_sg"
  description = "Security group for SSM-managed instance"
  vpc_id      = "vpc-a1759eca"  # Specify your VPC ID here

  # SSM requires these ports to be open
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SSM-Security-Group"
  }
}


resource "aws_network_interface_sg_attachment" "ssm_sg_attachment" {
  security_group_id    = aws_security_group.ssm_sg.id
  network_interface_id = aws_instance.ssm_instance.primary_network_interface_id
}


output "instance_public_ip" {
  value = aws_instance.ssm_instance.public_ip
}

output "instance_id" {
  value = aws_instance.ssm_instance.id
}

