provider "aws" {
  region = "us-east-1"
}

module "vault" {
  source = "terraform-aws-modules/vault/aws"

  vpc_id     = "vpc-39975044"
  subnet_ids = ["subnet-c4f243e5"]

  instances_count = 1
  instance_type   = "t2.medium"

  cluster_name = "vault"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}