#!/bin/bash
set -e
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt update
apt install vault -y


tee /etc/vault.d/vault.hcl <<EOF
disable_cache = true
disable_mlock = true
ui = true


storage "file" {
path = "/opt/vault/data"
}


# HTTPS listener
listener "tcp" {
address = "0.0.0.0:8200"
tls_disable = 1
}
api_addr         = "http://0.0.0.0:8200"
max_lease_ttl         = "10h"
default_lease_ttl    = "10h"
cluster_name         = "vault"
raw_storage_endpoint     = true
disable_sealwrap     = true
disable_printable_check = true
EOF

systemctl start vault
systemctl status vault
systemctl enable vault