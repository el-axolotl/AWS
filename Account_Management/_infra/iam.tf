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
