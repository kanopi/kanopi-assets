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

# PHP / Node versions are pipeline parameters at the top of config.yml.
