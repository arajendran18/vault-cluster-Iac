# ---------- General ----------
variable "region" {
  description = "AWS Region"
  default     = "ap-south-1"
}

variable "vpc_id" {
  description = "VPC where the resources will be deployed"
  type        = string
  default     = "vpc-0115151ae79085445"
}

# ---------- EC2 ----------
variable "ami_id" {
  description = "AMI ID for Vault EC2 instances (Ubuntu preferred)"
  type        = string
  default     = "ami-0f918f7e67a3323f0"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH key name for EC2 access"
  type        = string
  default     = "vault-test-server"
}

variable "vault_instance_count" {
  description = "Number of Vault EC2 nodes"
  default     = 3
}

# ---------- Security ----------
variable "allowed_ip_cidr_blocks" {
  description = "CIDR blocks allowed to access Vault (e.g. your office/public IP)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ---------- Load Balancer ----------
variable "public_subnet_ids" {
  description = "List of public subnet IDs for Network Load Balancer and EC2"
  type        = list(string)
  default     = ["subnet-0e2be7faaf7472165"]
}

# ---------- EC2 Subnet Placement ----------
# Since you're using public subnet for EC2 too, reuse the same value
variable "private_subnet_ids" {
  description = "Placeholder for private subnets — using public subnet instead"
  type        = list(string)
  default     = ["subnet-0e2be7faaf7472165"]
}

# ---------- KMS ----------
variable "kms_key_alias" {
  description = "Alias for the AWS KMS key used for Vault Auto Unseal"
  default     = "alias/vault-auto-unseal"
}
