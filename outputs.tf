output "application_url" {
  description = "HTTP URL of the public application load balancer (demo only)."
  value       = "http://${aws_lb.web.dns_name}"
}

output "target_group_arn" {
  description = "ALB target group used by the Auto Scaling Group."
  value       = aws_lb_target_group.web.arn
}

output "bucket_names" {
  description = "Private raw and finished S3 bucket names."
  value       = { for name, bucket in aws_s3_bucket.demo : name => bucket.id }
}

output "dynamodb_table_name" {
  description = "DynamoDB table created by Terraform."
  value       = aws_dynamodb_table.demo.name
}

output "availability_zones" {
  description = "Availability zones selected for the EC2 Auto Scaling Group."
  value       = var.availability_zones
}

output "raw_s3_bucket_name" {
  description = "Private S3 bucket used for raw sample image uploads."
  value       = aws_s3_bucket.demo["raw"].id
}

output "finished_s3_bucket_name" {
  description = "Private S3 bucket for finished samples (no processing pipeline provided)."
  value       = aws_s3_bucket.demo["finished"].id
}

output "aws_region" {
  description = "AWS Region for AWS CLI portfolio checks."
  value       = var.aws_region
}
