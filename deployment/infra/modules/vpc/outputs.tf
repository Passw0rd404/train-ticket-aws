output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

# Waits for the NAT route, so nodes can pull images and join the cluster as soon as they start
output "private_subnet_ids" {
  value      = module.vpc.private_subnets
  depends_on = [aws_route.private_nat]
}

output "database_subnet_ids" {
  value = module.vpc.database_subnets
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "nat_gateway_id" {
  value = aws_nat_gateway.regional.id
}
