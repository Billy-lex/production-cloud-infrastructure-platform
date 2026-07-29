#!/bin/bash
set -euo pipefail

# =============================================================================
# Terraform Backend Bootstrap Script
# =============================================================================
#
# Purpose:
#   Create the S3 bucket required for Terraform remote state storage.
#   This script solves the chicken-and-egg problem: Terraform needs the S3
#   bucket to exist before "terraform init", but Terraform itself can't
#   create it (because the backend isn't initialized yet).
#
# Usage:
#   Run ONCE before the first "terraform init":
#
#     ./scripts/bootstrap.sh
#     cd terraform/environments/dev
#     terraform init
#     terraform apply
#
# Prerequisites:
#   - AWS CLI installed and configured with appropriate credentials
#   - Sufficient IAM permissions: s3:CreateBucket, s3:PutBucketVersioning,
#     s3:PutBucketPublicAccessBlock
#
# Notes:
#   - Safe to run multiple times (idempotent - skips if bucket exists)
#   - Enables versioning to protect against accidental state file loss
#   - Blocks all public access to the state bucket (security best practice)
# =============================================================================

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

BUCKET="myapp-terraform-state-bucket123"
REGION="us-east-1"

# -----------------------------------------------------------------------------
# Pre-flight checks
# -----------------------------------------------------------------------------

# Verify AWS CLI is installed
if ! command -v aws &>/dev/null; then
  echo "ERROR: aws CLI not found. Install it first:"
  echo "  https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
  exit 1
fi

# Verify AWS credentials are configured
if ! aws sts get-caller-identity &>/dev/null; then
  echo "ERROR: AWS credentials not configured or expired."
  echo "  Run: aws configure"
  exit 1
fi

echo "AWS Identity: $(aws sts get-caller-identity --query Arn --output text)"

# -----------------------------------------------------------------------------
# Create S3 bucket for Terraform state
# -----------------------------------------------------------------------------

if aws s3 ls "s3://$BUCKET" &>/dev/null; then
  echo "Bucket '$BUCKET' already exists. Skipping creation."
else
  echo "Creating S3 bucket: $BUCKET (region: $REGION)"

  # us-east-1 does not accept LocationConstraint; other regions require it
  if [ "$REGION" = "us-east-1" ]; then
    aws s3api create-bucket \
      --bucket "$BUCKET" \
      --region "$REGION"
  else
    aws s3api create-bucket \
      --bucket "$BUCKET" \
      --region "$REGION" \
      --create-bucket-configuration LocationConstraint="$REGION"
  fi

  echo "Bucket created."
fi

# -----------------------------------------------------------------------------
# Enable versioning (protects state file from accidental deletion/overwrite)
# -----------------------------------------------------------------------------

echo "Enabling bucket versioning..."
aws s3api put-bucket-versioning \
  --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled

# -----------------------------------------------------------------------------
# Block public access (state files must never be publicly accessible)
# -----------------------------------------------------------------------------

echo "Blocking public access..."
aws s3api put-public-access-block \
  --bucket "$BUCKET" \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------

echo ""
echo "============================================"
echo " Bootstrap complete"
echo "============================================"
echo ""
echo " S3 Bucket:   $BUCKET"
echo " Region:      $REGION"
echo " Versioning:  Enabled"
echo " Public:      Blocked"
echo ""
echo " Next steps:"
echo "   cd terraform/environments/dev"
echo "   terraform init"
echo "   terraform plan"
echo "   terraform apply"
echo ""
