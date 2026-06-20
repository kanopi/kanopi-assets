#!/usr/bin/env bash
# =============================================================================
# .circleci/env.sh — non-secret, per-project values for Drupal on custom hosting.
# =============================================================================
# Seeded once (overwrite:false). Sourced by config.yml (`load-env`) and read by
# the deploy orbs. SECRETS (GITHUB_TOKEN, DOCKERHUB_*, SLACK_WEBHOOK,
# TUGBOAT_TOKEN) live in the CircleCI "kanopi-code" context, NOT here.
# -----------------------------------------------------------------------------

# --- Code layout -----------------------------------------------------------
export DOCROOT="web"
export THEME_PATH="web/themes/custom/mytheme"
export THEME_BUILD_COMMAND="build"
export BUILD_THEME="true"                      # set "false" for a theme-less / no-build site
export NODE_VERSION="20.11.0"                   # installed at runtime via nvm (ci-tools/install-node)
export NODE_PACKAGE_MANAGER="npm"              # "npm" or "yarn"

# --- rsync target: Production ----------------------------------------------
export DEPLOY_HOST_PROD="prod.example.com"
export DEPLOY_USER_PROD="deploy"
export DEPLOY_PORT_PROD="22"
export DEPLOY_PATH_PROD="/var/www/prod"

# --- rsync target: Staging -------------------------------------------------
export DEPLOY_HOST_STG="stg.example.com"
export DEPLOY_USER_STG="deploy"
export DEPLOY_PORT_STG="22"
export DEPLOY_PATH_STG="/var/www/stg"

# --- git deploy alternative (used only if you switch to deploy/git) --------
export DEPLOY_GIT_REMOTE="ssh://git@git.example.com/site.git"

# --- Post-build test targets -----------------------------------------------
export TEST_URL="https://stg.example.com/"
export REFERENCE_URL="https://www.example.com/"

# PHP version is a pipeline parameter at the top of config.yml (it selects the
# Docker image, resolved before this file is sourced). Node is installed at
# runtime via nvm, so NODE_VERSION lives above with the other project knobs.
