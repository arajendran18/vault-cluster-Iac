resource "aws_instance" "vault" {
  count         = 3
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  subnet_id = element(
    ["subnet-0f6709602b301aa95", "subnet-0e2be7faaf7472165"],
    count.index
  )

  security_groups       = [aws_security_group.vault_sg.id]
  iam_instance_profile  = aws_iam_instance_profile.vault_profile.name
  user_data             = file("user_data.sh")

  tags = {
    Name = "vault-${count.index + 1}"
    VaultCluster  = "vault" 
  }
}
