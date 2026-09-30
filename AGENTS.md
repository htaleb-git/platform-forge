# Platform Forge OpenCode Guardrails

These rules apply to every OpenCode session in this repository. They are
authoritative where tooling cannot enforce a rule technically.

## 1. Repository Boundary

OpenCode may read and modify files only inside the current Platform Forge
repository.

OpenCode must never create, modify, or delete files in any of these locations:

- `/tmp`
- `/var/tmp`
- `$HOME`
- `~/.ssh`
- `~/.config`
- `~/.ansible`
- `~/.docker`
- `/etc`
- `/srv`
- any path outside the current repository

An exception requires explicit user authorization for the exact action and
path. General authorization for a task is not authorization to write outside
the repository.

## 2. Git Ownership

The human user exclusively controls Git history and publication.

OpenCode must never:

- run `git commit`;
- run `git push`;
- run `git tag`;
- create a release;
- force push;
- modify a remote repository;
- publish to GitHub or another forge;
- initialize Git.

After Git is initialized by the user, OpenCode may run read-only Git commands
such as `git status`, `git diff`, `git log`, `git show`, `git branch --list`,
and `git remote -v`.

## 3. Deployment Ownership

The human user exclusively controls real deployments and infrastructure
operations.

OpenCode must never execute:

- `ansible-playbook` against a real or remote host;
- a deployment script against a real or remote host;
- Docker Compose operations on a remote host;
- SSH commands that mutate a remote system;
- restore operations against real infrastructure;
- maintenance operations against real infrastructure;
- application start, stop, restart, or reload operations against real
  infrastructure.

OpenCode may generate and statically validate deployment code. Generating
deployment code does not authorize its execution.

## 4. Ansible Check Mode

Ansible check mode and diff mode are not automatically safe.

Before proposing `ansible-playbook --check` or `--diff` against any remote
host, OpenCode must:

1. Inspect every affected role and task.
2. Identify commands and modules that may not safely support check mode.
3. Explain the expected remote effects and remaining uncertainty.
4. Wait for explicit user authorization for that exact execution.

OpenCode must never execute remote check mode autonomously.

## 5. Dependency Installation

Without explicit user authorization, OpenCode must not install or update:

- operating-system packages;
- Python packages;
- Ansible collections;
- Node packages;
- Docker packages or images;
- development tools.

OpenCode may inspect dependency manifests and report missing dependencies.

## 6. Secrets

OpenCode must never print, reproduce, or expose a discovered secret. Report
only the affected file and secret category.

OpenCode must never introduce real values for:

- passwords;
- password hashes;
- tokens;
- API keys;
- private keys;
- SSH keys;
- certificates containing private material;
- production credentials.

Public examples must use obvious placeholders such as `CHANGE_ME`, reserved
domains such as `example.com`, and RFC documentation addresses.

Real Ansible Vault files must never be created for this public repository.
Only clearly named example Vault templates containing placeholders may be
created.

## 7. Public Project Safety

Platform Forge is intended to be a public GitHub repository. Treat every
modification as potentially public.

Do not introduce:

- personal names;
- usernames from the source infrastructure;
- personal domains;
- private infrastructure hostnames;
- private infrastructure IP addresses;
- disk UUIDs;
- internal URLs;
- historical secrets;
- environment-specific identifiers.

Use `example.com` for domains and RFC 5737 or RFC 3849 documentation addresses
when examples require IP addresses.

## 8. Ansible Development

Before adding a role or variable, search the repository for an existing
equivalent. Reuse or refactor existing concepts where appropriate. Avoid
duplicate roles and variables.

Prefer:

- idempotent Ansible modules over shell commands;
- fully qualified collection names;
- explicit assertions for required inputs and invariants;
- safe, non-environment-specific defaults;
- least-privilege ownership, permissions, and service configuration;
- `no_log: true` for secret-bearing tasks where appropriate.

Do not add backward-compatibility aliases unless a concrete external or
persisted compatibility requirement exists.

## 9. Destructive Operations

Restore, delete, prune, cleanup, and destructive maintenance functionality
must fail closed. Require explicit inputs, validation, confirmation, bounded
paths, and post-operation checks as appropriate.

OpenCode may write and statically test destructive-operation code. It must
never execute destructive operations against real infrastructure.

## 10. Testing

The following are allowed without additional authorization when they are
strictly local and do not mutate anything outside the repository:

- syntax validation;
- `yamllint`;
- `ansible-lint`;
- `bash -n`;
- `shellcheck`;
- static searches;
- tests using repository-local fixtures.

Tests requiring any of the following require explicit user authorization
first:

- containers;
- package or collection installation;
- network access;
- remote hosts;
- external services;
- writes outside the repository.

Static validation must not be silently converted into deployment or runtime
validation.

## 11. Model Strategy

Choose the least expensive model suitable for the work:

- GPT-5.6 Sol: architecture, security-sensitive design, complex reasoning,
  critical implementation, and important design decisions.
- GPT-5.6 Terra: normal implementation and refactoring.
- GPT-5.6 Terra or Luna: mechanical corrections, lint fixes, tests, and small
  maintenance tasks.

Use Sol only when its additional reasoning is justified.

## 12. Human Checkpoints

At the end of every implementation phase, OpenCode must stop and report:

- files changed;
- tests executed and their results;
- remaining risks or unresolved questions.

OpenCode must not continue automatically to the next implementation phase.
The human user reviews and authorizes each phase before continuation.

## Conflict Handling

If a request conflicts with these guardrails, stop and identify the conflict.
Do not choose the broader or riskier interpretation. Request exact
authorization where an explicit exception is permitted.
