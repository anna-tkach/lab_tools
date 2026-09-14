# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

`_tools` is a collection of bash scripts (no build system, no package manager, no tests to run) that manage a personal/agency "Lab" directory structure and generate sandboxed environments for running coding agents (Claude Code) against individual repos. All comments and echo output in the scripts are written in Ukrainian; keep that convention when editing existing scripts.

There is no CI, linter, or test suite — validation happens by actually running the scripts and, for the sandbox, by the `permissions-check.tests` self-check described below.

## The Lab directory model

Everything is organized around one root directory (`LAB_ROOT_DIRECTORY`, default `~/lab`, overridable via `.env`) containing parallel "branches", each with the identical `owner/project/repo` structure but different content:

- `repo` — actual git repositories (what gets committed)
- `vault` — sensitive/encrypted material (currently: per-repo SSH deploy keys)
- `runners` — generated sandbox-runner files for each repo (not committed to the repo itself)

`owner` is either `own` or `clients/<client-id>`; a project can have multiple repos. This cascade is implemented by `new-item-create/owner.sh` → `project.sh` → `repo.sh`, each idempotently `mkdir -p`-ing its level in every branch before delegating down. `repo.sh` is the actual entry point used day-to-day:

```
sh new-item-create/repo.sh <owner> <project> <repo> <email>
```

Path construction is centralized in two utility files (sourced, never executed directly):
- `utils_subpaths_computing.sh` — turns `(owner[, project[, repo]])` into a relative subpath (e.g. `compute_repo_subpath own translator web-extension` → `own/translator/web-extension`); `client-x` owners get prefixed with `clients/`.
- `utils_paths_computing.sh` — combines a subpath with `LAB_ROOT_DIRECTORY` and a branch name to get an absolute path. Note: `[owner]` and `[project]` level paths do **not** depend on branch, but `[repo]` level paths do (`.../repo_subpath/<branch>`).

When adding a new path-computing helper, follow the existing naming pattern: `compute_<subject>_[sub]path[_by_<input>]`.

## The sandboxed env-runner

`repo.sh` step 2 calls `env-runner/new-repo-create.sh`, which generates a set of runner files under `runners/.../<repo>/<method>/` for **every** method listed in `env-runner/constants.sh` (`ENV_RUNNER_METHODS`). Currently only `apple-sandbox` is implemented; `docker` is an intentional stub (`impl/docker/docker-run.sh` is a placeholder) — do not treat it as a gap to fill unprompted.

Generated files are created from templates in `env-runner/impl/<method>/new-repo-create/templates/` via `sed` substitution, not a templating engine. Placeholder tokens in a template (e.g. `{{REPO_ABSOLUTE_PATH}}`) must exactly match a `*_TEMPLATES_VAR_*` constant defined in that method's `constants.sh` — if you rename one side, you must rename the other, or the substitution silently no-ops and a literal `{{...}}` token ships into the generated file. Existing generated files are never overwritten (`create_file_if_needed` skips if the target already exists) — delete the generated file under `runners/` manually to force regeneration.

### Runtime flow

Each generated per-repo `run.sh` (from `templates/run.sh`) is a thin wrapper that `cd`s into the repo, sets `HOME`/`PATH` to the sandbox's own values, and delegates to the shared `env-runner/run.sh`:

```
env-runner/run.sh --method=<method> --profile=<path.sb> --tests=<path.tests> -- <command> [args...]
```

`run.sh` dispatches to `env-runner/impl/<method>/<method>-run.sh`, which is the actual isolation implementation. For `apple-sandbox`, that script:
1. Wraps everything in one `sandbox-exec -f <profile.sb> bash -c "..."` call — the self-check and the final command run in the **same** sandboxed bash process (sandbox-exec confines one process + its children, so splitting into two `sandbox-exec` invocations would not share the restriction).
2. Inside that sandbox, first runs `permission-inside-selfcheck.sh <tests-file>` — this validates that the `.sb` profile actually grants/denies what it claims (reads `description|command|expected` lines, expected is `allow` or `deny`) **before** trusting the sandbox with a real session.
3. Only on self-check success does it `exec` the final command (e.g. `claude`), replacing the bash process so sandbox constraints persist into it.

If you edit `permission-profile.sb`, always add/update a matching line in `permissions-check.tests` — an allow/deny rule with no corresponding test is unverified.

### Editing the sandbox profile template

`env-runner/impl/apple-sandbox/new-repo-create/templates/permission-profile.sb` is Apple Seatbelt syntax (`(version 1)`, default-deny baseline via `(import "system.sb")`). Key things to know before touching it:
- A `subpath` rule grants access within a tree, not to its ancestors — resolving an absolute path stats every parent directory, so non-standard roots (outside `/usr`, `/bin`) need explicit `file-read-metadata` on each ancestor directory.
- `.instructions/` inside a repo is explicitly denied (`deny file-read* file-write*` on the whole subpath) — it holds human-only docs (e.g. how to attach the SSH remote) and must stay invisible to the sandboxed agent. 
- Seatbelt filters `network-outbound` by IP/port only, not domain — there is no way to restrict egress to specific hosts (e.g. api.anthropic.com) from this profile alone.
- Some binaries (`sudo`, `su`, `osascript`, `launchctl`, `dscl`, `csrutil`, `pbpaste`) are explicitly denied as defense-in-depth even though most would fail anyway (missing IPC/Keychain access); `/usr/bin/security` is deliberately **not** denied because Claude Code spawns it internally and denying it prevents Claude from launching — the Keychain itself is still unreachable via the filesystem/IPC rules.

## SSH deploy key generation

`repo.sh` step 3 calls `keys/ssh/generate/repo-remote-connection/ssh-key-repo-remote-connection-generate.sh`, which generates an `ed25519` deploy key pair into the repo's `vault` branch (via `ssh-key-generate.sh`) and writes a human-readable connection-instructions markdown file into the repo's `.instructions/` folder (from `templates/ssh-remote-connection.md`, same `sed`-substitution pattern as the sandbox templates).

`ssh-key-generate.sh` enforces that the generated private key is passphrase-protected: after `ssh-keygen` runs, it checks whether the key can be read back with an empty passphrase, and if so, deletes both key files and fails — an unencrypted key in `vault/` is treated as a hard error, not a warning.

## Conventions when adding scripts

- Every script sources its own `constants.sh` (if one exists at its level) using a `SCRIPT_DIR`/`BASH_SOURCE[0]`-derived path, never a hardcoded or relative-to-cwd path — scripts must work regardless of caller's cwd.
- `set -euo pipefail` at the top of any script that performs multi-step work with side effects.
- Higher-level scripts pass fully-resolved absolute paths down to lower-level ones; a module never hardcodes knowledge (like the `.instructions` folder name) that belongs to a higher-level caller — it receives that as a parameter instead.
- Idempotency: creation scripts (`mkdir -p`, `create_file_if_needed`) are safe to re-run and skip work that's already done, logging `[SKIP]`/`[OK]` rather than failing.
