#!/bin/bash
set -euo pipefail

# Bootstrap only - no business configuration
# Nginx and application config are managed by Ansible

# System updates
apt-get update -y
apt-get upgrade -y

# Essential tooling
apt-get install -y \
  curl \
  wget \
  unzip \
  awscli

# Signal bootstrap completion
echo "Bootstrap completed at $(date)" > /var/log/bootstrap.log
