#!/usr/bin/env bash
#
# pre-deploy.sh — project-specific steps to run BEFORE the build artifact is
# pushed to Pantheon.
#
# OWNED (seeded once, committed, survives updates) — yours to edit. dev-multidev
# runs this only if it exists; it ships empty (a no-op placeholder).
#
# Context when this runs (inside the deploy job, after Terminus auth, before
# build:env:push / build:env:create):
#   TERMINUS_SITE, TERMINUS_TOKEN, CI_BRANCH, DEFAULT_BRANCH are exported and
#   terminus is authenticated. The target environment ($TERMINUS_ENV) may not
#   exist on the platform yet, so prefer build-side checks here.
#
# Example — fail the deploy unless the theme actually compiled:
#   [ -f "${THEME_PATH}/dist/css/style.css" ] || { echo "theme not built"; exit 1; }
set -eo pipefail
