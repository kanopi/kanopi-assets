#!/usr/bin/env bash
#
# create-split-repos.sh — one-time helper: create the downstream GitHub repos
# listed in split-packages.txt (the split job pushes to them but cannot create
# them). Requires the `gh` CLI, authenticated with repo-create rights.
#
#   ./bin/create-split-repos.sh            # create as private
#   VISIBILITY=public ./bin/create-split-repos.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="${ROOT}/split-packages.txt"
VISIBILITY="${VISIBILITY:-private}"

command -v gh >/dev/null || { echo "!! gh CLI not found" >&2; exit 1; }

while read -r dir repo _rest; do
  [ -z "${dir:-}" ] && continue
  case "${dir}" in \#*) continue ;; esac
  if gh repo view "${repo}" >/dev/null 2>&1; then
    echo "exists: ${repo}"
  else
    echo "create: ${repo} (${VISIBILITY})"
    gh repo create "${repo}" "--${VISIBILITY}" \
      --description "Read-only split of kanopi-assets/${dir} — do not edit directly."
  fi
done < "${MANIFEST}"
