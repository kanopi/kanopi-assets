#!/usr/bin/env bash
#
# files.sh — make production media available in the preview. Two independent,
# conditional strategies (set in tugboat.env):
#   FILES_PROXY=true  -> serve missing uploads from PROD_URL (no copy; fast)
#   FILES_RSYNC=true  -> rsync wp-content/uploads down from the source over SSH
# Enable either, both, or neither.
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

UPLOADS="${CMS_ROOT}/wp-content/uploads"

if [ "${FILES_PROXY}" = "true" ]; then
  require PROD_URL
  log "Files: proxy missing uploads -> ${PROD_URL}"
  conf="/etc/apache2/conf-enabled/apache-file-proxy.conf"
  sed "s#__PROD_URL__#${PROD_URL%/}#g" "${TUGBOAT_ROOT}/.tugboat/apache-file-proxy.conf" > "${conf}"
  # Ensure the proxy conf is included by the active vhost.
  if ! grep -q "apache-file-proxy.conf" /etc/apache2/sites-enabled/000-default.conf 2>/dev/null; then
    sed -i '/^<\/VirtualHost>/i \\tIncludeOptional conf-enabled/apache-file-proxy.conf' \
      /etc/apache2/sites-enabled/000-default.conf || true
  fi
  apachectl -k graceful 2>/dev/null || true
else
  log "Files: proxy disabled (FILES_PROXY=${FILES_PROXY})"
fi

if [ "${FILES_RSYNC}" = "true" ]; then
  require WPE_SSH WPE_REMOTE_PATH
  log "Files: rsync uploads down from ${WPE_SSH}"
  mkdir -p "${UPLOADS}"
  rsync -avzh --delete -e 'ssh -o StrictHostKeyChecking=no -o PubkeyAcceptedKeyTypes=+ssh-rsa' \
    "${WPE_SSH}:${WPE_REMOTE_PATH}/wp-content/uploads/" "${UPLOADS}/"
else
  log "Files: rsync disabled (FILES_RSYNC=${FILES_RSYNC})"
fi

# Permissions for whatever ended up on disk.
if [ -d "${UPLOADS}" ]; then
  chgrp -R www-data "${CMS_ROOT}/wp-content" 2>/dev/null || true
  find "${UPLOADS}" -type d -exec chmod 2775 {} \; 2>/dev/null || true
  find "${UPLOADS}" -type f -exec chmod 0664 {} \; 2>/dev/null || true
fi
