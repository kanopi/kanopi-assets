#!/usr/bin/env bash
#
# post-deploy.sh — project-specific steps to run AFTER the release tasks
# (wp core update-db + cache flush) finish on the deployed environment.
#
# OWNED (seeded once, committed, survives updates) — yours to edit. dev-multidev
# runs this only if it exists; it ships empty (a no-op placeholder).
#
# Context when this runs (the deployed environment is live):
#   TERMINUS_SITE and TERMINUS_ENV are exported and terminus is authenticated,
#   so target the environment as "$TERMINUS_SITE.$TERMINUS_ENV".
#
# Example — run an extra wp-cli command and flush again:
#   terminus -n wp "$TERMINUS_SITE.$TERMINUS_ENV" -- search-replace old.example new.example
#   terminus -n wp "$TERMINUS_SITE.$TERMINUS_ENV" -- cache flush
set -eo pipefail
