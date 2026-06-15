#!/usr/bin/env bash
#
# deploy.sh — per-preview finalize: drush deploy + optional Cypress test user.
# (File handling lives in files.sh.)
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

log "drush deploy"
if ${DRUSH} deploy -y; then :; else
  ${DRUSH} updatedb -y
  ${DRUSH} config:import -y || true
  ${DRUSH} cache:rebuild -y
fi

if [ "${BUILD_CYPRESS_USERS}" = "true" ]; then
  log "Creating Cypress test user"
  ${DRUSH} user:create cypress --mail="cypress@mailinator.com" --password="cypress" || true
  ${DRUSH} user:role:add administrator cypress || true
fi

${DRUSH} cache:rebuild -y
log "Deploy complete."
