#!/bin/bash
set -e
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt update
apt install vault -y
apt install nginx -y

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


sudo rm -rf /etc/nginx/sites-enabled/default
sudo rm -rf /etc/nginx/sites-available/default
touch /etc/nginx/sites-available/vault

bash -c 'sudo cat <<EOT> /etc/nginx/sites-available/vault
server{
    listen      80;
    server_name vault.robofarming.link;
    access_log  /var/log/nginx/vault.access.log;
    error_log   /var/log/nginx/vault.error.log;
    proxy_buffers 16 64k;
    proxy_buffer_size 128k;
    location / {
        proxy_pass  http://127.0.0.1:8200;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_redirect off;
              
        proxy_set_header    Host            \$host;
        proxy_set_header    X-Real-IP       \$remote_addr;
        proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto http;
    }
}
EOT'
#Create symbolic link
ln -s /etc/nginx/sites-available/vault /etc/nginx/sites-enabled/vault

#Start Artifactory 
systemctl enable nginx.service
systemctl restart nginx.service
systemctl restart vault

echo "export VAULT_ADDR=http://127.0.0.1:8200" >> ~/.bashrc