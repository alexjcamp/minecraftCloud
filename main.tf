terraform {
  backend "s3" {
    bucket = "alex100minecraft"
    key    = "path/key"
    region = "us-west-2"
  }
}

provider "aws" {
  profile = "alex"
  region  = "us-west-2"
}

data "aws_ami" "linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_efs_file_system" "minecraftData" {
  creation_token = "minecraftData"
}

resource "aws_security_group" "minecraftsg" {
  name        = "Minecraftsg"
  description = "Allow minecraftport"
  ingress {
    description = "Minecraft rule"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["108.172.92.217/32"]
  }
  ingress {
    description = "EFS mount target"
    from_port   = 2049
    to_port     = 2049
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

resource "aws_efs_mount_target" "efs" {
  file_system_id  = aws_efs_file_system.minecraftData.id
  security_groups = [aws_security_group.minecraftsg.id]
  subnet_id       = "subnet-badc60e7"
}

data "template_file" "script" {
  template = file("script.tpl")
  vars = {
    efs_id = "${aws_efs_file_system.minecraftData.id}"
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.linux.id
  instance_type = "t3.medium"

  tags = {
    Name = "minecraftv1"
  }

  security_groups = [aws_security_group.minecraftsg.name]
  key_name        = "test"
  user_data       = data.template_file.script.rendered
}

resource "aws_eip" "minecraftIP" {
  instance = aws_instance.web.id
  vpc      = true
}

