#!/bin/bash

# Update system & install dependencies
apt update -y
apt install unzip curl -y

# Install Vault
VAULT_VERSION="1.15.2"
curl -O https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip
unzip vault_${VAULT_VERSION}_linux_amd64.zip
mv vault /usr/local/bin/
chmod +x /usr/local/bin/vault

# Create Vault user & directories
useradd --system --home /etc/vault.d --shell /bin/false vault
mkdir -p /etc/vault.d /opt/vault/data
chown -R vault:vault /etc/vault.d /opt/vault

# Fetch instance's local IP using IMDSv2
TOKEN=$(curl -X PUT -s -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" \
  http://169.254.169.254/latest/api/token)

LOCAL_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/local-ipv4)

# Generate Vault config
cat <<EOF > /etc/vault.d/config.hcl
storage "raft" {
  path    = "/opt/vault/data"
  node_id = "vault-\$(hostname)"

  retry_join {
    auto_join = "provider=aws tag_key=VaultCluster tag_value=vault region=ap-south-1"
  }
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

seal "awskms" {
  region     = "ap-south-1"
  kms_key_id = "alias/vault-auto-unseal-ajith"
}

disable_mlock = true

api_addr = "http://$LOCAL_IP:8200"
cluster_addr = "http://$LOCAL_IP:8201"
ui = true
EOF

chown -R vault:vault /etc/vault.d

# Create systemd service
cat <<EOF > /etc/systemd/system/vault.service
[Unit]
Description=Vault
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target

[Service]
User=vault
Group=vault
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/config.hcl
ExecReload=/bin/kill --signal HUP \$MAINPID
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# Start Vault
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable vault
systemctl start vault
