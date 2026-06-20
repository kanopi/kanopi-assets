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
export THEME_BUILD_COMMAND="build"            # script run by compile-theme.sh
export BUILD_THEME="true"                     # set "false" for a theme-less / no-build site
export NODE_VERSION="20.11.0"                  # installed at runtime via nvm; keep in sync with theme .nvmrc
export NODE_PACKAGE_MANAGER="npm"             # "npm" or "yarn"

# PHP version is a pipeline parameter at the top of config.yml (the docker image
# resolves before this file can be sourced). Node is installed at runtime via
# nvm, so NODE_VERSION lives here with the other project knobs.
