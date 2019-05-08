terraform {
  backend "s3" {
    bucket = "jambit-iac-terraform"
    key = "skreisig/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  version = "~> 2"
  region = "eu-west-1"
}
