#!/usr/bin/env bash
#
# install-tools.sh — system tooling + PHP extensions for the preview container.
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

log "Installing PHP extensions + apache modules"
apt-get update
apt-get install -y rsync libzip-dev >/dev/null
docker-php-ext-install opcache zip >/dev/null 2>&1 || true
a2enmod headers rewrite >/dev/null
echo "memory_limit = 512M" >> /usr/local/etc/php/conf.d/my-php.ini

log "Installing Node 20.x"
curl -fsSL https://deb.nodesource.com/setup_20.x | bash - >/dev/null
apt-get install -y nodejs >/dev/null
node --version

if [ -x "${TUGBOAT_ROOT}/vendor/bin/drush" ]; then
  ln -sf "${TUGBOAT_ROOT}/vendor/bin/drush" /usr/local/bin/drush
fi
