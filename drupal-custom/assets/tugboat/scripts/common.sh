#!/usr/bin/env bash
#
# common.sh — shared config + helpers for Tugboat tasks (Drupal/custom host).
# Gitignored + re-scaffolded each install. Sourced first by every task.
set -euo pipefail

if [ -n "${TUGBOAT_ROOT:-}" ] && [ -f "${TUGBOAT_ROOT}/.tugboat/tugboat.env" ]; then
  # shellcheck disable=SC1091
  source "${TUGBOAT_ROOT}/.tugboat/tugboat.env"
fi

: "${CMS:=drupal}"
: "${PROJECT_DOCROOT:=web}"
: "${BUILD_THEME:=true}"
: "${NODE_PACKAGE_MANAGER:=npm}"
: "${NODE_VERSION:=20.11.0}"
: "${NVM_DIR:=/usr/local/nvm}"
export NVM_DIR
# Put nvm's node/npm/yarn on PATH (install-tools.sh installs them). Skipped on
# first init before that runs. nvm.sh isn't `set -u` clean, so toggle it off.
if [ -s "${NVM_DIR}/nvm.sh" ]; then
  set +u
  # shellcheck disable=SC1091
  . "${NVM_DIR}/nvm.sh"
  set -u
fi
: "${THEME_PATH:=}"
: "${THEME_BUILD_COMMAND:=build}"
: "${PROD_URL:=}"
: "${FILES_PROXY:=true}"
: "${FILES_RSYNC:=false}"
: "${FILES_REMOTE_PATH:=}"
: "${DB_SSH_USER:=}"
: "${DB_SSH_HOST:=}"
: "${DB_SSH_PORT:=22}"
: "${DB_REMOTE_HOST:=127.0.0.1}"
: "${DB_REMOTE_NAME:=}"
: "${DB_REMOTE_USER:=}"
: "${DB_REMOTE_PASS:=}"
: "${BUILD_CYPRESS_USERS:=false}"

CMS_ROOT="${TUGBOAT_ROOT}/${PROJECT_DOCROOT}"
# shellcheck disable=SC2034  # consumed by scripts that source this file
DRUSH="${TUGBOAT_ROOT}/vendor/bin/drush --root=${CMS_ROOT}"

log() { echo "==> [$(basename "${0}")] $*"; }

require() {
  local missing=0 name
  for name in "$@"; do
    [ -n "${!name:-}" ] || { echo "!! Required variable '${name}' is not set." >&2; missing=1; }
  done
  [ "${missing}" -eq 0 ] || { echo "!! Set the above in tugboat.env or the dashboard." >&2; exit 1; }
}

ssh_src() {
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
      -p "${DB_SSH_PORT}" "${DB_SSH_USER}@${DB_SSH_HOST}" "$@"
}
