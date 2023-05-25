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
        echo "Installing dependencies..."
        sudo apt-get update -y
        sudo apt-get install -y unzip


        echo "Fetching vault..."
        VAULT=0.6.5
        cd /tmp
        wget https://releases.hashicorp.com/vault/${VAULT}/vault_${VAULT}_linux_amd64.zip -O vault.zip
        wget https://gist.githubusercontent.com/ewilde/b3f622e0899b5188263238c2e54054c9/raw/8f7816ed98f4f4cc9efa5034a2ce300e0e8f95d7/vault.service -O vault.service

        echo "Installing Vault..."
        unzip vault.zip >/dev/null
        chmod +x vault
        sudo mv vault /usr/local/bin/vault

       # Write the flags to a temporary file
        cat >/tmp/vault_flags << EOF
        OPTIONS=""
        KEYS="your keys after"
        VAULT_TOKEN="your root token"
        VAULT_ADDR="http://0.0.0.0:8200"


        echo "Installing Systemd service..."
        sudo mkdir -p /etc/vault.d
        sudo tee -a /etc/vault.d/vault.conf >/dev/null <<'EOF'
        
        sudo chown root:root /tmp/vault.service
        sudo mv /tmp/vault.service /etc/systemd/system/vault.service
        sudo chmod 0644 /etc/systemd/system/vault.service
        sudo mv /tmp/vault_flags /etc/default/vault
        sudo chown root:root /etc/default/consul
        sudo chmod 0644 /etc/default/consul

      EOF
}


output "public_ip" {
  value = aws_instance.linux.public_ip
}
