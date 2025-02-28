provider "aws" {
  region = var.region

  default_tags {
    tags = {
      app         = "Account_Management",
      environment = var.env,
      repo        = var.repo
    }
  }

}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "s3_backend" {
  backend = "s3"

  config = {
    bucket = aws_s3_bucket.tfstate_bucket.id
    key    = "${var.repo}/${var.env}/terraform.tfstate"
    region = "us-west-2"
  }
}
