#!/usr/bin/env bash
#
# build.sh — settings, dependencies, theme build, docroot link.
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

log "Installing Tugboat settings.local.php"
cp "${TUGBOAT_ROOT}/.tugboat/settings.local.php" "${CMS_ROOT}/sites/default/settings.local.php"

log "composer install (no dev)"
composer --working-dir="${TUGBOAT_ROOT}" install --no-dev --optimize-autoloader
ln -sf "${TUGBOAT_ROOT}/vendor/bin/drush" /usr/local/bin/drush

if [ "${BUILD_THEME}" = "true" ] && [ -n "${THEME_PATH}" ] && [ -f "${TUGBOAT_ROOT}/${THEME_PATH}/package.json" ]; then
  log "Building theme in ${THEME_PATH}"
  ( cd "${TUGBOAT_ROOT}/${THEME_PATH}" && npm ci && npm run "${THEME_BUILD_COMMAND}" )
fi

ln -snf "${CMS_ROOT}" "${DOCROOT:-/var/www/html}/docroot" 2>/dev/null || true
