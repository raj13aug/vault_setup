provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu-focal-20.04-amd64-server-*"]
  }

}

resource "aws_instance" "linux" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "new-eks"
  tags = {
    Name = "Vault"
  }
  user_data = <<EOF
        #!/bin/bash

        EOF
}


output "public_ip" {
  value = aws_instance.linux.public_ip
}
