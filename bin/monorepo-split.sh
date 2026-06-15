#!/usr/bin/env bash
#
# monorepo-split.sh — split each package directory into its own GitHub repo,
# mirroring the Symfony monorepo approach (splitsh-lite computes a subtree split
# commit; we push it downstream). Read-only mirror: never edit the splits.
#
# Modes (auto-detected from the CircleCI environment):
#   - tag build   ($CIRCLE_TAG set) -> push the split commit as that tag to each
#                                       downstream repo (version propagation).
#   - branch build                  -> force-push the split commit to the
#                                       downstream branch ($SPLIT_BRANCH).
#
# Inputs:
#   split-packages.txt          manifest of "<dir> <org/repo>" lines
#   GITHUB_TOKEN                 PAT with push access to the downstream repos
#                                (set in the CircleCI "kanopi-code" context)
#   SPLIT_BRANCH                 downstream branch for branch builds (default: main)
#
# Requires: splitsh-lite on PATH (installed by .circleci/config.yml).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="${ROOT}/split-packages.txt"
SPLIT_BRANCH="${SPLIT_BRANCH:-main}"
TAG="${CIRCLE_TAG:-}"

: "${GITHUB_TOKEN:?Set GITHUB_TOKEN (PAT with downstream push access) in the kanopi-code context}"
command -v splitsh-lite >/dev/null || { echo "!! splitsh-lite not found on PATH" >&2; exit 1; }
[ -f "${MANIFEST}" ] || { echo "!! manifest not found: ${MANIFEST}" >&2; exit 1; }

git config --global --add safe.directory "${ROOT}" 2>/dev/null || true
# Ensure splitsh has full history to walk.
git -C "${ROOT}" fetch --tags --force --quiet origin || true

split_one() {
  local dir="$1" repo="$2" sha remote
  echo "==> Splitting '${dir}' -> ${repo}"
  sha="$(splitsh-lite --prefix="${dir}/")"
  [ -n "${sha}" ] || { echo "!! empty split SHA for ${dir}" >&2; return 1; }
  remote="https://x-access-token:${GITHUB_TOKEN}@github.com/${repo}.git"

  if [ -n "${TAG}" ]; then
    echo "    tag ${TAG} -> ${sha:0:12}"
    git push "${remote}" "${sha}:refs/tags/${TAG}"
  else
    echo "    ${SPLIT_BRANCH} -> ${sha:0:12}"
    git push --force "${remote}" "${sha}:refs/heads/${SPLIT_BRANCH}"
  fi
}

rc=0
while read -r dir repo _rest; do
  [ -z "${dir:-}" ] && continue
  case "${dir}" in \#*) continue ;; esac
  [ -d "${ROOT}/${dir}" ] || { echo "!! missing directory: ${dir}" >&2; rc=1; continue; }
  [ -n "${repo:-}" ] || { echo "!! no downstream repo for ${dir}" >&2; rc=1; continue; }
  split_one "${dir}" "${repo}" || rc=1
done < "${MANIFEST}"

exit "${rc}"
