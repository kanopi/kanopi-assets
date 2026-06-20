#!/usr/bin/env bash
#
# post-deploy.sh — project-specific steps to run AFTER the release tasks
# (drush deploy + cache clear) finish on the deployed environment.
#
# OWNED (seeded once, committed, survives updates) — yours to edit. dev-multidev
# runs this only if it exists; it ships empty (a no-op placeholder).
#
# Context when this runs (the deployed environment is live):
#   TERMINUS_SITE and TERMINUS_ENV are exported and terminus is authenticated,
#   so target the environment as "$TERMINUS_SITE.$TERMINUS_ENV".
#
# Example — run an extra drush command and warm the cache:
#   terminus -n drush "$TERMINUS_SITE.$TERMINUS_ENV" -- locale:update -y
#   terminus -n drush "$TERMINUS_SITE.$TERMINUS_ENV" -- cr
set -eo pipefail
