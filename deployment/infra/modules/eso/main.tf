data "aws_iam_policy_document" "trust" {
  for_each = var.roles

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Only this one service account can assume this role
    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${each.value.service_account}"]
    }
  }
}

resource "aws_iam_role" "this" {
  for_each = var.roles

  name               = "${var.name_prefix}-eso-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.trust[each.key].json
}

data "aws_iam_policy_document" "read" {
  for_each = var.roles

  statement {
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = [each.value.secret_arn]
  }
}

resource "aws_iam_role_policy" "read" {
  for_each = var.roles

  name   = "read-${each.key}-secret"
  role   = aws_iam_role.this[each.key].id
  policy = data.aws_iam_policy_document.read[each.key].json
}
