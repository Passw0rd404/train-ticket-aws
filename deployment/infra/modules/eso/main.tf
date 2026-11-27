data "aws_caller_identity" "current" {}

locals {
  account_id      = data.aws_caller_identity.current.account_id
  scoped_role_arn = { for k, _ in var.roles : k => "arn:aws:iam::${local.account_id}:role/${k}" }
}

# ---- ESO controller role (bound via EKS Pod Identity) -----------------------
data "aws_iam_policy_document" "controller_trust" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "controller" {
  name               = "${var.name_prefix}-eso-controller"
  assume_role_policy = data.aws_iam_policy_document.controller_trust.json
}

data "aws_iam_policy_document" "controller_assume_scoped" {
  statement {
    actions   = ["sts:AssumeRole", "sts:TagSession"]
    resources = values(local.scoped_role_arn)
  }
}

resource "aws_iam_role_policy" "controller_assume_scoped" {
  name   = "assume-scoped-eso-roles"
  role   = aws_iam_role.controller.id
  policy = data.aws_iam_policy_document.controller_assume_scoped.json
}

resource "aws_eks_pod_identity_association" "eso" {
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = var.service_account
  role_arn        = aws_iam_role.controller.arn
}

# ---- Per-store least-privilege roles (names match ClusterSecretStores) ------
data "aws_iam_policy_document" "scoped_trust" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.controller.arn]
    }
  }
}

resource "aws_iam_role" "scoped" {
  for_each = var.roles

  name               = each.key
  assume_role_policy = data.aws_iam_policy_document.scoped_trust.json
}

data "aws_iam_policy_document" "read" {
  for_each = var.roles

  statement {
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = each.value.secret_arns
  }
}

resource "aws_iam_role_policy" "read" {
  for_each = var.roles

  name   = "read-secrets"
  role   = aws_iam_role.scoped[each.key].id
  policy = data.aws_iam_policy_document.read[each.key].json
}
