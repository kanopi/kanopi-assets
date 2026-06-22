# kanopi/composer-assets-wordpress-custom

> [!IMPORTANT]
> **Read-only mirror.** This repository is a subtree split of
> [`kanopi/kanopi-assets`](https://github.com/kanopi/kanopi-assets) and is updated
> automatically. Issues are disabled and pull requests are closed automatically —
> **report issues and open pull requests on the
> [main `kanopi-assets` repository](https://github.com/kanopi/kanopi-assets).**

CircleCI + Tugboat deployment configuration for **WordPress on custom /
self-managed hosting** (any server reachable over SSH), on the Kanopi orbs.

## Scaffolds

**Committed, seeded once** (`overwrite:false`): `.circleci/config.yml`,
`.circleci/env.sh`, `.circleci/exclude-files.txt`, `.tugboat/config.yml`,
`.tugboat/tugboat.env`, `.tugboat/apache-file-proxy.conf`.

**Gitignored, re-scaffolded each install:**
`.circleci/scripts/compile-theme.sh` (CI theme build, npm/yarn, in place),
`.tugboat/scripts/{common,install-tools,build,database,files,deploy}.sh`.

## CircleCI

Default deploy is `deploy/rsync`, tag-gated (`stage-*` → staging, `prod-*` →
production). A **`deploy/git` alternative is included commented out** in
`build-deploy`. Fill targets in `.circleci/env.sh`; secrets in `kanopi-code`.
Works for Composer-managed (Bedrock) and classic WordPress.

**Toggling stages:** set `BUILD_THEME="false"` in `env.sh` to skip the theme
build (also auto-skips with no `package.json`). The post-build jobs are boolean
pipeline parameters in `config.yml` — `run_lighthouse`, `run_pa11y` (default
`true`); flip a default to `false` to skip. Jobs live in `config.yml`, not
`env.sh` — CircleCI resolves the workflow before `env.sh` is sourced.

## Tugboat — file handling

`files.sh`, two independent conditionals (set in `tugboat.env`):

| Variable | Default | Effect |
|---|---|---|
| `FILES_PROXY` | `true` | Serve missing `wp-content/uploads` from `PROD_URL` via `apache-file-proxy.conf` |
| `FILES_RSYNC` | `false` | rsync `wp-content/uploads` down from `FILES_REMOTE_PATH` over SSH |

DB is streamed from the source over SSH (`database.sh`). Add the source host's
SSH key in the Tugboat dashboard.

## Multisite

The network constants live in a committed, version-controlled
**`wp-config-multisite.php`** (seeded once, yours to edit) so every environment
shares one definition. Require it from `wp-config.php`, above the
"stop editing" line:

```php
require_once __DIR__ . '/wp-config-multisite.php';
```

The file resolves `DOMAIN_CURRENT_SITE` from `WP_MULTISITE_DOMAIN` → request
host → a hard-coded fallback, so it works on web and CLI. Edit
`SUBDOMAIN_INSTALL` in it for a subdomain network.

For Tugboat previews, set `WP_MULTISITE=true` in `tugboat.env` (and
`WP_MULTISITE_TYPE=subdirectory|subdomain`). `build.sh` then includes
`wp-config-multisite.php` in the preview `wp-config.php` (via
`wp config create --extra-php`), and `deploy.sh` runs a network-aware
`search-replace` (bare host → preview host across `--all-tables`, so
`wp_site`/`wp_blogs` domains are rewritten too), feeding wp-cli the right
`DOMAIN_CURRENT_SITE` through `WP_MULTISITE_DOMAIN`. **Subdirectory** networks
map cleanly to a single preview host; **subdomain** networks only resolve the
primary site (subsites need wildcard DNS, which Tugboat doesn't provide by
default).

## Tugboat — phases

`composer install` and the theme build run on **every** preview build (the
`build` phase re-runs `build.sh`), so each commit's `composer.lock` and theme
assets are reflected — not just the cached snapshot. `composer install` honors
the lockfile (reproducible); it does not bump to newer releases (that would be
`composer update`).

## Code quality (PHPStan, Rector, PHPCS)

`phpstan.neon`, `rector.php`, and `phpcs.xml` are seeded once (`overwrite:false`)
at the repo root — yours to tune. Unlike Drupal, the scan paths are baked into the
configs (default `wp-content/themes/mytheme`); update them to your custom
theme(s)/plugin(s).

Add the tools and the `composer` scripts the CI runs (`phpcs`, `phpstan`,
`rector`) to your project `composer.json`:

```jsonc
"require-dev": {
    "rector/rector": "^2",
    "szepeviktor/phpstan-wordpress": "^2",
    "wp-coding-standards/wpcs": "^3"
},
"config": { "allow-plugins": {
    "dealerdirect/phpcodesniffer-composer-installer": true,
    "phpstan/extension-installer": true
} }
```

Optional: require `fsylum/rector-wordpress` for the WordPress-specific Rector set
(uncomment it in `rector.php`).
