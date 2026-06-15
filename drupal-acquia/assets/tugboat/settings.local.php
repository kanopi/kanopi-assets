<?php

/**
 * @file
 * Tugboat-specific Drupal settings (committed, seeded once — own it per project).
 *
 * Copied into web/sites/default by .tugboat/scripts/build.sh. Points Drupal at
 * the Tugboat `mysql` service and relaxes a few things for preview environments.
 */

// Database — matches the `mysql` service in .tugboat/config.yml.
$databases['default']['default'] = [
  'database' => 'tugboat',
  'username' => 'tugboat',
  'password' => 'tugboat',
  'host' => 'mysql',
  'driver' => 'mysql',
  'port' => 3306,
  'prefix' => '',
];

// Tugboat injects the preview hostname; trust it.
$settings['trusted_host_patterns'] = ['.*'];

// Hash salt (preview-only; not a production secret).
$settings['hash_salt'] = 'tugboat-preview-not-a-secret';

// Config sync directory — adjust if your project differs.
$settings['config_sync_directory'] = '../config/sync';

// Memcached, if the service is enabled in config.yml.
if (extension_loaded('memcached')) {
  $settings['memcache']['servers'] = ['memcached:11211' => 'default'];
}

// Helpful while reviewing previews.
$config['system.logging']['error_level'] = 'verbose';
