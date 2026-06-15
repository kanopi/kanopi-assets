# kanopi/config-wordpress-custom

CircleCI + Tugboat deployment configuration for **WordPress on custom /
self-managed hosting** (any server reachable over SSH), on the Kanopi orbs.

## Scaffolds

**Committed, seeded once** (`overwrite:false`): `.circleci/config.yml`,
`.circleci/env.sh`, `.circleci/exclude-files.txt`, `.tugboat/config.yml`,
`.tugboat/tugboat.env`, `.tugboat/apache-file-proxy.conf`.

**Gitignored, re-scaffolded each install:**
`.tugboat/scripts/{common,install-tools,build,database,files,deploy}.sh`.

## CircleCI

Default deploy is `deploy/rsync`, tag-gated (`stage-*` → staging, `prod-*` →
production). A **`deploy/git` alternative is included commented out** in
`build-deploy`. Fill targets in `.circleci/env.sh`; secrets in `kanopi-code`.
Works for Composer-managed (Bedrock) and classic WordPress.

## Tugboat — file handling

`files.sh`, two independent conditionals (set in `tugboat.env`):

| Variable | Default | Effect |
|---|---|---|
| `FILES_PROXY` | `true` | Serve missing `wp-content/uploads` from `PROD_URL` via `apache-file-proxy.conf` |
| `FILES_RSYNC` | `false` | rsync `wp-content/uploads` down from `FILES_REMOTE_PATH` over SSH |

DB is streamed from the source over SSH (`database.sh`). Add the source host's
SSH key in the Tugboat dashboard.
