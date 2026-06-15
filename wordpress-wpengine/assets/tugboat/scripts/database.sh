#!/usr/bin/env bash
#
# database.sh — pull the WP Engine nightly DB backup over SSH and import it.
# Add the WP Engine SSH key in the Tugboat dashboard (Repository Settings -> SSH).
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

require WPE_SSH WPE_REMOTE_PATH

DB_DUMP="/tmp/wpe-db.sql"
log "Fetching nightly backup from ${WPE_SSH}"
rsync -avzh -e 'ssh -o StrictHostKeyChecking=no -o PubkeyAcceptedKeyTypes=+ssh-rsa' \
  "${WPE_SSH}:${WPE_REMOTE_PATH}/wp-content/mysql.sql" "${DB_DUMP}"

log "Importing into the Tugboat database"
${WP} db cli --skip-ssl < "${DB_DUMP}"
rm -f "${DB_DUMP}"

log "Database import complete."
