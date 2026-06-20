#!/usr/bin/env bash
#
# install-quicksilver.sh — stage Pantheon Quicksilver scripts into the build
# artifact so they ship to Pantheon and the pantheon.yml hooks can find them.
#
# Gitignored + re-scaffolded by composer-assets, so the logic stays centrally
# maintained. Runs in the deploy job BEFORE the Pantheon artifact is assembled.
#
# Destination follows the project's docroot: Quicksilver script paths in
# pantheon.yml are relative to the repo root, so they must sit under web/private
# for a web-docroot site and private otherwise. We read `web_docroot` straight
# from the project pantheon.yml (grep — no YAML parser needed on the build
# image) to pick the right directory; the seeded pantheon.yml's hook paths match.
set -eo pipefail

SRC="$(dirname "${BASH_SOURCE[0]}")/quicksilver"
[ -d "${SRC}" ] || { echo "No Quicksilver scripts to install — skipping."; exit 0; }

if [ -f pantheon.yml ] && grep -Eq '^[[:space:]]*web_docroot:[[:space:]]*true' pantheon.yml; then
  DEST="web/private/scripts/quicksilver"
else
  DEST="private/scripts/quicksilver"
fi

echo "Installing Quicksilver scripts into ${DEST}/"
mkdir -p "${DEST}"
cp -v "${SRC}"/*.php "${DEST}/"
