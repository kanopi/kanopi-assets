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
| `.circleci/scripts/pantheon/pre-deploy.sh` | **seed once** (`overwrite:false`) | Optional hook, runs before the artifact push (ships empty) |
| `.circleci/scripts/pantheon/post-deploy.sh` | **seed once** (`overwrite:false`) | Optional hook, runs after the release tasks (ships empty) |

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
