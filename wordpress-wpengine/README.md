# kanopi/composer-assets-wordpress-wpengine

> [!IMPORTANT]
> **Read-only mirror.** This repository is a subtree split of
> [`kanopi/kanopi-assets`](https://github.com/kanopi/kanopi-assets) and is updated
> automatically. Issues are disabled and pull requests are closed automatically —
> **report issues and open pull requests on the
> [main `kanopi-assets` repository](https://github.com/kanopi/kanopi-assets).**

CircleCI + Tugboat deployment configuration for **WordPress on WP Engine**, on
the Kanopi orbs (`kanopi/ci-tools`, `kanopi/deploy`, `kanopi/cms-updates`).

## Scaffolds

**Committed, seeded once** (`overwrite:false` — you own these):
`.circleci/config.yml`, `.circleci/env.sh`, `.circleci/exclude-files.txt`,
`.tugboat/config.yml`, `.tugboat/tugboat.env`, `.tugboat/apache-file-proxy.conf`.

**Gitignored, re-scaffolded each install:**
`.circleci/scripts/compile-theme.sh` (CI theme build + asset staging),
`.tugboat/scripts/{common,install-tools,build,database,files,deploy}.sh`.

## CircleCI

`deploy/rsync` to WP Engine, gated on git tags: `stage-*` → staging, `prod-*` →
production. The pipeline self-advances build → deploy → test via
`ci-tools/trigger-pipeline`. Fill remotes in `.circleci/env.sh`. Secrets in the
`kanopi-code` context. PHP/Node versions are pipeline parameters.

**Toggling stages:** set `BUILD_THEME="false"` in `env.sh` to skip the theme
build (also auto-skips with no `package.json`). The test jobs are boolean
pipeline parameters in `config.yml` — `run_backstop`, `run_lighthouse`,
`run_pa11y` (default `true`); flip a default to `false` to skip. Jobs live in
`config.yml`, not `env.sh` — CircleCI resolves the workflow before `env.sh` is
sourced.

## Tugboat — file handling

`files.sh` offers two independent, conditional strategies (set in `tugboat.env`):

| Variable | Default | Effect |
|---|---|---|
| `FILES_PROXY` | `true` | Serve missing `wp-content/uploads` from `PROD_URL` via `apache-file-proxy.conf` (no copy) |
| `FILES_RSYNC` | `false` | rsync `wp-content/uploads` down from the WP Engine source over SSH |

Enable either, both, or neither. The DB comes from the WP Engine nightly backup
over SSH (`database.sh`). Add the WP Engine SSH key in the Tugboat dashboard.

## Multisite

The network constants live in a committed, version-controlled
**`wp-config-multisite.php`** (seeded once, yours to edit) so every environment
shares one definition. Require it from `wp-config.php`, above the
"stop editing" line:

```php
require_once __DIR__ . '/wp-config-multisite.php';
```

On WP Engine (which owns `wp-config.php`) add that one `require` to the host's
config. The file resolves `DOMAIN_CURRENT_SITE` from `WP_MULTISITE_DOMAIN` →
request host → a hard-coded fallback, so it works on web and CLI. Edit
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
