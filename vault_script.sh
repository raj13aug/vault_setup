#!/bin/bash
set -e
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt update
apt install vault -y


tee /etc/vault.d/vault.hcl <<EOF
ui = true

#mlock = true
#disable_mlock = true

storage "file" {
path = "/opt/vault/data"
}


# HTTPS listener
listener "tcp" {
address = "0.0.0.0:8200"
tls_cert_file = "/opt/vault/tls/tls.crt"
tls_key_file = "/opt/vault/tls/tls.key"
}
EOF

systemctl start vault
systemctl status vault
systemctl enable vault