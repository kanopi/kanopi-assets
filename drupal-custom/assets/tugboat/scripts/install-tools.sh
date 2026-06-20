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

log "Installing Node ${NODE_VERSION} + Yarn via nvm"
mkdir -p "${NVM_DIR}"
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash >/dev/null
set +u
# shellcheck disable=SC1091
. "${NVM_DIR}/nvm.sh"
set -u
nvm install "${NODE_VERSION}" >/dev/null
nvm alias default "${NODE_VERSION}" >/dev/null
corepack enable >/dev/null 2>&1 || npm install -g corepack >/dev/null 2>&1
corepack prepare "yarn@${YARN_VERSION:-4.15.0}" --activate >/dev/null 2>&1 || true
node --version

if [ -x "${TUGBOAT_ROOT}/vendor/bin/drush" ]; then
  ln -sf "${TUGBOAT_ROOT}/vendor/bin/drush" /usr/local/bin/drush
fi
