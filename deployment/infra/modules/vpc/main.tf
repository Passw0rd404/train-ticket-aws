data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = var.name
  cidr = var.cidr
  azs  = local.azs

  # Mostly private: large private subnets for EKS and Amazon MQ, small database
  # subnets for RDS. The small public subnets exist only because they bring the
  # internet gateway, which the regional NAT gateway needs.
  private_subnets  = [for i in range(var.az_count) : cidrsubnet(var.cidr, 4, i)]
  database_subnets = [for i in range(var.az_count) : cidrsubnet(var.cidr, 8, 100 + i)]
  public_subnets   = [for i in range(var.az_count) : cidrsubnet(var.cidr, 8, 200 + i)]

  # The module cannot build regional NAT gateways yet, so it is created below.
  enable_nat_gateway = false

  # The RDS module creates its own subnet group
  create_database_subnet_group = false

  enable_dns_support   = true
  enable_dns_hostnames = true

  public_subnet_tags  = { "kubernetes.io/role/elb" = 1 }
  private_subnet_tags = { "kubernetes.io/role/internal-elb" = 1 }
}

# One regional NAT gateway for the whole VPC. AWS adds addresses and covers new
# availability zones automatically, so there is nothing to size per zone.
resource "aws_nat_gateway" "regional" {
  vpc_id            = module.vpc.vpc_id
  availability_mode = "regional"

  tags = {
    Name = "${var.name}-regional"
  }

  # The internet gateway must exist first (and be removed last)
  depends_on = [module.vpc]
}

# Private subnets send internet-bound traffic through the regional NAT gateway
resource "aws_route" "private_nat" {
  count = length(module.vpc.private_route_table_ids)

  route_table_id         = module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.regional.id
}
