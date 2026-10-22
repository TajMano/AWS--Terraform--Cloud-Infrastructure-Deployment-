# Architecture and design notes

## Request and network path

1. An internet-facing **Application Load Balancer (ALB)** listens on HTTP port 80.
2. The ALB forwards HTTP requests to a target group with health checks on `/`.
3. An **EC2 Auto Scaling Group** launches and maintains instances in two availability zones using available default-VPC subnets.
4. The launch template selects an Amazon Linux 2023 AMI and specifies two additional encrypted gp3 EBS volumes per instance.
5. The launch template uses the Bash user-data script at `scripts/install-env.sh` to install Nginx and start the service.
6. EC2 security-group ingress to port 80 is restricted to traffic from the ALB security group. No SSH inbound rule is configured.

## Storage and data

- **Amazon S3**: Terraform creates separate private raw and finished buckets with public access blocking and server-side encryption. `scripts/upload-s3-images.sh` can upload local PNGs to either bucket via the AWS CLI. There is no automatic image-processing pipeline or raw-to-finished transfer.
- **Amazon DynamoDB**: Terraform provisions a table with an optional fictional demonstration record. The table is separate from the Nginx application.

## Capacity and deployment choices

- Defaults: ASG minimum 2, desired 2, maximum 5. These values define capacity bounds, not scaling rules or CPU-triggered scaling behavior.
- Uses existing default-VPC network resources rather than managing an entirely new private network topology. Environment compatibility depends on the default VPC and its subnets.
- Additional EBS volumes are declared in the launch template, but the Nginx bootstrap does not mount or format them.
- The example uses HTTP without TLS. A production-grade design would add HTTPS with ACM, appropriate network segmentation, access controls, monitoring, and hardening.
- S3 uses `force_destroy = false`, so any objects must be removed separately prior to `terraform destroy`.
- Provisioning resources may incur AWS costs.
