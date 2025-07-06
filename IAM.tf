data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "vault_role" {
  name               = "vault-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy" "vault_kms_policy" {
  name = "vault-kms-policy"
  role = aws_iam_role.vault_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "VaultKMSUnsealPermissions",
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey"
        ],
        Resource = "arn:aws:kms:ap-south-1:058264471863:key/1d40b459-6ceb-4a39-84ba-13de08c97e11"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "vault_profile" {
  name = "vault-instance-profile"
  role = aws_iam_role.vault_role.name
}
