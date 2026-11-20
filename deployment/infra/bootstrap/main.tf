
# Apply once, by hand, from your laptop with your own admin AWS login:
#   terraform init
#   terraform apply -var github_repo=OWNER/REPO
# It creates the GitHub OIDC trust, the Terraform role the workflows assume,
# and the S3 bucket that holds the Terraform state (with native S3 locking).

terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"

  default_tags {
    tags = {
      Stack     = "bootstrap"
      ManagedBy = "terraform"
    }
  }
}

variable "github_repo" {
  description = "GitHub repository as owner/repo, exact case"
  type        = string
}

data "aws_caller_identity" "current" {}

locals {
  owner = split("/", var.github_repo)[0]
  repo  = split("/", var.github_repo)[1]
  acct  = data.aws_caller_identity.current.account_id

  # GitHub adds @<id> suffixes to the subject of repos created after 15 July 2026,
  # so every pattern is listed in both forms.
  subject_main = [
    "repo:${local.owner}/${local.repo}:ref:refs/heads/main",
    "repo:${local.owner}@*/${local.repo}@*:ref:refs/heads/main",
    "repo:${local.owner}/${local.repo}:ref:refs/heads/master",
    "repo:${local.owner}@*/${local.repo}@*:ref:refs/heads/master",
  ]
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

# Who may assume the role: runs on main only
data "aws_iam_policy_document" "trust_main" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.subject_main
    }
  }
}

# Terraform apply and destroy. Admin, because the stack creates IAM, VPC and more;
# only runs on main can assume it. Two hours because long runs are possible.
resource "aws_iam_role" "terraform" {
  name                 = "gha-terraform"
  max_session_duration = 7200
  assume_role_policy   = data.aws_iam_policy_document.trust_main.json
}

resource "aws_iam_role_policy_attachment" "terraform_admin" {
  role       = aws_iam_role.terraform.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Terraform state bucket (locking uses a lock file in the bucket, no DynamoDB needed)
resource "aws_s3_bucket" "tfstate" {
  bucket = "tfstate-mern-dev-${local.acct}"

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "terraform_role_arn" {
  value = aws_iam_role.terraform.arn
}

output "tfstate_bucket" {
  value = aws_s3_bucket.tfstate.bucket
}
