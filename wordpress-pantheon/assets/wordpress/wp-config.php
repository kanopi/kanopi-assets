<?php
/**
 * This config file is yours to hack on. It will work out of the box on Pantheon
 * but you may find there are a lot of neat tricks to be used here.
 *
 * Seeded once (overwrite:false) by kanopi/composer-assets-wordpress-pantheon —
 * owned by the site. wp-config-pantheon.php (Pantheon platform settings) and
 * wp-config-ocp.php (Object Cache Pro) are required below.
 *
 * See Pantheon's documentation for more details: https://pantheon.io/docs
 */

// Include for ddev-managed settings in wp-config-ddev.php.
$ddev_settings = dirname( __FILE__ ) . '/wp-config-ddev.php';

/**
 * Local configuration information.
 *
 * If you are working in a local/desktop development environment and want to
 * keep your config separate, we recommend using a 'wp-config-local.php' file,
 * which you should also make sure you .gitignore.
 */
if ( getenv('IS_DDEV_PROJECT') == 'true' && is_readable( $ddev_settings ) ) {
	require_once $ddev_settings;
/**
 * Pantheon platform settings. Everything you need should already be set.
 */
} elseif ( file_exists( dirname( __FILE__ ) . '/wp-config-pantheon.php' ) && isset( $_ENV['PANTHEON_ENVIRONMENT'] ) ) {
	require_once dirname( __FILE__ ) . '/wp-config-pantheon.php';
} elseif ( file_exists( dirname( __FILE__ ) . '/wp-config-local.php' ) && ! isset( $_ENV['PANTHEON_ENVIRONMENT'] ) ) {
	// IMPORTANT: ensure your local config does not include wp-settings.php
	require_once dirname( __FILE__ ) . '/wp-config-local.php';

	/**
	 * This block will be executed if you are NOT running on Pantheon and have NO
	 * wp-config-local.php. Insert alternate config here if necessary.
	 */
} else {
	define( 'DB_NAME', 'database_name' );
	define( 'DB_USER', 'database_username' );
	define( 'DB_PASSWORD', 'database_password' );
	define( 'DB_HOST', 'database_host' );
	define( 'DB_CHARSET', 'utf8' );
	define( 'DB_COLLATE', '' );
	define( 'AUTH_KEY', 'put your unique phrase here' );
	define( 'SECURE_AUTH_KEY', 'put your unique phrase here' );
	define( 'LOGGED_IN_KEY', 'put your unique phrase here' );
	define( 'NONCE_KEY', 'put your unique phrase here' );
	define( 'AUTH_SALT', 'put your unique phrase here' );
	define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );
	define( 'LOGGED_IN_SALT', 'put your unique phrase here' );
	define( 'NONCE_SALT', 'put your unique phrase here' );
}

/** Standard wp-config.php stuff from here on down. */

/**
 * WordPress Database Table prefix.
 */
$table_prefix = 'wp_';

/**
 * Object Cache Pro (Redis). Provides WP_REDIS_CONFIG before WordPress loads the
 * object-cache.php drop-in. Safe no-op until wp-config-ocp.php is seeded.
 */
if ( file_exists( dirname( __FILE__ ) . '/wp-config-ocp.php' ) ) {
	require_once dirname( __FILE__ ) . '/wp-config-ocp.php';
}

/**
 * Multisite (uncomment to enable). On Pantheon, define DOMAIN_CURRENT_SITE per
 * environment — see https://docs.pantheon.io/guides/multisite.
 */
// define( 'WP_ALLOW_MULTISITE', true );
// define( 'MULTISITE', true );
// define( 'SUBDOMAIN_INSTALL', false );
// $base = '/';
// define( 'PATH_CURRENT_SITE', '/' );
// define( 'SITE_ID_CURRENT_SITE', 1 );
// define( 'BLOG_ID_CURRENT_SITE', 1 );
// if ( ! empty( $_ENV['PANTHEON_ENVIRONMENT'] ) ) {
// 	switch ( $_ENV['PANTHEON_ENVIRONMENT'] ) {
// 		case 'live':
// 			define( 'DOMAIN_CURRENT_SITE', $_SERVER['HTTP_HOST'] );
// 			break;
// 		default:
// 			define( 'DOMAIN_CURRENT_SITE', $_ENV['PANTHEON_ENVIRONMENT'] . '-' . $_ENV['PANTHEON_SITE_NAME'] . '.pantheonsite.io' );
// 			break;
// 	}
// }

/* That's all, stop editing! Happy Pressing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', dirname( __FILE__ ) . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
