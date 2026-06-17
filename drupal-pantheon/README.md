# kanopi/composer-assets-drupal-pantheon

> [!IMPORTANT]
> **Read-only mirror.** This repository is a subtree split of
> [`kanopi/kanopi-assets`](https://github.com/kanopi/kanopi-assets) and is updated
> automatically. Issues are disabled and pull requests are closed automatically —
> **report issues and open pull requests on the
> [main `kanopi-assets` repository](https://github.com/kanopi/kanopi-assets).**

CircleCI deployment configuration for **Drupal on Pantheon**, built on the
Kanopi orbs (`kanopi/ci-tools`, `kanopi/cms-updates`). Pantheon uses Multidev
for preview/QA, so there is **no Tugboat** config here.

## Scaffolds

| Destination | Update policy | Purpose |
|---|---|---|
| `.circleci/config.yml` | replaced on update | Full workflow: phpcs/phpstan/rector/twig, compile→deploy→cypress/lighthouse/pa11y/sdtt/backstop, automated-updates, cron |
| `.circleci/env.sh` | **seed once** (`overwrite:false`) | The per-project fill-in file |
| `.circleci/scripts/compile-theme.sh` | replaced on update | Theme build (`npm ci` + `npm run $THEME_BUILD_COMMAND`) + asset staging |
| `.circleci/scripts/pantheon/dev-multidev` | replaced on update | Pantheon dev/multidev deploy |

The logic lives in the orbs and the shipped files; per-project values live only
in `env.sh`. **Bump the orb version or update this package to roll a fix to
every site.** To diverge, a site sets `".circleci/config.yml": false` (or the
script path) in its own `composer.json` and commits its own copy.

## Fill in `.circleci/env.sh`

`TERMINUS_SITE`, `PANTHEON_UUID`, `DEFAULT_BRANCH`, `DOCROOT`, `THEME_NAME`,
`THEME_PATH`. PHP/Node **versions** are pipeline parameters at the top of
`config.yml` (docker images resolve before `env.sh` can be sourced).

## Toggling stages

- **Theme build** — set `BUILD_THEME="false"` in `env.sh` for a theme-less /
  no-build site (the `compile-theme` job then skips `npm`; it also auto-skips
  when the theme has no `package.json`).
- **Post-deploy jobs** — `config.yml` exposes boolean pipeline parameters
  (`run_cypress`, `run_lighthouse`, `run_pa11y`, `run_sdtt`, `run_backstop`),
  all default `true`. Flip a default to `false` to skip that job. These are
  jobs, not steps, so they live in `config.yml`, not `env.sh` — CircleCI
  resolves the workflow before `env.sh` is sourced.

## Secrets (CircleCI `kanopi-code` context — never in the repo)

`TERMINUS_TOKEN`, `GITHUB_TOKEN`, `DOCKERHUB_USER`, `DOCKERHUB_PASS`,
`SLACK_WEBHOOK`. Add the deploy SSH key under **Project Settings → SSH Keys**.

## Scheduled pipelines

- **automatic updates** — name a CircleCI scheduled trigger `automatic updates`.
- **cron job …** — name a trigger starting with `cron job`; set the `cron_env`
  pipeline parameter to the target Pantheon env.
