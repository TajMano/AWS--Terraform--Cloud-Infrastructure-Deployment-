# Optional local S3 sample images

Place your own `.png` images in this folder to exercise the AWS CLI upload helper. These are local demonstration assets only and are excluded from Git by `.gitignore`.

After provisioning AWS resources, run `bash scripts/upload-s3-images.sh raw --dry-run` to preview the upload, or omit `--dry-run` to upload to the private raw S3 bucket. The finished bucket is a separate resource; this example does not process or transform images automatically.
