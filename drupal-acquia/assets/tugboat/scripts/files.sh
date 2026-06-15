#!/usr/bin/env bash
#
# files.sh — make production files available in the preview. Two independent,
# conditional strategies (set in tugboat.env):
#   FILES_PROXY=true  -> stage_file_proxy serves missing files from PROD_URL
#   FILES_RSYNC=true  -> drush rsync the files directory down from DRUSH_ALIAS
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
  require DRUSH_ALIAS
  log "Files: drush rsync ${DRUSH_ALIAS}:%files -> local"
  mkdir -p "${FILES_DIR}"
  ${DRUSH} rsync "${DRUSH_ALIAS}":%files @self:%files -y || true
else
  log "Files: rsync disabled (FILES_RSYNC=${FILES_RSYNC})"
fi

if [ -d "${FILES_DIR}" ]; then
  chgrp -R www-data "${FILES_DIR}" 2>/dev/null || true
  find "${FILES_DIR}" -type d -exec chmod 2775 {} \; 2>/dev/null || true
  find "${FILES_DIR}" -type f -exec chmod 0664 {} \; 2>/dev/null || true
fi
