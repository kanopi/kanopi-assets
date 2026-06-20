<?php
/**
 * drush-deploy.php — Pantheon Quicksilver hook.
 *
 * Runs `drush deploy` after a code deploy to an environment, which performs
 * database updates, cache rebuild, config import and deploy hooks in the
 * correct order (the modern replacement for the manual updb/cr/cim dance).
 *
 * Gitignored + re-scaffolded by composer-assets, then staged into the build
 * artifact by install-quicksilver.sh. Wired in pantheon.yml under
 * workflows.deploy.after. Drupal only.
 */

// No need to trace this maintenance task in New Relic.
if (extension_loaded('newrelic')) {
  newrelic_ignore_transaction();
}

// Pantheon puts drush (Composer-managed Drupal) on PATH and runs the hook with
// the site's environment already selected; `drush deploy` resolves the docroot
// from the project. Stream output so it shows in the Pantheon workflow log.
passthru('drush deploy -y 2>&1', $exit_code);

exit((int) $exit_code);
