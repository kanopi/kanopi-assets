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
| `.circleci/config.yml` | replaced on update | phpcs/phpstan, compile→deploy→cypress/lighthouse/pa11y/backstop, automated-updates, cron |
| `.circleci/env.sh` | **seed once** (`overwrite:false`) | per-project fill-in file |
| `.circleci/scripts/pantheon/dev-multidev` | replaced on update | Pantheon dev/multidev deploy (wp-cli release tasks) |

Per-project values live only in `env.sh`; the logic is in the orbs + shipped
files. Update the package (or bump the orb versions) to fix every site. To
diverge, a site sets `".circleci/config.yml": false` in its `composer.json` and
commits its own copy.

## Fill in `.circleci/env.sh`

`TERMINUS_SITE`, `PANTHEON_UUID`, `DEFAULT_BRANCH`, `DOCROOT`, `THEME_NAME`,
`THEME_PATH`. PHP/Node versions are pipeline parameters in `config.yml`.

## Secrets (CircleCI `kanopi-code` context)

`TERMINUS_TOKEN`, `GITHUB_TOKEN`, `DOCKERHUB_USER`, `DOCKERHUB_PASS`,
`SLACK_WEBHOOK`. Works for Composer-managed (Bedrock) and classic WordPress.
