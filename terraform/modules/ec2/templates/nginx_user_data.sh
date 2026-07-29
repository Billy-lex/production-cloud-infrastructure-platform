#!/bin/bash
set -euo pipefail

# Update system packages
apt-get update -y
apt-get upgrade -y

# Install Nginx
apt-get install -y nginx

# Configure Nginx as reverse proxy to the application server
cat > /etc/nginx/sites-available/default <<'NGINX_CONF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass         http://${app_private_ip}:8080;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade $http_upgrade;
        proxy_set_header   Connection "upgrade";
        proxy_set_header   Host $host;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
NGINX_CONF

# Enable and start Nginx
systemctl enable nginx
systemctl restart nginx
