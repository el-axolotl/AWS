resource "aws_s3_bucket" "tfstate_bucket" {
  bucket = "tfstate-axolotl-${var.env}"
  force_destroy = var.s3_force_destroy
}

resource "aws_s3_object" "keys" {
    bucket = aws_s3_bucket.tfstate_bucket.id
    key = "${var.repo}/${var.env}/"
    force_destroy = var.s3_force_destroy
}