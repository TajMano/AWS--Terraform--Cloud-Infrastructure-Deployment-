# This demo intentionally reuses the AWS account's default VPC and default
# subnets. It does not create a new VPC or NAT gateway.
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "selected" {
  for_each = toset(var.availability_zones)

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "availability-zone"
    values = [each.value]
  }
}

# AWS maintains this public parameter for the latest Amazon Linux 2023 x86_64 AMI.
data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

locals {
  subnet_ids = [for az in var.availability_zones : data.aws_subnets.selected[az].ids[0]]

  common_tags = {
    Project     = var.project_name
    Environment = "demo"
    ManagedBy   = "Terraform"
  }
}
