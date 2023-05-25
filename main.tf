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
        set -e
        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
        apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
        apt update
        apt install vault -y
        
        cat /dev/null > /etc/vault.d/vault.conf
        
        sudo tee -a /etc/vault.d/vault.conf >/dev/null 
        ui = true

        storage "file" {
        path = "/opt/vault/data"
        }

        # HTTPS listener
        listener "tcp" {
        address = "0.0.0.0:8200"
        tls_cert_file = "/opt/vault/tls/tls.crt"
        tls_key_file = "/opt/vault/tls/tls.key"
        }

       systemctl start vault
       systemctl status vault
EOF
}


output "public_ip" {
  value = aws_instance.linux.public_ip
}
