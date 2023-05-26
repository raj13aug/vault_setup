provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu-*-20.04-*"]
  }

}

resource "aws_instance" "linux" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  user_data              = file("vault_script.sh")
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = "new-eks"
  tags = {
    Name = "Vault"
  }
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