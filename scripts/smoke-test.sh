#!/usr/bin/env bash
# Basic checks for a deployed AWS infrastructure environment.
# Prerequisites: deployed Terraform workspace; AWS CLI configured; curl available.
set -euo pipefail

for tool in terraform aws curl grep; do
  command -v "$tool" >/dev/null 2>&1 || { echo "Required tool missing: $tool" >&2; exit 1; }
done

repository_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repository_root"

region="$(terraform output -raw aws_region)"
url="$(terraform output -raw application_url)"
raw="$(terraform output -raw raw_s3_bucket_name)"
finished="$(terraform output -raw finished_s3_bucket_name)"
table="$(terraform output -raw dynamodb_table_name)"

printf 'Checking HTTP page at %s ...\n' "$url"
curl --fail --show-error --silent --max-time 20 "$url" | grep -Fq 'AWS Multi-AZ Infrastructure Demo'
echo 'PASS: demo page returned expected marker'

for bucket in "$raw" "$finished"; do
  aws s3api head-bucket --bucket "$bucket" --region "$region" >/dev/null
  echo "PASS: bucket exists and is accessible: $bucket"
done

status="$(aws dynamodb describe-table --table-name "$table" --region "$region" --query 'Table.TableStatus' --output text)"
[[ "$status" == 'ACTIVE' ]] || { echo "Expected DynamoDB ACTIVE; got: $status" >&2; exit 1; }
echo "PASS: DynamoDB table is ACTIVE: $table"

echo 'Smoke checks passed.'
