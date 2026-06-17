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
export THEME_BUILD_COMMAND="build"            # npm script run by compile-theme.sh
export BUILD_THEME="true"                     # set "false" for a theme-less / no-build site

# NOTE: PHP / Node versions are CircleCI pipeline parameters at the top of
# config.yml (docker images are resolved at config-compile time, before this
# file can be sourced). Keep them in sync with pantheon.yml and .nvmrc.
