resource "aws_kms_key" "vault_unseal" {
  description             = "Vault Auto Unseal Key"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "vault_unseal_alias" {
  name          = var.kms_key_alias
  target_key_id = aws_kms_key.vault_unseal.key_id
}
