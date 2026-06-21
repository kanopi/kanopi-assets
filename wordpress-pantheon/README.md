# kanopi/composer-assets-wordpress-pantheon

> [!IMPORTANT]
> **Read-only mirror.** This repository is a subtree split of
> [`kanopi/kanopi-assets`](https://github.com/kanopi/kanopi-assets) and is updated
> automatically. Issues are disabled and pull requests are closed automatically —
> **report issues and open pull requests on the
> [main `kanopi-assets` repository](https://github.com/kanopi/kanopi-assets).**

CircleCI deployment configuration for **WordPress on Pantheon**, built on the
Kanopi orbs (`kanopi/ci-tools`, `kanopi/cms-updates`). Pantheon uses Multidev
for preview/QA, so there is **no Tugboat** config here.

## Scaffolds

| Destination | Update policy | Purpose |
|---|---|---|
| `.circleci/config.yml` | replaced on update | phpcs/phpstan, deploy→cypress/lighthouse/pa11y/backstop, automated-updates, cron |
| `.circleci/env.sh` | **seed once** (`overwrite:false`) | per-project fill-in file |
| `.circleci/scripts/compile-theme.sh` | replaced on update | Theme build (npm/yarn `$THEME_BUILD_COMMAND`), in place — runs in the deploy job before the Pantheon artifact is built |
| `.circleci/scripts/pantheon/dev-multidev` | replaced on update | Pantheon dev/multidev deploy (wp-cli release tasks) |
| `.circleci/scripts/pantheon/pre-deploy.sh` | **seed once** (`overwrite:false`) | Optional CI hook, runs before the artifact push (ships empty) |
| `.circleci/scripts/pantheon/post-deploy.sh` | **seed once** (`overwrite:false`) | Optional CI hook, runs after the release tasks (ships empty) |
| `{web/private,private}/scripts/quicksilver/new_relic_deploy.php` | **seed once** (`overwrite:false`) | Quicksilver hook: record the deploy in New Relic |
| `{web,.}/wp-config.php` | **seed once** (`overwrite:false`) | Main WordPress config — yours to hack on; requires the two below |
| `{web,.}/wp-config-pantheon.php` | replaced on update (`overwrite:true`) | Pantheon platform settings — maintained centrally, do not modify |
| `{web,.}/wp-config-ocp.php` | **seed once** (`overwrite:false`) | Object Cache Pro config (Pantheon's recommended `WP_REDIS_CONFIG`) |
| `pantheon.yml` | **seed once** (`overwrite:false`) | Platform config + Quicksilver `deploy` hook (skipped if you already have one) |

The three `wp-config*.php` files, the Quicksilver script, and `pantheon.yml` are
placed by composer-assets **conditional** mapping: next to the `web/` docroot
when it exists, else at the repo root — and the matching `pantheon.yml` variant
(`web_docroot: true` vs not) is seeded with paths to match. No deploy-time staging.

`wp-config.php` requires `wp-config-pantheon.php` (platform settings) and
`wp-config-ocp.php` (Object Cache Pro) for you, so the config works as a set out
of the box. `wp-config-pantheon.php` is `overwrite:true` (re-applied on update,
drift-checked) — treat it as read-only; put site changes in `wp-config.php`.

Per-project values live only in `env.sh`; the logic is in the orbs + shipped
files. Update the package (or bump the orb versions) to fix every site. To
diverge, a site sets `".circleci/config.yml": false` in its `composer.json` and
commits its own copy.

## Fill in `.circleci/env.sh`

`TERMINUS_SITE`, `PANTHEON_UUID`, `DEFAULT_BRANCH`, `DOCROOT`, `THEME_NAME`,
`THEME_PATH`, `NODE_VERSION`, `NODE_PACKAGE_MANAGER` (`npm`/`yarn`). The **PHP**
version is a pipeline parameter in `config.yml` (the image resolves before
`env.sh` is sourced); **Node** is installed at runtime via nvm, so `NODE_VERSION`
lives in `env.sh`.

## Deploy hooks

`pre-deploy.sh` and `post-deploy.sh` (seeded once, committed, **yours to edit**)
let you customize the deploy without forking `dev-multidev`. They ship empty and
run only if present — `pre-deploy.sh` before the artifact is pushed,
`post-deploy.sh` after the wp-cli release tasks, with `$TERMINUS_SITE.$TERMINUS_ENV`
in scope and terminus authenticated.

These are **CI-side** hooks (CircleCI deploys to dev/multidev). For **platform**
deploys (dev→test→live promotions), see Quicksilver below.

## Quicksilver hooks

`pantheon.yml` registers a `workflows.deploy.after` hook that runs **on Pantheon**
after every code deploy — including dashboard promotions that never touch CI:

- **`new_relic_deploy.php`** — records a deploy marker in New Relic. Requires the
  site secret: `terminus secret:site:set <site> new_relic_api_key <key>`.

composer-assets seeds the script and `pantheon.yml` under `web/private/` when a
`web/` docroot exists, else `private/` (conditional mapping on `exists: web`), so
the hook path always resolves and the script ships in the committed artifact —
no deploy-time staging. **If your project already has a `pantheon.yml`**, the
seeded one is skipped — copy its `workflows` block in by hand.

## Object Cache Pro (Redis)

The package ships Pantheon's recommended `WP_REDIS_CONFIG` (OCP Config v2.0) as
**`wp-config-ocp.php`**, seeded next to `wp-config.php` (`web/` when a web docroot
exists, else repo root). The license token and connection details come from the
platform (`OCP_LICENSE`, `CACHE_*` env vars), so nothing secret is committed and
it works on every environment without `terminus install:run ocp`.

To enable it:

1. **Redis on + version 6.2** — already set via `object_cache: { version: 6.2 }`
   in the seeded `pantheon.yml`; enable the add-on with `terminus redis:enable <site>`.
2. **Require the config** from `wp-config.php`, above the "stop editing" line:

   ```php
   if ( file_exists( dirname( __FILE__ ) . '/wp-config-ocp.php' ) ) {
       require_once dirname( __FILE__ ) . '/wp-config-ocp.php';
   }
   ```
3. **Install the plugin** (composer-managed): add the OCP Composer repo + license,
   then `composer require rhubarbgroup/object-cache-pro` (see the
   [Pantheon OCP guide](https://docs.pantheon.io/object-cache/wordpress)).
4. **Enable the drop-in**: activate the plugin and enable it (creates
   `object-cache.php`), then **commit `object-cache.php`** so it reaches test/live:

   ```bash
   terminus connection:set <site>.<env> sftp
   terminus wp -- <site>.<env> plugin activate object-cache-pro
   terminus wp -- <site>.<env> redis enable
   terminus env:commit <site>.<env> --message="Add Object Cache Pro drop-in"
   terminus connection:set <site>.<env> git
   ```
5. **On first promotion to test/live**, flush the cache:
   `terminus wp <site>.<env> -- cache flush` (disable any old `wp-redis` first).

Local dev (DDEV/Lando) may lack `igbinary`/`zstd`; override `serializer`/`compression`
to `php`/`none` locally, or set `WP_REDIS_DISABLED` — see the Pantheon guide.

## Toggling stages

- **Theme build** — set `BUILD_THEME="false"` in `env.sh` for a theme-less /
  no-build site (also auto-skips when the theme has no `package.json`).
- **Post-deploy jobs** — boolean pipeline parameters in `config.yml`
  (`run_cypress`, `run_lighthouse`, `run_pa11y`, `run_backstop`), all default
  `true`. Flip a default to `false` to skip that job. They live in `config.yml`,
  not `env.sh` — CircleCI resolves the workflow before `env.sh` is sourced.

## Secrets (CircleCI `kanopi-code` context)

`TERMINUS_TOKEN`, `GITHUB_TOKEN`, `DOCKERHUB_USER`, `DOCKERHUB_PASS`,
`SLACK_WEBHOOK`. Works for Composer-managed (Bedrock) and classic WordPress.
