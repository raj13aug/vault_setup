provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "linux" {
  ami                    = data.aws_ami.linux.image_id
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["sg-id1", "sg-id2", "sg-id3"]
  subnet_id              = "subnet-id"
  key_name               = "new-eks"
  tags = {
    Name = "instance_name"
  }
  user_data = <<EOF
        #!/bin/bash

        EOF
}

output "public_dns" {
  value = aws_instance.linux.*.public_dns
}
output "public_ip" {
  value = aws_instance.linux.*.public_ip
}
output "name" {
  value = aws_instance.linux.*.tags.Name
}