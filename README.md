# kanopi-assets

Shared, **CMS- and host-specific deployment configuration** for Kanopi projects,
distributed as [`kanopi/composer-assets`](../composer-assets) provider packages
and built on the Kanopi CircleCI orbs (`kanopi/ci-tools`, `kanopi/deploy`,
`kanopi/cms-updates`).

Onboarding a site becomes "require the right package + fill in one env file".
Fixes roll out across the fleet automatically: the heavy logic lives in the
orbs (pinned at the major version, so minor/patch fixes flow on every run) and
in the **scripts** (gitignored + re-scaffolded on every `composer install`).

## The matrix

| Package | CMS | Host | CircleCI deploy | Tugboat |
|---|---|---|---|:---:|
| `kanopi/composer-assets-drupal-pantheon`    | Drupal    | Pantheon  | Terminus build/multidev | — |
| `kanopi/composer-assets-drupal-acquia`      | Drupal    | Acquia    | `deploy/git`            | ✅ |
| `kanopi/composer-assets-drupal-custom`      | Drupal    | Custom    | `deploy/rsync` (git alt) | ✅ |
| `kanopi/composer-assets-wordpress-pantheon` | WordPress | Pantheon  | Terminus build/multidev | — |
| `kanopi/composer-assets-wordpress-wpengine` | WordPress | WP Engine | `deploy/rsync`          | ✅ |
| `kanopi/composer-assets-wordpress-custom`   | WordPress | Custom    | `deploy/rsync` (git alt) | ✅ |

Every stack deploys with **CircleCI**. Every host except **Pantheon** (which has
Multidev) also ships **Tugboat**. **Acquia** is Drupal-only; **WP Engine** is
WordPress-only.

## What gets scaffolded — and the update policy

Two intentionally different behaviors, modeled on Drupal scaffolding's
`settings.php` vs. managed files:

| Kind | Files | composer-assets mapping | Behavior |
|---|---|---|---|
| **Config / settings** (you own these) | `config.yml`, `env.sh`, `tugboat.env`, `settings.local.php`, `apache-file-proxy.conf`, `exclude-files.txt` | `overwrite:false, gitignore:false` | **Committed, seeded once.** Never clobbered on update. |
| **Scripts** (managed) | everything under `scripts/` | `gitignore:true` | **Gitignored, re-scaffolded every install.** Fixes flow automatically. |

To diverge from a managed script, a site edits it and adds `"<path>": false` to
its own `composer.json` `extra.composer-assets.file-mapping` (a skip), taking
ownership — exactly the `settings.php` pattern.

> Because scripts are gitignored, `composer install` (which triggers
> composer-assets) runs **first** in every CI job and as the first Tugboat
> `init` step, so the scripts exist before anything calls them.

## Per-project values & PHP version

- **`.circleci/env.sh`** (committed, seeded once) holds the per-project identity
  — site id, deploy targets, theme path, URLs. `config.yml` sources it and the
  scripts read it.
- **PHP / Node versions are CircleCI pipeline parameters** at the top of the
  (owned, seeded-once) `config.yml`, used throughout — images, orb tags,
  `cms-updates` php-version. Set once; survives updates. Tugboat's PHP is the
  `tugboatqa/php:<tag>` image in its owned `config.yml`.
- **Secrets never live in the repo** — they come from the CircleCI `kanopi-code`
  context (`TERMINUS_TOKEN`, `GITHUB_TOKEN`, `DOCKERHUB_*`, `SLACK_WEBHOOK`,
  `TUGBOAT_TOKEN`) and the Tugboat dashboard (SSH keys, DB passwords).

## Tugboat file handling

Each Tugboat package ships `scripts/files.sh` with two **independent,
conditional** strategies (set in `tugboat.env`):

| Variable | Default | Effect |
|---|---|---|
| `FILES_PROXY` | `true`  | Serve missing files from `PROD_URL` (Drupal `stage_file_proxy`; WordPress Apache file proxy) — no copy |
| `FILES_RSYNC` | `false` | rsync the files/uploads directory down from the source over SSH |

Enable either, both, or neither.

## Custom hosts

`drupal-custom` / `wordpress-custom` default to `deploy/rsync` (tag-gated:
`stage-*` → staging, `prod-*` → production) and include a **commented-out
`deploy/git` block** in the `build-deploy` workflow as an alternative.

## Using a package

```jsonc
{
    "repositories": {
        "kanopi-config": { "type": "vcs", "url": "git@github.com:kanopi/kanopi-assets.git" }
    },
    "require": {
        "kanopi/composer-assets": "^1",
        "kanopi/composer-assets-drupal-pantheon": "^1"
    },
    "config": { "allow-plugins": { "kanopi/composer-assets": true } },
    "extra": {
        "composer-assets": { "allowed-packages": ["kanopi/composer-assets-drupal-pantheon"] }
    }
}
```

```bash
composer install        # scaffolds .circleci/ (+ .tugboat/ for non-Pantheon)
```

Then fill in `.circleci/env.sh` (and `.tugboat/tugboat.env`), set the
`kanopi-code` context secrets, and commit the seeded config files. See each
package's `README.md` for its exact variables.

## Layout of each package

```
{cms}-{host}/
├── composer.json            # kanopi/composer-assets-{cms}-{host} + file-mapping
├── README.md
└── assets/
    ├── circleci/
    │   ├── config.yml        # → .circleci/config.yml         (committed, seeded once)
    │   ├── env.sh            # → .circleci/env.sh             (committed, seeded once)
    │   └── scripts/…         # → .circleci/scripts/…          (gitignored, replaced)
    └── tugboat/              # omitted for Pantheon
        ├── config.yml        # → .tugboat/config.yml          (committed, seeded once)
        ├── tugboat.env       # → .tugboat/tugboat.env         (committed, seeded once)
        ├── settings.local.php / apache-file-proxy.conf        (committed, seeded once)
        └── scripts/…         # → .tugboat/scripts/…           (gitignored, replaced)
```

## Publishing — monorepo split (Symfony-style)

This repo is a **monorepo**. Each package directory is mirrored read-only into
its own GitHub repo (`kanopi/composer-assets-{cms}-{host}`) so Composer can resolve a
dedicated package per stack — the same pattern Symfony uses to split
`src/Symfony/Component/*` into standalone component repos.

| Piece | Role |
|---|---|
| `split-packages.txt` | manifest: `<directory> <org/repo>` per package |
| `bin/monorepo-split.sh` | engine — `splitsh-lite` computes each subtree split, pushes it downstream |
| `.circleci/config.yml` | runs the split on `main` pushes and on tags |
| `bin/create-split-repos.sh` | one-time **local** `gh` helper: creates each downstream repo and locks it down read-only |
| `{pkg}/.github/workflows/close-pull-requests.yml` | shipped in each package; splits down and auto-closes PRs on the mirror |

**How it runs** (root `.circleci/config.yml`, `validate-and-split` workflow):

- **every branch & tag** → three lint gates run first:
  - `lint-circleci` — `circleci config validate` on the root config **and** all
    six package configs (orb-aware).
  - `lint-yaml` — `yamllint -c .yamllint.yml` over every `.yml`/`.yaml`
    (CircleCI + Tugboat), checking correctness (parse, duplicate keys), not style.
  - `lint-shell` — `shellcheck` (config in `.shellcheckrc`) over every script.
- **push to `main`** → after lint passes, force-push each package's subtree
  split to its downstream `main` (continuous mirror).
- **git tag `vX.Y.Z`** → after lint passes, push the split commit as that tag to
  every downstream repo, so `composer require kanopi/composer-assets-...:^X.Y` resolves.

The `split` job `requires` the three lint jobs, so a broken config or script
never propagates downstream. The Kanopi orbs are public, so the lint jobs need
no secrets; only `split` uses the `kanopi-code` context (for the downstream-push
`GITHUB_TOKEN`).

**Setup (once):**

1. `./bin/create-split-repos.sh` — run **locally** (needs interactive `gh` admin
   rights; CI never runs it). It creates each downstream repo and locks it down:
   issues, wiki, projects, discussions, and forking **disabled**, with the
   description/homepage pointing back here.
2. Add a `GITHUB_TOKEN` (PAT with push access to the downstream repos) to the
   CircleCI `kanopi-code` context.
3. Push `main`; tag a release (`git tag v1.0.0 && git push --tags`).

**Read-only enforcement.** Downstream repos are mirrors — never commit to them
directly; edit here and let the split propagate. GitHub has no switch to disable
pull requests, so each package ships `.github/workflows/close-pull-requests.yml`
(it splits down to the mirror root and auto-closes any PR with a pointer back
here), and every package README carries a read-only banner directing issues and
PRs to this repo — the same convention as
[`symfony/yaml`](https://github.com/symfony/yaml). Consuming sites point Composer
at the split repo (or a Satis/Packagist entry), not at this monorepo.

## Validating changes locally

The same three checks CI runs (`validate-and-split` → `lint-*` jobs):

```bash
# 1. CircleCI configs (root + every package), orb-aware
circleci config validate .circleci/config.yml
for f in */assets/circleci/config.yml; do circleci config validate "$f"; done

# 2. YAML correctness (uses .yamllint.yml)
yamllint -c .yamllint.yml $(find . \( -name '*.yml' -o -name '*.yaml' \) -not -path './.git/*')

# 3. Shell scripts (uses .shellcheckrc)
find . \( -name '*.sh' -o -name 'dev-multidev' \) -not -path './.git/*' -print0 | xargs -0 shellcheck
```
