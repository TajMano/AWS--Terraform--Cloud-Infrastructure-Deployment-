#!/usr/bin/env bash
set -euo pipefail

if ! command -v terraform >/dev/null 2>&1; then
  echo "Terraform CLI not installed. See README for prerequisites." >&2
  exit 1
fi

terraform fmt -check -recursive
terraform init -backend=false
terraform validate
