terraform {
  required_version = ">= 1.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.27"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # The bucket is passed at init time (see the workflows):
  #   terraform init -backend-config="bucket=tfstate-mern-dev-<account-id>"
  # Locking uses a lock file in the bucket, no DynamoDB table.
  backend "s3" {
    key          = "prod/terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project
      Environment = var.env
      ManagedBy   = "terraform"
    }
  }
}

locals {
  name = "${var.project}-${var.env}"
}

module "vpc" {
  source = "../modules/vpc"

  name     = local.name
  cidr     = var.vpc_cidr
  az_count = var.az_count
}

module "eks" {
  source = "../modules/eks"

  name               = local.name
  kubernetes_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  instance_types = var.node_instance_types
  node_count     = var.node_count
  node_disk_size = var.node_disk_size

  endpoint_public_access       = var.endpoint_public_access
  endpoint_public_access_cidrs = var.endpoint_public_access_cidrs
  admin_principal_arns         = var.admin_principal_arns
}

module "rds" {
  source = "../modules/rds"

  name       = local.name
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.database_subnet_ids

  # Pods connect through the node network interfaces
  allowed_security_group_ids = [module.eks.node_security_group_id]

  engine_version        = var.db_engine_version
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  multi_az              = var.db_multi_az
  backup_retention_days = var.db_backup_retention_days
  deletion_protection   = var.db_deletion_protection
  skip_final_snapshot   = var.db_skip_final_snapshot
  apply_immediately     = var.apply_immediately
}

module "mq" {
  source = "../modules/mq"

  name       = local.name
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  allowed_security_group_ids = [module.eks.node_security_group_id]

  instance_type        = var.mq_instance_type
  deployment_mode      = var.mq_deployment_mode
  apply_immediately    = var.apply_immediately
  secret_recovery_days = var.mq_secret_recovery_days
}

module "eso" {
  source = "../modules/eso"

  oidc_provider_arn = module.eks.oidc_provider_arn
  namespace         = "external-secrets"
  service_account   = "external-secrets"
  secret_arns = [
    module.rds.master_user_secret_arn,
    module.mq.secret_arn,
  ]
}

# ESO reads the RDS and MQ secrets created by the rds and mq modules
module "eso" {
  source = "../modules/eso"

  name              = "${local.name}-eso"
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider     = module.eks.oidc_provider
  namespace         = "external-secrets"
  service_account   = "external-secrets"

  secret_arns = [
    module.rds.master_user_secret_arn,
    module.mq.secret_arn,
  ]
}

module "argocd" {
  count  = var.enable_argocd ? 1 : 0
  source = "../modules/argocd"

  cluster_name   = module.eks.cluster_name
  admin_username = var.argocd_admin_username
}
