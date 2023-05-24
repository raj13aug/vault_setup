provider "aws" {
  region = "us-east-1"
}

module "vault" {
  source  = "hashicorp/vault/aws"
  version = "0.17.0"

  vpc_id = "vpc-39975044"

  vault_instance_type = "t2.medium"

  vault_cluster_name = "vault"
}