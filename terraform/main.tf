terraform {
  required_providers {
    aws = "~> 4.0"
  }
}

provider "aws" {
  region = "us-west-2"
}

data "aws_key_pair" "web_key_pair" {
  key_name           = "test_key"
  include_public_key = true

  filter {
    name   = "tag:Name"
    values = ["test_key"]
  }
}

resource "aws_instance" "web" {
  ami                         = var.web_ami
  instance_type               = var.instance_type
  key_name                    = data.aws_key_pair.web_key_pair.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.web_sec_sg.id]

  tags = {
    Name = "${var.environment}-web"
  }
}

resource "aws_security_group" "web_sec_sg" {
  name        = "${var.environment}-web-sec-grp"
  description = "WebServer Security Group"
  tags = {
    Name = "${var.environment}-web-sec-grp"
  }

  ingress {
    description = "HTTP (80)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH (22)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ansible_controller" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = data.aws_key_pair.web_key_pair.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.web_sec_sg.id]

  tags = {
    Name = "${var.environment}-ansible"
  }

  depends_on = [
    aws_instance.web
  ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("../ansible/test_key.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install -y epel",
      "sudo yum install -y ansible",
      "ansible --version "
    ]
  }
  provisioner "file" {
    source      = "../ansible"
    destination = "/home/ec2-user/"
  }
  provisioner "remote-exec" {
    inline = [
      "cd /home/ec2-user/ansible",
      "sudo chmod 400 test_key.pem",
      "ansible-playbook playbook.yaml -i inventory --private-key=test_key.pem"
    ]
  }
}