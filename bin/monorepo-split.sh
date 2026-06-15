#!/usr/bin/env bash
#
# monorepo-split.sh — split each package directory into its own GitHub repo,
# mirroring the Symfony monorepo approach. Uses git's built-in `git subtree
# split` to compute a subtree commit, then pushes it downstream. Read-only
# mirror: never edit the splits.
#
# Modes (auto-detected from the CircleCI environment):
#   - tag build   ($CIRCLE_TAG set): push the split commit as that tag to each
#                                     downstream repo (version propagation).
#   - branch build                  : force-push the split commit to the
#                                     same-named branch downstream, THEN prune
#                                     any downstream branch that no longer exists
#                                     upstream (cleans up merged/deleted branches
#                                     — CircleCI gets no branch-delete event, so
#                                     this reconciles on the next run, e.g. the
#                                     main build after a PR merge).
#
# Inputs:
#   split-packages.txt          manifest of "<dir> <org/repo>" lines
#   downstream push auth        an SSH key (machine user with write access to the
#                               downstream repos) installed by ci-tools/copy-ssh-key
#                               in .circleci/config.yml
#
# Requires: git with `git subtree` (bundled with modern git; no external binary).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="${ROOT}/split-packages.txt"
TAG="${CIRCLE_TAG:-}"
BRANCH="${CIRCLE_BRANCH:-}"

[ -f "${MANIFEST}" ] || { echo "!! manifest not found: ${MANIFEST}" >&2; exit 1; }

# Push downstream over SSH (key installed by ci-tools/copy-ssh-key).
export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new"
git config --global --add safe.directory "${ROOT}" 2>/dev/null || true
git -C "${ROOT}" fetch --tags --force --quiet origin || true

remote_url() { printf 'git@github.com:%s.git' "$1"; }

# Authoritative list of upstream branch names (used to prune the downstream).
upstream_branches() { git ls-remote --heads origin | awk '{sub("refs/heads/","",$2); print $2}'; }

split_sha() {
  local sha
  sha="$(git -C "${ROOT}" subtree split --prefix="$1" 2>/dev/null | tail -n1 || true)"
  if ! printf '%s' "${sha}" | grep -Eq '^[0-9a-f]{40}$'; then
    echo "!! git subtree split produced no commit for '$1' (is 'git subtree' available?)" >&2
    return 1
  fi
  printf '%s' "${sha}"
}

push_tag() {
  local dir="$1" repo="$2" sha
  sha="$(split_sha "${dir}")" || return 1
  echo "    tag ${TAG} -> ${sha:0:12}"
  git push "$(remote_url "${repo}")" "${sha}:refs/tags/${TAG}"
}

push_branch() {
  local dir="$1" repo="$2" sha
  sha="$(split_sha "${dir}")" || return 1
  echo "    ${BRANCH} -> ${sha:0:12}"
  git push --force "$(remote_url "${repo}")" "${sha}:refs/heads/${BRANCH}"
}

prune_downstream() {
  local repo="$1" url ups b
  url="$(remote_url "${repo}")"
  ups="$(upstream_branches)"
  git ls-remote --heads "${url}" | awk '{sub("refs/heads/","",$2); print $2}' | while read -r b; do
    [ -z "${b}" ] && continue
    [ "${b}" = "main" ] && continue                       # never delete the default branch
    [ "${b}" = "${BRANCH}" ] && continue                  # keep the branch we just pushed
    if ! grep -qxF "${b}" <<<"${ups}"; then
      echo "    prune stale downstream branch: ${b}"
      git push "${url}" ":refs/heads/${b}" || echo "    (could not delete ${b}; continuing)"
    fi
  done
}

rc=0
while read -r dir repo _rest; do
  [ -z "${dir:-}" ] && continue
  case "${dir}" in \#*) continue ;; esac
  [ -d "${ROOT}/${dir}" ] || { echo "!! missing directory: ${dir}" >&2; rc=1; continue; }
  [ -n "${repo:-}" ] || { echo "!! no downstream repo for ${dir}" >&2; rc=1; continue; }

  echo "==> ${dir} -> ${repo}"
  if [ -n "${TAG}" ]; then
    push_tag "${dir}" "${repo}" || rc=1
  else
    [ -n "${BRANCH}" ] || { echo "!! no CIRCLE_BRANCH/CIRCLE_TAG set" >&2; exit 1; }
    push_branch "${dir}" "${repo}" || rc=1
    prune_downstream "${repo}" || true
  fi
done < "${MANIFEST}"

exit "${rc}"
