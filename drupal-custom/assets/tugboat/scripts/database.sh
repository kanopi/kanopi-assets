#!/usr/bin/env bash
#
# database.sh — stream the source DB over SSH (mysqldump) and import it into the
# Tugboat mysql service. Add the source host's SSH key in the Tugboat dashboard.
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

require DB_SSH_USER DB_SSH_HOST DB_REMOTE_NAME DB_REMOTE_USER DB_REMOTE_PASS

DUMP="/tmp/source.sql.gz"
log "Dumping ${DB_REMOTE_NAME} from ${DB_SSH_HOST}"
ssh_src "MYSQL_PWD='${DB_REMOTE_PASS}' mysqldump --single-transaction --no-tablespaces \
  --skip-lock-tables -h '${DB_REMOTE_HOST}' -u '${DB_REMOTE_USER}' '${DB_REMOTE_NAME}' | gzip -c" > "${DUMP}"

log "Importing into the Tugboat database"
mysql -h mysql -u tugboat -ptugboat --skip-ssl \
  -e "DROP DATABASE IF EXISTS tugboat; CREATE DATABASE tugboat;"
zcat "${DUMP}" | mysql -h mysql -u tugboat -ptugboat --skip-ssl tugboat
rm -f "${DUMP}"

log "Database import complete."
