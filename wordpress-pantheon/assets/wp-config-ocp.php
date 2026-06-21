<?php
/**
 * wp-config-ocp.php — Object Cache Pro (OCP) configuration for Pantheon.
 *
 * Seeded once (overwrite:false) — owned by the site. This is Pantheon's
 * recommended WP_REDIS_CONFIG (OCP Config Version 2.0); `terminus install:run
 * <site>.<env> ocp` generates the same file. The license token comes from the
 * platform via getenv('OCP_LICENSE'), and the connection details from the
 * CACHE_* environment variables — so nothing secret is committed.
 *
 * Wire it up by requiring this file from wp-config.php, above the
 * "stop editing" line:
 *
 *   if ( file_exists( dirname( __FILE__ ) . '/wp-config-ocp.php' ) ) {
 *       require_once dirname( __FILE__ ) . '/wp-config-ocp.php';
 *   }
 *
 * Prerequisites (see the package README for the full walkthrough):
 *   - Redis enabled + `object_cache: { version: 6.2 }` in pantheon.yml.
 *   - The rhubarbgroup/object-cache-pro plugin installed.
 *   - The object-cache.php drop-in enabled and committed.
 */

/*
 * Pantheon OCP Config Version: 2.0
 */

$ocp_redis_prefix = 'ocppantheon';

define( 'WP_REDIS_CONFIG', [
	'token'             => getenv( 'OCP_LICENSE' ) ?: null,
	'host'              => getenv( 'CACHE_HOST' ) ?: '127.0.0.1',
	'port'              => getenv( 'CACHE_PORT' ) ?: 6379,
	'database'          => getenv( 'CACHE_DB' ) ?: 0,
	'password'          => getenv( 'CACHE_PASSWORD' ) ?: null,
	'maxttl'            => 86400 * 7,
	'retry_interval'    => 100,
	'split_alloptions'  => true,
	'prefetch'          => true,
	'debug'             => false,
	'save_commands'     => false,
	'analytics'         => [
		'enabled'   => true,
		'persist'   => false,
		'retention' => 3600, // 1 hour
		'footnote'  => true,
	],
	'prefix'            => $ocp_redis_prefix,
	'serializer'        => 'igbinary',
	'compression'       => 'zstd',
	'async_flush'       => true,
	'strict'            => true,
] );
