#!/usr/bin/env bash
# =============================================================================
# .circleci/env.sh — non-secret, per-project values for WordPress on WP Engine.
# =============================================================================
# Seeded once (overwrite:false). Sourced by config.yml (`load-env`) and read by
# the deploy/rsync orb. SECRETS (GITHUB_TOKEN, DOCKERHUB_*, SLACK_WEBHOOK,
# TUGBOAT_TOKEN) live in the CircleCI "kanopi-code" context, NOT here.
# -----------------------------------------------------------------------------

# --- Code layout -----------------------------------------------------------
export THEME_PATH="wp-content/themes/mytheme"
export THEME_BUILD_COMMAND="build"
export BUILD_THEME="true"                      # set "false" for a theme-less / no-build site
export NODE_VERSION="16.14.2"                   # installed at runtime via nvm (ci-tools/install-node)
export NODE_PACKAGE_MANAGER="npm"              # "npm" or "yarn"

# --- WP Engine: Production -------------------------------------------------
export WPE_REMOTE_HOST_PROD="myinstall.ssh.wpengine.net"
export WPE_REMOTE_USER_PROD="myinstall"
export WPE_REMOTE_PORT_PROD="22"
export WPE_REMOTE_PATH_PROD="/sites/myinstall"

# --- WP Engine: Staging ----------------------------------------------------
export WPE_REMOTE_HOST_STG="myinstallstg.ssh.wpengine.net"
export WPE_REMOTE_USER_STG="myinstallstg"
export WPE_REMOTE_PORT_STG="22"
export WPE_REMOTE_PATH_STG="/sites/myinstallstg"

# --- Automatic updates -----------------------------------------------------
export WPE_UPDATE_SITE_ID="myinstallstg"

# --- Post-build test targets (BackstopJS / Lighthouse / pa11y) -------------
export TEST_URL="https://myinstallstg.wpengine.com/"
export REFERENCE_URL="https://www.example.com/"

# PHP version is a pipeline parameter at the top of config.yml (it selects the
# Docker image, resolved before this file is sourced). Node is installed at
# runtime via nvm, so NODE_VERSION lives above with the other project knobs.
