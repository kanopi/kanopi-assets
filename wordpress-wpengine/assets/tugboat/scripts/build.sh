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
${WP} config create --dbname="tugboat" --dbuser="tugboat" --dbpass="tugboat" \
  --dbhost="mysql" --dbprefix="${TABLE_PREFIX}" --force

if [ "${BUILD_THEME}" = "true" ] && [ -n "${THEME_PATH}" ] && [ -f "${TUGBOAT_ROOT}/${THEME_PATH}/package.json" ]; then
  log "Building theme in ${THEME_PATH}"
  ( cd "${TUGBOAT_ROOT}/${THEME_PATH}" && npm ci && npm run "${THEME_BUILD_COMMAND}" )
fi

ln -snf "${CMS_ROOT}" "${DOCROOT:-/var/www/html}" 2>/dev/null || true
