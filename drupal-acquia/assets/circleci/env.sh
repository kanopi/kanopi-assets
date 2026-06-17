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

# PHP / Node versions are pipeline parameters at the top of config.yml.
