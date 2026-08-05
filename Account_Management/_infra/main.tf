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

# ---------------------------------------------------------------------------
# S3 - start
# ---------------------------------------------------------------------------

resource "aws_s3_bucket" "tfstate_bucket" {
  bucket        = "tfstate-axolotl-${var.env}"
  force_destroy = var.s3_force_destroy
}

resource "aws_s3_object" "keys" {
  bucket        = aws_s3_bucket.tfstate_bucket.id
  key           = "${var.repo}/${var.env}/"
  force_destroy = var.s3_force_destroy
}

# ---------------------------------------------------------------------------
# S3 - end
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# IAM - start
# ---------------------------------------------------------------------------

# Roles
resource "aws_iam_role" "infra-engineer" {
  description = "Managed by Terraform. Grants access to infra-engineer role."

  name               = "infra-engineer-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.infra-engineer-assume-role.json
}

resource "aws_iam_role" "developer" {
  description = "Managed by Terraform. Grants access to developer role."

  name               = "developer-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.developer-assume-role.json
}

# Assume Role Policies
data "aws_iam_policy_document" "infra-engineer-assume-role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.account_id}:user/axolotl"
      ]
    }
  }
}

data "aws_iam_policy_document" "developer-assume-role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:user/axolotl"]
    }
  }
}

# Role Policy Attachments
resource "aws_iam_role_policy_attachment" "AmazonS3FullAccess" {
  role       = aws_iam_role.infra-engineer.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "IAMFullAccess" {
  role       = aws_iam_role.infra-engineer.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_role_policy_attachment" "IAMAccessAnalyzerReadOnlyAccess" {
  role       = aws_iam_role.infra-engineer.name
  policy_arn = "arn:aws:iam::aws:policy/IAMAccessAnalyzerReadOnlyAccess"
}

# Inline Policies
# data "aws_iam_policy_document" "developer-inline-policy" {
#   statement {
#     actions = []
#     resources = [aws_iam_role.developer.arn]
#   }
# }

# ---------------------------------------------------------------------------
# IAM - end
# ---------------------------------------------------------------------------
