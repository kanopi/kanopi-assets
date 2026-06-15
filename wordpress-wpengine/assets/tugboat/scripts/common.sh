#!/usr/bin/env bash
#
# common.sh — shared config + helpers for Tugboat tasks (WordPress/WP Engine).
# Gitignored + re-scaffolded each install. Sourced first by every task.
set -euo pipefail

if [ -n "${TUGBOAT_ROOT:-}" ] && [ -f "${TUGBOAT_ROOT}/.tugboat/tugboat.env" ]; then
  # shellcheck disable=SC1091
  source "${TUGBOAT_ROOT}/.tugboat/tugboat.env"
fi

: "${CMS:=wordpress}"
: "${PROJECT_DOCROOT:=}"
: "${TABLE_PREFIX:=wp_}"
: "${BUILD_THEME:=true}"
: "${NODE_PACKAGE_MANAGER:=npm}"
: "${THEME_PATH:=}"
: "${THEME_BUILD_COMMAND:=build}"
: "${PROD_URL:=}"
: "${FILES_PROXY:=true}"
: "${FILES_RSYNC:=false}"
: "${WPE_SSH:=}"
: "${WPE_REMOTE_PATH:=}"

# Web root: repo root for classic WP, or $PROJECT_DOCROOT for Bedrock.
if [ -n "${PROJECT_DOCROOT}" ]; then
  CMS_ROOT="${TUGBOAT_ROOT}/${PROJECT_DOCROOT}"
else
  CMS_ROOT="${TUGBOAT_ROOT}"
fi
# shellcheck disable=SC2034  # consumed by scripts that source this file
WP="wp --allow-root --path=${CMS_ROOT}"

log() { echo "==> [$(basename "${0}")] $*"; }

require() {
  local missing=0 name
  for name in "$@"; do
    [ -n "${!name:-}" ] || { echo "!! Required variable '${name}' is not set." >&2; missing=1; }
  done
  [ "${missing}" -eq 0 ] || { echo "!! Set the above in tugboat.env or the dashboard." >&2; exit 1; }
}

ssh_src() { ssh -o StrictHostKeyChecking=no -o PubkeyAcceptedKeyTypes=+ssh-rsa "${WPE_SSH}" "$@"; }
