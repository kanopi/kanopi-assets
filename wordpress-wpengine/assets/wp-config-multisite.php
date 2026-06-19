<?php
/**
 * WordPress multisite (network) configuration — committed & version-controlled.
 *
 * Keeping the network constants here, instead of hand-editing each
 * environment's wp-config.php, keeps the definition identical across local,
 * Tugboat previews, staging and production.
 *
 * Wire it up by requiring this file from wp-config.php, ABOVE the
 * "That's all, stop editing!" line:
 *
 *     require_once __DIR__ . '/wp-config-multisite.php';
 *
 * On hosts that own wp-config.php (WP Engine, Pantheon), add that one require
 * to the host's wp-config.php. Tugboat previews include it automatically
 * (build.sh passes it to `wp config create --extra-php`).
 *
 * Seeded once (overwrite:false) — this file is yours to edit per project.
 */

/* ---- Network type -------------------------------------------------------- */
/* Flip SUBDOMAIN_INSTALL to true for a subdomain network; keep it in sync with
 * WP_MULTISITE_TYPE in .tugboat/tugboat.env. */
defined( 'WP_ALLOW_MULTISITE' ) || define( 'WP_ALLOW_MULTISITE', true );
defined( 'MULTISITE' )          || define( 'MULTISITE', true );
defined( 'SUBDOMAIN_INSTALL' )  || define( 'SUBDOMAIN_INSTALL', false );

/* ---- Primary network domain ---------------------------------------------- */
/* Resolution order, so one file works on every environment:
 *   1. DOMAIN_CURRENT_SITE, if a wrapper already defined it.
 *   2. WP_MULTISITE_DOMAIN env var — lets CLI contexts (wp-cli, which has no
 *      HTTP host) resolve to the right site; Tugboat's deploy.sh sets this.
 *   3. The current request host — covers web requests on any environment.
 *   4. A hard-coded fallback — edit this to your canonical production domain. */
if ( ! defined( 'DOMAIN_CURRENT_SITE' ) ) {
	$kanopi_ms_domain = getenv( 'WP_MULTISITE_DOMAIN' );
	if ( false === $kanopi_ms_domain || '' === $kanopi_ms_domain ) {
		if ( ! empty( $_SERVER['HTTP_HOST'] ) ) {
			$kanopi_ms_domain = preg_replace( '/:\d+$/', '', $_SERVER['HTTP_HOST'] );
		} else {
			$kanopi_ms_domain = 'www.example.com';
		}
	}
	define( 'DOMAIN_CURRENT_SITE', $kanopi_ms_domain );
	unset( $kanopi_ms_domain );
}

defined( 'PATH_CURRENT_SITE' )    || define( 'PATH_CURRENT_SITE', '/' );
defined( 'SITE_ID_CURRENT_SITE' ) || define( 'SITE_ID_CURRENT_SITE', 1 );
defined( 'BLOG_ID_CURRENT_SITE' ) || define( 'BLOG_ID_CURRENT_SITE', 1 );
