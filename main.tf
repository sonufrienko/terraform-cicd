terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.46.0"
    }
  }

  backend "s3" {
    region         = "eu-west-1"
    encrypt        = true
    kms_key_id     = "alias/tfstate"
    key            = "development/terraform.tfstate"
    bucket         = "tf-9257-state"
    dynamodb_table = "tf-9257-state-lock"
  }
}

provider "aws" {
  region = "eu-west-1"
}

provider "aws" {
  alias  = "replica"
  region = "eu-west-1"
}

module "remote_state" {
  source                      = "nozaq/remote-state-s3-backend/aws"
  terraform_iam_policy_create = false
  enable_replication          = false
  override_s3_bucket_name     = true
  kms_key_alias               = "tfstate"
  s3_bucket_name              = "tf-9257-state"
  dynamodb_table_name         = "tf-9257-state-lock"

  providers = {
    aws         = aws
    aws.replica = aws.replica
  }
}
