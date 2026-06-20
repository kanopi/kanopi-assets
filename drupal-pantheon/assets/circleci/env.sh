#!/usr/bin/env bash
# =============================================================================
# .circleci/env.sh — non-secret, per-project values for Drupal on Pantheon.
# =============================================================================
# Fill these in ONCE per project. composer-assets scaffolds this file with
# overwrite:false, so it is never clobbered when the shared config is updated.
# config.yml sources it (via ci-tools/set-variables / a `source` step) and the
# helper scripts read it, so every per-project value lives here — not in the
# workflow logic.
#
# SECRETS DO NOT GO HERE. Set TERMINUS_TOKEN, GITHUB_TOKEN, DOCKERHUB_USER,
# DOCKERHUB_PASS and SLACK_WEBHOOK in the CircleCI "kanopi-code" context.
# -----------------------------------------------------------------------------

# --- Pantheon site ---------------------------------------------------------
export TERMINUS_SITE="PANTHEON_SITE_MACHINE_NAME"
export PANTHEON_UUID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export DEFAULT_BRANCH="main"

# --- Code layout -----------------------------------------------------------
export DOCROOT="web"
export THEME_NAME="mytheme"
export THEME_PATH="web/themes/custom/mytheme"
export THEME_BUILD_COMMAND="build"            # script run by compile-theme.sh
export BUILD_THEME="true"                     # set "false" for a theme-less / no-build site
export NODE_VERSION="20.11.0"                  # installed at runtime via nvm; keep in sync with theme .nvmrc
export NODE_PACKAGE_MANAGER="npm"             # "npm" or "yarn"

# NOTE: PHP version is a CircleCI pipeline parameter at the top of config.yml
# (the docker image is resolved at config-compile time, before this file can be
# sourced). Node is installed at runtime via nvm, so NODE_VERSION lives here;
# keep it in sync with the theme's .nvmrc.
