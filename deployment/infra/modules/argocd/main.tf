# Found automatically: the Identity Center instance you enabled in this region
data "aws_ssoadmin_instances" "this" {}

data "aws_identitystore_user" "admin" {
  identity_store_id = one(data.aws_ssoadmin_instances.this.identity_store_ids)

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = var.admin_username
    }
  }
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
          id   = data.aws_identitystore_user.admin.user_id
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
