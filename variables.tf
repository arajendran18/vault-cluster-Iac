variable "region" {
  description = "AWS Region"
  default     = "ap-south-1"
}

variable "vpc_id" {
  description = "VPC where the resources will be deployed"
  type        = string
}

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
}

variable "vault_instance_count" {
  description = "Number of Vault EC2 nodes"
  default     = 3
}

variable "allowed_ip_cidr_blocks" {
  description = "CIDR blocks allowed to access Vault (e.g. your office/public IP)"
  type        = list(string)
}

variable "kms_key_alias" {
  description = "Alias for the AWS KMS key used for Vault Auto Unseal"
  default     = "alias/vault-auto-unseal"
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the load balancer and EC2 instances"
  type        = list(string)
}
