data "aws_caller_identity" "current" {}

# ---------------------------------------------------------------------------
# IAM - start
# ---------------------------------------------------------------------------

# Roles
resource "aws_iam_role" "infra-engineer" {
  description = "Managed by Terraform. Grants access to infra-engineer role."
  name               = "infra-engineer"
  assume_role_policy = data.aws_iam_policy_document.infra-engineer-assume-role.json
}

resource "aws_iam_role" "developer" {
  description = "Managed by Terraform. Grants access to developer role."
  name               = "developer"
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
    effect = "Allow"
    actions = [
      "apigateway:DELETE",
      "apigateway:GET",
      "apigateway:PATCH",
      "apigateway:POST",
      "apigateway:TagResource",
      "iam:AttachRolePolicy",
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:CreateRole",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
      "iam:DeleteRole",
      "iam:DetachRolePolicy",
      "iam:Get*",
      "iam:List*",
      "iam:PassRole",
      "iam:Tag*",
      "lambda:AddPermission",
      "lambda:Create*",
      "lambda:DeleteFunction",
      "lambda:Get*",
      "lambda:List*",
      "lambda:Put*",
      "lambda:RemovePermission",
      "lambda:Tag*",
      "lambda:Update*",
      "logs:CreateLog*",
      "logs:DeleteLogDelivery",
      "logs:DeleteLogGroup",
      "logs:Describe*",
      "logs:Get*",
      "logs:List*",
      "logs:Put*",
      "logs:Tag*",
      "cloudwatch:Get*",
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:DeleteObject",
      "s3:Get*",
      "s3:List*",
      "s3:Put*",
      "secretsmanager:CreateSecret",
      "secretsmanager:DeleteSecret",
      "secretsmanager:DescribeSecret",
      "secretsmanager:Get*",
      "secretsmanager:PutSecretValue",
      "secretsmanager:TagResource"
    ]
    resources = ["*"]

    condition {
      test     = "StringEqualsIfExists"
      variable = "aws:ResourceTag/purpose"
      values   = ["home-lab"]
    }
  }

  statement {
    sid     = "tfstate"
    effect  = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::tfstate-axolotl-prod",
      "arn:aws:s3:::tfstate-axolotl-prod/*"
    ]
  }

  statement {
    sid    = "slackbotDemoBucket"
    effect = "Allow"
    actions = [
      "s3:CreateBucket",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:GetBucketLocation",
      "s3:PutBucketTagging",
      "s3:GetBucketTagging"
    ]
    resources = [
      "arn:aws:s3:::slackbot-demo-*-us-west-2-bucket",
      "arn:aws:s3:::slackbot-demo-*-us-west-2-bucket/*"
    ]
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

data "aws_iam_policy_document" "infra-engineer-policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:Get*",
      "cloudwatch:Get*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "infra-engineer-policy" {
  description = "The iam policy that provides permissions to the infra-engineer role."

  name   = "infra-engineer-policy-${var.env}"
  path   = "/"
  policy = data.aws_iam_policy_document.infra-engineer-policy.json
}

resource "aws_iam_role_policy_attachment" "infra-engineer-policy-attachment" {
  role       = aws_iam_role.infra-engineer.name
  policy_arn = aws_iam_policy.infra-engineer-policy.arn
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
