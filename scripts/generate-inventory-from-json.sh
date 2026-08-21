#!/usr/bin/env bash
# Generate Ansible inventory from Terraform JSON outputs (for CI environments)
# Does not require Terraform or AWS access — reads a pre-exported JSON file
# Usage: ./scripts/generate-inventory-from-json.sh <json_file> [environment]

set -euo pipefail

JSON_FILE="${1:?Usage: $0 <tf_outputs.json> [environment]}"
ENV="${2:-dev}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INVENTORY_FILE="$SCRIPT_DIR/../ansible/inventory/$ENV"

if [ ! -f "$JSON_FILE" ]; then
  echo "ERROR: JSON file not found: $JSON_FILE"
  exit 1
fi

NGINX_IP=$(jq -r '.nginx_public_ip.value' "$JSON_FILE")
APP_IP=$(jq -r '.app_private_ip.value' "$JSON_FILE")
APP_PORT=$(jq -r '.app_port.value' "$JSON_FILE")

if [ "$NGINX_IP" = "null" ] || [ -z "$NGINX_IP" ] || [ "$APP_IP" = "null" ] || [ -z "$APP_IP" ]; then
  echo "ERROR: Missing required outputs (nginx_public_ip, app_private_ip) in $JSON_FILE"
  exit 1
fi

echo "    nginx_public_ip = $NGINX_IP"
echo "    app_private_ip  = $APP_IP"
echo "    app_port        = $APP_PORT"

mkdir -p "$(dirname "$INVENTORY_FILE")"

TEMPLATE_FILE="$SCRIPT_DIR/../ansible/templates/inventory.tmpl"

if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "ERROR: Inventory template not found: $TEMPLATE_FILE"
  exit 1
fi

echo "==> Generating Ansible inventory at $INVENTORY_FILE"

export NGINX_IP APP_IP APP_PORT ENV
envsubst < "$TEMPLATE_FILE" > "$INVENTORY_FILE"

echo "==> Done. Run: ansible-playbook -i inventory/$ENV playbooks/site.yml"
