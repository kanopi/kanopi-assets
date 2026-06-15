# kanopi/composer-assets-drupal-custom

> [!IMPORTANT]
> **Read-only mirror.** This repository is a subtree split of
> [`kanopi/kanopi-assets`](https://github.com/kanopi/kanopi-assets) and is updated
> automatically. Issues are disabled and pull requests are closed automatically —
> **report issues and open pull requests on the
> [main `kanopi-assets` repository](https://github.com/kanopi/kanopi-assets).**

CircleCI + Tugboat deployment configuration for **Drupal on custom /
self-managed hosting** (any server reachable over SSH), on the Kanopi orbs.

## Scaffolds

**Committed, seeded once** (`overwrite:false`): `.circleci/config.yml`,
`.circleci/env.sh`, `.circleci/exclude-files.txt`, `.tugboat/config.yml`,
`.tugboat/tugboat.env`, `.tugboat/settings.local.php`.

**Gitignored, re-scaffolded each install:**
`.tugboat/scripts/{common,install-tools,build,database,files,deploy}.sh`.

## CircleCI

Default deploy is `deploy/rsync`, tag-gated (`stage-*` → staging, `prod-*` →
production). A **`deploy/git` alternative is included commented out** in
`build-deploy` — uncomment it and comment the rsync jobs if the host deploys via
git. Fill targets in `.circleci/env.sh`; secrets in the `kanopi-code` context.

## Tugboat — file handling

`files.sh`, two independent conditionals (set in `tugboat.env`):

| Variable | Default | Effect |
|---|---|---|
| `FILES_PROXY` | `true` | `stage_file_proxy` serves missing files from `PROD_URL` |
| `FILES_RSYNC` | `false` | rsync `sites/default/files` down from `FILES_REMOTE_PATH` over SSH |

DB is streamed from the source over SSH (`database.sh`). Add the source host's
SSH key in the Tugboat dashboard. Automatic updates are not wired for custom
hosts (no managed update target) — handle dependency updates via PRs.
