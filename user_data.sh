#!/bin/bash

# Update and install dependencies
apt update -y
apt install unzip curl jq -y

# Install Vault
VAULT_VERSION="1.15.2"
curl -O https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip
unzip vault_${VAULT_VERSION}_linux_amd64.zip
mv vault /usr/local/bin/
chmod +x /usr/local/bin/vault

# Create Vault user and directories
useradd --system --home /etc/vault.d --shell /bin/false vault
mkdir -p /etc/vault.d /opt/vault/data
chown -R vault:vault /etc/vault.d /opt/vault
chmod 700 /opt/vault/data

# Fetch local IP
LOCAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Create Vault config
cat <<EOF > /etc/vault.d/config.hcl
ui = true

storage "raft" {
  path    = "/opt/vault/data"
  node_id = "vault-\$(hostname)"
  retry_join {
    auto_join = "provider=aws tag_key=VaultCluster tag_value=vault"
    auto_join_scheme = "http"
  }
  retry_join {
    auto_join = "provider=aws tag_key=VaultCluster tag_value=vault"
    auto_join_scheme = "http"
  }
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  cluster_address = "http://$LOCAL_IP:8201"
  tls_disable = 1
}

seal "awskms" {
  region     = "ap-south-1"
  kms_key_id = "alias/vault-auto-unseal-ajith"
}

api_addr = "http://$LOCAL_IP:8200"
cluster_addr = "http://$LOCAL_IP:8201"

disable_mlock = true
EOF

chown vault:vault /etc/vault.d/config.hcl
chmod 640 /etc/vault.d/config.hcl

# Create systemd service for Vault
cat <<EOF > /etc/systemd/system/vault.service
[Unit]
Description=Vault service
Documentation=https://developer.hashicorp.com/vault
Requires=network-online.target
After=network-online.target

[Service]
User=vault
Group=vault
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
ProtectControlGroups=yes
LimitMEMLOCK=infinity
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/config.hcl
ExecReload=/bin/kill --signal HUP \$MAINPID
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Enable and start Vault
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable vault
systemctl start vault
