#!/usr/bin/env bash

set -euo pipefail

DATE=$(date +%F)
BACKUP_DIR="/var/backups/nginx_$DATE"

read -rp "Enter your email: " EMAIL
read -rp "Enter domains separated by space: " DOMAINS

mkdir -p "$BACKUP_DIR"

echo "Taking backup of current nginx configs..."
echo "path: $BACKUP_DIR"
cp -r /etc/nginx/sites-available /etc/nginx/sites-enabled "$BACKUP_DIR"


if ! command -v certbot >/dev/null 2>&1; then
    echo "Certbot not found. Installing..."
    sudo apt update
    sudo apt install -y certbot python3-certbot-nginx
else
    echo "Certbot is already installed."
fi

echo "Generating certificates for domains: $DOMAINS"

# Convert space-separated domains into -d arguments
DOMAIN_ARGS=""
for domain in $DOMAINS; do
    DOMAIN_ARGS="$DOMAIN_ARGS -d $domain"
done

sudo certbot --nginx $DOMAIN_ARGS --non-interactive --agree-tos --email "$EMAIL"

echo "Reloading nginx..."
sudo systemctl reload nginx

echo "Certificates generated and nginx reloaded successfully!"