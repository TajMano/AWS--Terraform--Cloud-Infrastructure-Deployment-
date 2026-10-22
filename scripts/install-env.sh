#!/usr/bin/env bash
# Nginx instance bootstrap for AWS EC2 user data.
# User data runs as root on first boot. Amazon Linux uses dnf; Ubuntu uses apt-get.
set -euo pipefail

if command -v dnf >/dev/null 2>&1; then
  dnf install -y nginx
  html_root=/usr/share/nginx/html
elif command -v apt-get >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y
  apt-get install -y nginx
  html_root=/var/www/html
else
  echo "Unable to install Nginx: no supported package manager (dnf or apt-get)." >&2
  exit 1
fi

# Use the usual document root for each distribution.
if [[ ! -d "$html_root" ]]; then
  echo "Nginx document root not found: $html_root" >&2
  exit 1
fi

cat > "${html_root}/index.html" <<HTML
<!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><title>AWS Multi-AZ Demo</title></head>
<body>
  <h1>AWS Multi-AZ Infrastructure Demo</h1>
  <p>Served by instance hostname: $(hostname)</p>
  <p>Provisioned with Terraform and Nginx.</p>
</body>
</html>
HTML

# Enable and start Nginx.
systemctl enable nginx
systemctl start nginx
