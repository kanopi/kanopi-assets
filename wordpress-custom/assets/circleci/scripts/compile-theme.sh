#!/usr/bin/env bash
#
# compile-theme.sh — build the front-end theme assets and stage them for deploy.
#
# Gitignored: shipped by composer-assets and (re)materialized on every
# `composer install`, so config.yml stays a thin caller and the build logic is
# maintained centrally. `composer install` MUST run before this script (that is
# what writes it); config.yml owns that step plus the CircleCI-native cache and
# persist_to_workspace steps that wrap the build.
#
# Per-project values come from .circleci/env.sh:
#   THEME_PATH           — path to the theme (e.g. web/themes/custom/mytheme)
#   THEME_BUILD_COMMAND  — npm script to run (defaults to "build")
#   BUILD_THEME          — set "false" to skip the build entirely (default true)
set -eo pipefail

: "${THEME_PATH:?set THEME_PATH in .circleci/env.sh}"
BUILD_CMD="${THEME_BUILD_COMMAND:-build}"

# The workspace dist dir always exists so persist_to_workspace and the deploy
# job's copy succeed even when the build is skipped (theme-less / no-build site).
mkdir -p /tmp/workspace/dist

if [ "${BUILD_THEME:-true}" = "false" ]; then
  echo "BUILD_THEME=false — skipping theme build."
  exit 0
fi

if [ ! -f "${THEME_PATH}/package.json" ]; then
  echo "No ${THEME_PATH}/package.json found — skipping theme build."
  exit 0
fi

echo "Building theme in ${THEME_PATH} (npm run ${BUILD_CMD})"
( cd "${THEME_PATH}" && npm ci && npm run "${BUILD_CMD}" )

# Stage compiled assets for jobs that hand off via the CircleCI workspace
# (Pantheon build/deploy split, Acquia git deploy). Harmless where unused.
if [ -d "${THEME_PATH}/dist" ]; then
  cp -vr "${THEME_PATH}/dist/." /tmp/workspace/dist/
fi
