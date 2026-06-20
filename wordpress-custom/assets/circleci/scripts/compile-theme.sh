#!/usr/bin/env bash
#
# compile-theme.sh — build the front-end theme assets, in place.
#
# Gitignored: shipped by composer-assets and (re)materialized on every
# `composer install`, so config.yml stays a thin caller and the build logic is
# maintained centrally. `composer install` MUST run before this script (that is
# what writes it).
#
# Node/Yarn are provided by the `ci-tools/install-node` orb command (nvm + the
# pinned NODE_VERSION + yarn via corepack), so this script only runs the build.
# It builds IN PLACE — the compiled assets ship with the rest of the working
# tree (rsync, Pantheon artifact, Acquia git commit), so there is no CircleCI
# workspace handoff and the output directory name (dist, css/js, …) no longer
# matters.
#
# Per-project values come from .circleci/env.sh:
#   THEME_PATH            — path to the theme (e.g. web/themes/custom/mytheme)
#   THEME_BUILD_COMMAND   — script to run (defaults to "build")
#   NODE_PACKAGE_MANAGER  — "npm" (default) or "yarn"
#   BUILD_THEME           — set "false" to skip the build entirely (default true)
set -eo pipefail

: "${THEME_PATH:?set THEME_PATH in .circleci/env.sh}"
BUILD_CMD="${THEME_BUILD_COMMAND:-build}"
PKG_MGR="${NODE_PACKAGE_MANAGER:-npm}"

if [ "${BUILD_THEME:-true}" = "false" ]; then
  echo "BUILD_THEME=false — skipping theme build."
  exit 0
fi

if [ ! -f "${THEME_PATH}/package.json" ]; then
  echo "No ${THEME_PATH}/package.json found — skipping theme build."
  exit 0
fi

echo "Building theme in ${THEME_PATH} (${PKG_MGR} run ${BUILD_CMD})"
case "${PKG_MGR}" in
  yarn)
    # Yarn 4 (berry) via corepack; --immutable is the lockfile-respecting CI mode.
    ( cd "${THEME_PATH}" && yarn install --immutable && yarn run "${BUILD_CMD}" )
    ;;
  *)
    ( cd "${THEME_PATH}" && npm ci && npm run "${BUILD_CMD}" )
    ;;
esac
