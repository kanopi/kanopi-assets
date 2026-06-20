#!/usr/bin/env bash
# =============================================================================
# .circleci/env.sh — non-secret, per-project values for Drupal on Acquia.
# =============================================================================
# Seeded once (overwrite:false); never clobbered on update. Sourced by config.yml
# (the `load-env` command) and read by the orb deploy steps. SECRETS
# (GITHUB_TOKEN, DOCKERHUB_*, SLACK_WEBHOOK, TUGBOAT_TOKEN) live in the CircleCI
# "kanopi-code" context, NOT here.
# -----------------------------------------------------------------------------

# --- Acquia ----------------------------------------------------------------
export ACQUIA_SITE_ID="mysite"
export ACQUIA_REPO="mysite@svn-1234.prod.hosting.acquia.com:mysite.git"

# --- Code layout -----------------------------------------------------------
export DOCROOT="docroot"                       # Acquia's Drupal docroot
export THEME_NAME="mytheme"
export THEME_PATH="docroot/themes/custom/mytheme"
export THEME_BUILD_COMMAND="build:prod"
export BUILD_THEME="true"                       # set "false" for a theme-less / no-build site
export NODE_VERSION="20.17.0"                    # installed at runtime via nvm (ci-tools/install-node)
export NODE_PACKAGE_MANAGER="npm"               # "npm" or "yarn"

# PHP version is a pipeline parameter at the top of config.yml (it selects the
# Docker image, resolved before this file is sourced). Node is installed at
# runtime via nvm, so NODE_VERSION lives here with the rest of the project knobs.
