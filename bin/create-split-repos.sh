#!/usr/bin/env bash
#
# create-split-repos.sh — LOCAL one-time setup for the downstream split repos.
# Run this by hand (it needs interactive `gh` admin rights); CI never runs it.
#
# For each entry in split-packages.txt it:
#   1. creates the GitHub repo if it does not exist,
#   2. locks it down as a READ-ONLY mirror — disables issues, wiki, projects,
#      discussions, and forking,
#   3. points its description + homepage at the main monorepo.
#
# GitHub has no API switch to disable pull requests, so two more pieces (shipped
# in the repo, not here) finish the job:
#   - .github/workflows/close-pull-requests.yml in each package auto-closes any
#     PR with a pointer to the main repo (it splits down to the mirror root),
#   - each package README carries a read-only banner (see github.com/symfony/yaml).
#
# Requires: gh CLI authenticated with admin rights on the target org.
#   ./bin/create-split-repos.sh                  # create as private
#   VISIBILITY=public ./bin/create-split-repos.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="${ROOT}/split-packages.txt"
MAIN_REPO="${MAIN_REPO:-kanopi/kanopi-assets}"
VISIBILITY="${VISIBILITY:-public}"

command -v gh >/dev/null || { echo "!! gh CLI not found" >&2; exit 1; }
[ -f "${MANIFEST}" ] || { echo "!! manifest not found: ${MANIFEST}" >&2; exit 1; }

lockdown() {
  local repo="$1" dir="$2"
  gh api --method PATCH "repos/${repo}" \
    -F has_issues=false \
    -F has_wiki=false \
    -F has_projects=false \
    -F has_discussions=false \
    -F allow_forking=false \
    -f description="[READ-ONLY] subtree split of ${MAIN_REPO}/${dir}. Report issues & open PRs at ${MAIN_REPO}." \
    -f homepage="https://github.com/${MAIN_REPO}" \
    >/dev/null
}

while read -r dir repo _rest; do
  [ -z "${dir:-}" ] && continue
  case "${dir}" in \#*) continue ;; esac

  if gh repo view "${repo}" >/dev/null 2>&1; then
    echo "exists:   ${repo}"
  else
    echo "create:   ${repo} (${VISIBILITY})"
    gh repo create "${repo}" "--${VISIBILITY}" \
      --description "[READ-ONLY] subtree split of ${MAIN_REPO}/${dir}."
  fi

  if lockdown "${repo}" "${dir}"; then
    echo "lockdown: ${repo} (issues/wiki/projects/discussions/forking disabled)"
  else
    echo "!! lockdown failed for ${repo} — check admin permissions" >&2
  fi
done < "${MANIFEST}"

echo
echo "Done. Pull requests are auto-closed by .github/workflows/close-pull-requests.yml"
echo "(shipped in each package and split down to the mirror)."
