# Found automatically: the Identity Center instance you enabled in this region
data "aws_ssoadmin_instances" "this" {}

locals {
  identity_store_id = one(data.aws_ssoadmin_instances.this.identity_store_ids)
}

resource "aws_identitystore_user" "admin" {
  count = var.create_admin_user ? 1 : 0

  identity_store_id = local.identity_store_id
  display_name      = var.admin_display_name
  user_name         = var.admin_username

  name {
    given_name  = var.admin_given_name
    family_name = var.admin_family_name
  }

  emails {
    value = var.admin_email
  }
}

data "aws_identitystore_user" "existing" {
  count = var.create_admin_user ? 0 : 1

  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = var.admin_username
    }
  }
}

locals {
  admin_user_id = var.create_admin_user ? aws_identitystore_user.admin[0].user_id : data.aws_identitystore_user.existing[0].user_id
}

module "capability" {
  source  = "terraform-aws-modules/eks/aws//modules/capability"
  version = "~> 21.0"

  name         = "argocd"
  type         = "ARGOCD"
  cluster_name = var.cluster_name

  configuration = {
    argo_cd = {
      namespace = var.namespace

      aws_idc = {
        idc_instance_arn = one(data.aws_ssoadmin_instances.this.arns)
      }

      rbac_role_mapping = [{
        role = "ADMIN"
        identity = [{
          id   = local.admin_user_id
          type = "SSO_USER"
        }]
      }]
    }
  }
}

# EKS creates an access entry for the capability role but grants no Kubernetes
# permissions. Argo CD needs them to deploy to this cluster.
resource "aws_eks_access_policy_association" "argocd" {
  cluster_name  = var.cluster_name
  principal_arn = module.capability.iam_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}
