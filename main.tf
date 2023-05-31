provider "aws" {
  region = "us-east-1"
}


# create a Linux EC2 instance

resource "aws_instance" "linux" {
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t2.micro"
  user_data              = file("vault_script.sh")
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = "new-eks"
  tags = {
    Name = "Vault"
  }
}

# provide information about entities

data "aws_route53_zone" "selected" {
  name         = "robofarming.link"
  private_zone = false
}

#  create Route53 table record 

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