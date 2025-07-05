# ---------- General ----------
variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC where the resources will be deployed"
  type        = string
}

# ---------- EC2 ----------
variable "ami_id" {
  description = "AMI ID for Vault EC2 instances (Ubuntu preferred)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.medium"
}

variable "key_name" {
  description = "SSH key name for EC2 access"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EC2 instances"
  type        = list(string)
}

variable "vault_instance_count" {
  description = "Number of Vault EC2 nodes"
  default     = 3
}

# ---------- Security ----------
variable "allowed_ip_cidr_blocks" {
  description = "CIDR blocks allowed to access Vault (e.g. your office/public IP)"
  type        = list(string)
}

# ---------- Load Balancer ----------
variable "public_subnet_ids" {
  description = "List of public subnet IDs for Network Load Balancer"
  type        = list(string)
}

# ---------- KMS ----------
variable "kms_key_alias" {
  description = "Alias for the AWS KMS key used for Vault Auto Unseal"
  default     = "alias/vault-auto-unseal"
}