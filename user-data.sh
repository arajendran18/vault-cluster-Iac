#!/bin/bash
apt update -y
apt install unzip curl -y
curl -O https://releases.hashicorp.com/vault/1.15.2/vault_1.15.2_linux_amd64.zip
unzip vault_1.15.2_linux_amd64.zip
mv vault /usr/local/bin/

mkdir -p /etc/vault /opt/vault/data
cat <<EOF > /etc/vault/config.hcl
storage "raft" {
  path    = "/opt/vault/data"
  node_id = "vault-\$(hostname)"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

seal "awskms" {
  region     = "us-east-1"
  kms_key_id = "REPLACE_ME_WITH_KMS_ID"
}

api_addr = "http://\$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4):8200"
cluster_addr = "http://\$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4):8201"
EOF

vault server -config=/etc/vault/config.hcl
