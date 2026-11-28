terraform {
  required_version = ">= 1.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.27"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.10"
    }

    grafana = {
      source  = "grafana/grafana"
      version = "~> 4.20"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  backend "s3" {
    key          = "dev/terraform.tfstate"
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

provider "cloudflare" {}

provider "grafana" {
  alias                     = "cloud"
  cloud_access_policy_token = var.grafana_cloud_access_policy_token
}

provider "grafana" {
  alias = "stack"
  url   = module.grafana.stack_url
  auth  = module.grafana.stack_sa_token
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

  allowed_security_group_ids = [module.eks.node_security_group_id]

  engine_version        = var.db_engine_version
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  multi_az              = var.db_multi_az
  backup_retention_days = var.db_backup_retention_days
  deletion_protection   = var.db_deletion_protection
  skip_final_snapshot   = var.db_skip_final_snapshot
  db_name               = var.db_name
  apply_immediately     = var.apply_immediately
}

module "mq" {
  source = "../modules/mq"

  name       = local.name
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  allowed_security_group_ids = [module.eks.node_security_group_id]

  engine_version    = var.mq_engine_version
  instance_type     = var.mq_instance_type
  deployment_mode   = var.mq_deployment_mode
  apply_immediately = var.apply_immediately
}

module "cloudflare" {
  source = "../modules/cloudflare"

  name                = local.name
  account_id          = var.cloudflare_account_id
  zone_name           = var.cloudflare_zone_name
  api_hostname        = var.api_hostname
  pages_project_name  = var.pages_project_name
  pages_domain        = var.pages_domain
  traefik_service_url = var.traefik_service_url
}

module "grafana" {
  source = "../modules/grafana"

  providers = {
    grafana.cloud = grafana.cloud
    grafana.stack = grafana.stack
  }

  name            = local.name
  env             = var.env
  stack_slug      = var.grafana_stack_slug
  frontend_origin = "https://${var.pages_domain}"
  alert_email     = var.alert_email
}

module "cloudwatch" {
  source = "../modules/cloudwatch"

  name           = local.name
  rds_identifier = module.rds.identifier
  mq_broker_name = "${local.name}-rabbitmq"
  nat_gateway_id = module.vpc.nat_gateway_id
  alert_email    = var.alert_email
}

module "argocd" {
  count  = var.enable_argocd ? 1 : 0
  source = "../modules/argocd"

  cluster_name       = module.eks.cluster_name
  create_admin_user  = var.argocd_create_admin_user
  admin_username     = var.argocd_admin_username
  admin_display_name = var.argocd_admin_display_name
  admin_given_name   = var.argocd_admin_given_name
  admin_family_name  = var.argocd_admin_family_name
  admin_email        = var.argocd_admin_email
}

module "app_secrets" {
  source = "../modules/app-secrets"

  prefix                  = var.secrets_prefix
  recovery_window_in_days = var.secret_recovery_window_days

  mysql_host           = module.rds.address
  mysql_database       = var.db_name
  mysql_admin_user     = module.rds.master_username
  mysql_admin_password = module.rds.master_password
  mysql_user           = var.db_app_user
  mysql_readonly_user  = var.db_readonly_user

  rabbitmq_host     = module.mq.host
  rabbitmq_user     = module.mq.admin_username
  rabbitmq_password = module.mq.admin_password

  cloudflare_tunnel_token = module.cloudflare.tunnel_token

  grafana_prometheus_url      = module.grafana.prometheus_remote_write_url
  grafana_prometheus_username = module.grafana.prometheus_username
  grafana_loki_url            = module.grafana.loki_push_url
  grafana_loki_username       = module.grafana.loki_username
  grafana_otlp_endpoint       = module.grafana.otlp_endpoint
  grafana_otlp_username       = module.grafana.otlp_username
  grafana_alloy_token         = module.grafana.alloy_token
  grafana_prom_query_url      = module.grafana.prometheus_query_url
  grafana_prom_read_token     = module.grafana.prom_read_token
}

module "eso" {
  source = "../modules/eso"

  name_prefix  = local.name
  cluster_name = module.eks.cluster_name
  namespace    = "external-secrets"

  roles = {
    "tt-eso-mysql" = {
      secret_arns = [module.app_secrets.mysql_arn, module.app_secrets.mysql_bootstrap_arn]
    }
    "tt-eso-rabbitmq" = {
      secret_arns = [module.app_secrets.rabbitmq_arn]
    }
    "tt-eso-email" = {
      secret_arns = [module.app_secrets.notification_arn]
    }
    "tt-eso-cloudflare" = {
      secret_arns = [module.app_secrets.cloudflare_arn]
    }
    "tt-eso-prom-read" = {
      secret_arns = [module.app_secrets.grafana_prom_read_arn]
    }
    "tt-eso-monitoring" = {
      secret_arns = [
        module.app_secrets.mysql_readonly_arn,
        module.app_secrets.rabbitmq_arn,
        module.app_secrets.grafana_arn,
      ]
    }
  }
}
