#!/usr/bin/env bash
#
# build.sh — dependencies, Tugboat wp-config, theme build, docroot link.
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

if [ -f "${TUGBOAT_ROOT}/composer.json" ]; then
  log "composer install"
  composer --working-dir="${TUGBOAT_ROOT}" install --optimize-autoloader
fi

log "Creating Tugboat wp-config.php"
rm -f "${CMS_ROOT}/wp-config.php" || true
if [ "${WP_MULTISITE}" = "true" ] && [ -f "${CMS_ROOT}/wp-config-multisite.php" ]; then
  # Pull the network constants from the committed, version-controlled config so
  # the preview matches every other environment. deploy.sh feeds the correct
  # DOMAIN_CURRENT_SITE to wp-cli via the WP_MULTISITE_DOMAIN env var.
  log "Including wp-config-multisite.php (network constants)"
  ${WP} config create --dbname="tugboat" --dbuser="tugboat" --dbpass="tugboat" \
    --dbhost="mysql" --dbprefix="${TABLE_PREFIX}" --force \
    --extra-php <<'PHP'
require_once __DIR__ . '/wp-config-multisite.php';
PHP
else
  [ "${WP_MULTISITE}" = "true" ] && \
    log "WP_MULTISITE=true but wp-config-multisite.php not found at ${CMS_ROOT}; network constants will be missing."
  ${WP} config create --dbname="tugboat" --dbuser="tugboat" --dbpass="tugboat" \
    --dbhost="mysql" --dbprefix="${TABLE_PREFIX}" --force
fi

if [ "${BUILD_THEME}" = "true" ] && [ -n "${THEME_PATH}" ] && [ -f "${TUGBOAT_ROOT}/${THEME_PATH}/package.json" ]; then
  log "Building theme in ${THEME_PATH} (${NODE_PACKAGE_MANAGER})"
  case "${NODE_PACKAGE_MANAGER}" in
    yarn) ( cd "${TUGBOAT_ROOT}/${THEME_PATH}" && yarn install --immutable && yarn run "${THEME_BUILD_COMMAND}" ) ;;
    *)    ( cd "${TUGBOAT_ROOT}/${THEME_PATH}" && npm ci && npm run "${THEME_BUILD_COMMAND}" ) ;;
  esac
fi

ln -snf "${CMS_ROOT}" "${DOCROOT:-/var/www/html}" 2>/dev/null || true
