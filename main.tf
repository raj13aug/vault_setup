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
  user_data              = file("vault_script.sh")
  vpc_security_group_ids = [aws_security_group.ec2.id]  
  key_name      = "new-eks"
  tags = {
    Name = "Vault"
  }
  user_data = <<EOF
        #!/bin/bash
        set -e
        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
        apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
        apt update
        apt install vault -y
EOF
}


data "aws_route53_zone" "selected" {
  name         = "robofarming.link"
  private_zone = false
}

resource "aws_route53_record" "domainName" {
  name    = "vault"
  type    = "A"
  zone_id = data.aws_route53_zone.selected.zone_id
  records = [aws_instance.linux.public_ip]
  ttl     = 300
  depends_on = [
    aws_instance.linux
  ]
}