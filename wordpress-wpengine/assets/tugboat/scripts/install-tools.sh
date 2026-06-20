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

# Link the document root to the path Apache serves.
ln -snf "${CMS_ROOT}" "${DOCROOT:-/var/www/html}" 2>/dev/null || true
