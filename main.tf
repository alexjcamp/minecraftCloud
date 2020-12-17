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


resource "aws_instance" "web" {
  ami           = data.aws_ami.linux.id
  instance_type = "t2.micro"

  tags = {
    Name = "minecraftv1"
  }
}

resource "aws_eip" "minecraftIP" {
  instance = aws_instance.web.id
  vpc      = true
}

