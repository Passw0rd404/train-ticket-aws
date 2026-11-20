# Loaded automatically by terraform, so the workflows need no -var-file flag.

env = "prod"

# Different range from dev, so the two VPCs can be peered later
vpc_cidr = "10.1.0.0/16"
az_count = 3

# EKS. 3 x r6i.large = 6 vCPU and 48 GiB in total.
kubernetes_version  = "1.35"
node_instance_types = ["r6i.large"]
node_count          = 3
node_disk_size      = 50

# Private API only. You need a VPN, a bastion or SSM port forwarding to run kubectl.
# Set this to true with a list of your own addresses if you prefer public access.
endpoint_public_access       = false
endpoint_public_access_cidrs = []

# Your own IAM user or role that should get kubectl admin access
admin_principal_arns = []

# RDS MySQL
db_instance_class        = "db.m7g.large"
db_multi_az              = true
db_backup_retention_days = 14
db_deletion_protection   = true
db_skip_final_snapshot   = false

# Amazon MQ for RabbitMQ (a cluster needs mq.m5.large or bigger)
mq_instance_type        = "mq.m5.large"
mq_deployment_mode      = "CLUSTER_MULTI_AZ"
mq_secret_recovery_days = 7

apply_immediately = false
