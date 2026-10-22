#!/usr/bin/env bash
set -euo pipefail

# Upload local PNG demonstration images to one Terraform-managed private S3 bucket.
# Requires completed terraform apply, AWS CLI login and IAM permissions for s3:PutObject.

usage() {
  echo "Usage: bash scripts/upload-s3-images.sh <raw|finished> [--dry-run]" >&2
  echo "Example: bash scripts/upload-s3-images.sh raw --dry-run" >&2
}

if [[ $# -lt 1 || $# -gt 2 ]]; then usage; exit 2; fi
selection="$1"
if [[ "$selection" != "raw" && "$selection" != "finished" ]]; then usage; exit 2; fi
if [[ $# -eq 2 && "$2" != "--dry-run" ]]; then usage; exit 2; fi

directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
image_dir="$directory/assets/sample-images"
shopt -s nullglob
images=("$image_dir"/*.png)
if (( ${#images[@]} == 0 )); then
  echo "No .png files in $image_dir. Add your local sample files and retry." >&2
  exit 1
fi
command -v aws >/dev/null || { echo "AWS CLI not installed" >&2; exit 1; }
command -v terraform >/dev/null || { echo "Terraform CLI not installed" >&2; exit 1; }

cd "$directory"
if [[ "$selection" == "raw" ]]; then
  bucket="$(terraform output -raw raw_s3_bucket_name)"
else
  bucket="$(terraform output -raw finished_s3_bucket_name)"
fi

flags=()
if [[ $# -eq 2 ]]; then flags+=(--dryrun); fi

printf 'Selected private S3 bucket: %s\n' "$bucket"
for file in "${images[@]}"; do
  key="portfolio-samples/$(basename "$file")"
  aws s3 cp "$file" "s3://$bucket/$key" --content-type image/png "${flags[@]}"
done

if [[ $# -eq 1 ]]; then
  echo "Upload complete. Inspect objects with: aws s3 ls s3://$bucket/portfolio-samples/"
else
  echo "Dry run only: no objects were uploaded."
fi
