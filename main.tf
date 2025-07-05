provider "aws" {
  region = var.region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.18.1"
  # Optionally add VPC setup if needed, else pass existing VPC
}
