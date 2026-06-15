#!/usr/bin/env bash
#
# files.sh — make production files available in the preview. Two independent,
# conditional strategies (set in tugboat.env):
#   FILES_PROXY=true  -> stage_file_proxy serves missing files from PROD_URL
#   FILES_RSYNC=true  -> rsync sites/default/files down from the source over SSH
# Enable either, both, or neither.
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

FILES_DIR="${CMS_ROOT}/sites/default/files"

if [ "${FILES_PROXY}" = "true" ]; then
  require PROD_URL
  log "Files: stage_file_proxy -> ${PROD_URL}"
  ${DRUSH} en stage_file_proxy -y || true
  ${DRUSH} config:set stage_file_proxy.settings origin "${PROD_URL}" -y || true
  ${DRUSH} config:set stage_file_proxy.settings hotlink 1 -y || true
  ${DRUSH} config:set stage_file_proxy.settings verify 0 -y || true
else
  log "Files: proxy disabled (FILES_PROXY=${FILES_PROXY})"
fi

if [ "${FILES_RSYNC}" = "true" ]; then
  require DB_SSH_USER DB_SSH_HOST FILES_REMOTE_PATH
  log "Files: rsync down from ${DB_SSH_HOST}:${FILES_REMOTE_PATH}"
  mkdir -p "${FILES_DIR}"
  rsync -avzh --delete \
    -e "ssh -o StrictHostKeyChecking=no -p ${DB_SSH_PORT}" \
    "${DB_SSH_USER}@${DB_SSH_HOST}:${FILES_REMOTE_PATH}/" "${FILES_DIR}/"
else
  log "Files: rsync disabled (FILES_RSYNC=${FILES_RSYNC})"
fi

if [ -d "${FILES_DIR}" ]; then
  chgrp -R www-data "${FILES_DIR}" 2>/dev/null || true
  find "${FILES_DIR}" -type d -exec chmod 2775 {} \; 2>/dev/null || true
  find "${FILES_DIR}" -type f -exec chmod 0664 {} \; 2>/dev/null || true
fi
