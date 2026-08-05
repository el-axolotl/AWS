data "aws_caller_identity" "current" {}

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
        "arn:aws:iam::${local.account_id}:user/${var.user1}"
      ]
    }
    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
}

data "aws_iam_policy_document" "developer-assume-role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.account_id}:user/${var.user1}",
        "arn:aws:iam::${local.account_id}:user/${var.user2}"
      ]
    }
    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
}

# Role Policies
data "aws_iam_policy_document" "developer-policy" {
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:CreateSecret"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["apigateway:POST"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "developer-policy" {
  description = "The iam policy that provides permissions to the developer role."

  name   = "developer-policy-${var.env}"
  path   = "/"
  policy = data.aws_iam_policy_document.developer-policy.json
}

resource "aws_iam_role_policy_attachment" "developer-policy-attachment" {
  role       = aws_iam_role.developer.name
  policy_arn = aws_iam_policy.developer-policy.arn
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

# ---------------------------------------------------------------------------
# IAM - end
# ---------------------------------------------------------------------------
