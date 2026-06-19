#!/usr/bin/env bash
#
# deploy.sh — per-preview finalize: rewrite the prod URL to the preview URL,
# apply db updates, flush caches. Runs in the `build` phase.
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

PREVIEW_URL="${TUGBOAT_DEFAULT_SERVICE_URL:-}"
strip_host() { printf '%s' "${1}" | sed -E 's#^[a-zA-Z][a-zA-Z0-9+.-]*://##; s#/.*$##'; }

if [ -z "${PROD_URL}" ] || [ -z "${PREVIEW_URL}" ]; then
  log "PROD_URL or preview URL unset; skipping search-replace"
elif [ "${WP_MULTISITE}" = "true" ]; then
  PREVIEW_HOST="$(strip_host "${PREVIEW_URL}")"
  # Read the network's current primary host straight from the DB (raw SQL, no WP
  # bootstrap) so this is robust even when wp-config and the DB disagree — e.g.
  # on the 2nd+ commit, where build.sh has reset the host but the DB already
  # holds the preview host. Falls back to PROD_URL's host on a fresh import.
  CURRENT_HOST="$(${WP} db query "SELECT domain FROM ${TABLE_PREFIX}site ORDER BY id ASC LIMIT 1;" \
    --skip-column-names --skip-ssl 2>/dev/null | tr -d '[:space:]')"
  CURRENT_HOST="${CURRENT_HOST:-$(strip_host "${PROD_URL}")}"
  # wp-config-multisite.php reads WP_MULTISITE_DOMAIN to set DOMAIN_CURRENT_SITE
  # for CLI (no HTTP host). Point it at the current DB host so wp-cli can boot.
  export WP_MULTISITE_DOMAIN="${CURRENT_HOST}"
  if [ "${CURRENT_HOST}" != "${PREVIEW_HOST}" ]; then
    log "Multisite search-replace ${CURRENT_HOST} -> ${PREVIEW_HOST} (network)"
    # Bare host covers every scheme and the wp_site/wp_blogs domain columns.
    ${WP} search-replace "${CURRENT_HOST}" "${PREVIEW_HOST}" --all-tables --network --report-changed-only || true
  else
    log "Multisite already points at ${PREVIEW_HOST}; nothing to replace."
  fi
  # DB now matches the preview host — repoint the CLI domain, then apply updates.
  export WP_MULTISITE_DOMAIN="${PREVIEW_HOST}"
  [ "${WP_MULTISITE_TYPE}" = "subdomain" ] && \
    log "NOTE: subdomain multisite on a single Tugboat host — only the primary site resolves; subsites need wildcard DNS."
  ${WP} core update-db --network || true
else
  log "search-replace ${PROD_URL} -> ${PREVIEW_URL}"
  ${WP} search-replace "${PROD_URL}" "${PREVIEW_URL}" --all-tables --report-changed-only || true
  ${WP} core update-db || true
fi

${WP} cache flush || true
${WP} rewrite flush || true

log "Deploy complete."
