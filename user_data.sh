#!/bin/bash
apt update -y
apt install unzip curl -y

# Install Vault
curl -O https://releases.hashicorp.com/vault/1.15.2/vault_1.15.2_linux_amd64.zip
unzip vault_1.15.2_linux_amd64.zip
mv vault /usr/local/bin/

# Create Vault config directories
mkdir -p /etc/vault /opt/vault/data

# Fetch local IP from EC2 metadata
LOCAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Create Vault configuration file with interpolated IP address
cat <<EOF > /etc/vault.d/vault.hcl
storage "raft" {
  path    = "/opt/vault/data"
  node_id = "vault-$(hostname)"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

seal "awskms" {
  region     = "ap-south-1"
  kms_key_id = "alias/vault-auto-unseal-ajith"
}

api_addr = "http://$LOCAL_IP:8200"
cluster_addr = "http://$LOCAL_IP:8201"
EOF

# Start Vault manually (without systemd)
vault server -config=/etc/vault/config.hcl
