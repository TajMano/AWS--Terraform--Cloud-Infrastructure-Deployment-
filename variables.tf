variable "aws_region" {
  description = "AWS Region in which to deploy the portfolio environment."
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Short, lowercase prefix for named AWS resources."
  type        = string
  default     = "cloud-infra-demo"

  validation {
    condition     = length(var.project_name) <= 20 && can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.project_name))
    error_message = "project_name must be 2–20 characters, lowercase alphanumeric/hyphens, starting with a letter and ending with a letter/number."
  }
}

variable "availability_zones" {
  description = "Two or more availability zones in aws_region with default-VPC subnets."
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b"]

  validation {
    condition     = length(var.availability_zones) >= 2 && length(distinct(var.availability_zones)) == length(var.availability_zones)
    error_message = "Supply at least two distinct availability zones."
  }
}

variable "instance_type" {
  description = "EC2 instance type for the Nginx web instances."
  type        = string
  default     = "t3.micro"
}

variable "ebs_volume_size_gib" {
  description = "Size in GiB of EACH of two extra gp3 EBS volumes per instance."
  type        = number
  default     = 8

  validation {
    condition     = var.ebs_volume_size_gib >= 1 && var.ebs_volume_size_gib <= 1024
    error_message = "Extra gp3 EBS volume size must be between 1 and 1024 GiB."
  }
}

variable "asg_min_size" {
  description = "Minimum number of running EC2 instances."
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of running EC2 instances."
  type        = number
  default     = 5
}

variable "asg_desired_capacity" {
  description = "Desired number of running EC2 instances at deployment."
  type        = number
  default     = 2
}

variable "create_sample_item" {
  description = "Whether to write one fictional seed record to DynamoDB."
  type        = bool
  default     = false
}
