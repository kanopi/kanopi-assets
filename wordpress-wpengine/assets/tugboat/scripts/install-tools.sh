#!/usr/bin/env bash
#
# install-tools.sh — system tooling for the WordPress preview container.
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

log "Installing packages + apache modules"
apt-get update
apt-get install -y rsync libzip-dev libmagickwand-dev >/dev/null
a2enmod expires headers rewrite >/dev/null
docker-php-ext-install mysqli exif zip >/dev/null 2>&1 || true

if ! command -v wp >/dev/null 2>&1; then
  log "Installing wp-cli"
  curl -fsSL -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x /usr/local/bin/wp
fi

log "Installing Node 20.x"
curl -fsSL https://deb.nodesource.com/setup_20.x | bash - >/dev/null
apt-get install -y nodejs >/dev/null
node --version

# Link the document root to the path Apache serves.
ln -snf "${CMS_ROOT}" "${DOCROOT:-/var/www/html}" 2>/dev/null || true
