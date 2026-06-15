#!/usr/bin/env bash
# =============================================================================
# .circleci/env.sh — non-secret, per-project values for WordPress on Pantheon.
# =============================================================================
# Fill in ONCE per project. Scaffolded overwrite:false, so it is never clobbered
# when the shared config is updated. config.yml sources it and the deploy script
# reads it. SECRETS (TERMINUS_TOKEN, GITHUB_TOKEN, DOCKERHUB_*, SLACK_WEBHOOK)
# go in the CircleCI "kanopi-code" context, NOT here.
# -----------------------------------------------------------------------------

# --- Pantheon site ---------------------------------------------------------
export TERMINUS_SITE="PANTHEON_SITE_MACHINE_NAME"
export PANTHEON_UUID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export DEFAULT_BRANCH="main"

# --- Code layout -----------------------------------------------------------
export DOCROOT="web"
export THEME_NAME="mytheme"
export THEME_PATH="web/wp-content/themes/mytheme"

# PHP / Node versions are pipeline parameters at the top of config.yml
# (docker images resolve before this file can be sourced).
