#!/usr/bin/env bash
#
# deploy.sh — per-preview finalize: rewrite the prod URL to the preview URL,
# apply db updates, flush caches. Runs in the `build` phase.
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

PREVIEW_URL="${TUGBOAT_DEFAULT_SERVICE_URL:-}"
if [ -n "${PROD_URL}" ] && [ -n "${PREVIEW_URL}" ]; then
  log "search-replace ${PROD_URL} -> ${PREVIEW_URL}"
  ${WP} search-replace "${PROD_URL}" "${PREVIEW_URL}" --all-tables --report-changed-only || true
else
  log "PROD_URL or preview URL unset; skipping search-replace"
fi

${WP} core update-db || true
${WP} cache flush || true
${WP} rewrite flush || true

log "Deploy complete."
