terraform {
  backend "s3" {
    bucket  = "tfstate-axolotl-prod"
    key     = "AWS/terraform.tfstate"
    region  = "us-west-2"
    encrypt = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.38.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      app         = var.name,
      environment = var.env,
      repo        = var.repo
    }
  }

}
