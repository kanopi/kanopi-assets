#!/usr/bin/env bash
#
# database.sh — pull the source DB via a drush alias (Acquia) and import it into
# the Tugboat mysql service. Add the Acquia SSH key in the Tugboat dashboard.
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

require DRUSH_ALIAS

log "Dumping ${DRUSH_ALIAS} and importing into Tugboat"
# Stream a gzipped dump from the source alias straight into the local DB.
${DRUSH} "${DRUSH_ALIAS}" sql:dump --gzip --result-file=/tmp/source.sql 2>/dev/null || \
  drush "${DRUSH_ALIAS}" sql:dump --gzip --result-file=/tmp/source.sql

# rsync the dump down and import (skip TLS for the local mysql client).
drush rsync "${DRUSH_ALIAS}":/tmp/source.sql.gz @self:/tmp/source.sql.gz -y || true
mysql -h mysql -u tugboat -ptugboat --skip-ssl \
  -e "DROP DATABASE IF EXISTS tugboat; CREATE DATABASE tugboat;"
zcat /tmp/source.sql.gz | mysql -h mysql -u tugboat -ptugboat --skip-ssl tugboat

log "Database import complete."
