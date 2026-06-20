# kanopi/composer-assets-drupal-acquia

> [!IMPORTANT]
> **Read-only mirror.** This repository is a subtree split of
> [`kanopi/kanopi-assets`](https://github.com/kanopi/kanopi-assets) and is updated
> automatically. Issues are disabled and pull requests are closed automatically —
> **report issues and open pull requests on the
> [main `kanopi-assets` repository](https://github.com/kanopi/kanopi-assets).**

CircleCI + Tugboat deployment configuration for **Drupal on Acquia**, on the
Kanopi orbs (`kanopi/ci-tools`, `kanopi/deploy`, `kanopi/cms-updates`).

## Scaffolds

**Committed, seeded once** (`overwrite:false, gitignore:false` — you own these):

| File | Purpose |
|---|---|
| `.circleci/config.yml` | static-tests (phpcs/phpstan/rector), deploy (`deploy/git` → Acquia), post_build_tests, automated-updates |
| `.circleci/env.sh` | per-project identity (`ACQUIA_REPO`, `ACQUIA_SITE_ID`, theme path) |
| `.tugboat/config.yml` | init/update/build orchestration |
| `.tugboat/tugboat.env` | non-secret Tugboat values (drush alias, PROD_URL) |
| `.tugboat/settings.local.php` | Drupal settings for the preview DB |

**Gitignored, re-scaffolded every install** (fixes flow automatically; to
customize, edit + set the path to `false` in your `composer.json` to take
ownership):

`.circleci/scripts/compile-theme.sh` (CI theme build, npm/yarn, in place),
`.tugboat/scripts/{common,install-tools,build,database,deploy}.sh`

## PHP & Node versions

Set the `php_version` pipeline parameter at the top of `.circleci/config.yml`
(used throughout) and the `tugboatqa/php:<tag>` image in `.tugboat/config.yml`.
Node is installed at runtime via nvm, so set `NODE_VERSION` (and
`NODE_PACKAGE_MANAGER`, `npm`/`yarn`) in `.circleci/env.sh` and `.tugboat/tugboat.env`.
Because those files are seeded once, your choices survive package updates.

## CircleCI env / secrets

Fill `.circleci/env.sh`. Secrets in the `kanopi-code` context: `GITHUB_TOKEN`,
`DOCKERHUB_USER`, `DOCKERHUB_PASS`, `SLACK_WEBHOOK`, `TUGBOAT_TOKEN`. The
`post_build_tests` workflow is triggered by Tugboat's `online` phase calling the
CircleCI API with `run_post_build_tests`, `target_url`, `tugboat_instance_id`.

## Toggling stages

- **Theme build** — set `BUILD_THEME="false"` in `env.sh` for a theme-less /
  no-build site (also auto-skips when the theme has no `package.json`).
- **Post-build jobs** — boolean pipeline parameters in `config.yml`
  (`run_cypress`, `run_lighthouse`, `run_pa11y`), all default `true`. Flip a
  default to `false` to skip that job. They live in `config.yml`, not `env.sh` —
  CircleCI resolves the workflow before `env.sh` is sourced.

## Tugboat

Fill `.tugboat/tugboat.env` and add the Acquia SSH key in the Tugboat dashboard
(Repository Settings → SSH Keys). `composer install` runs first in `init` so the
gitignored scripts materialize before they're called.
