# Example inventory

`hosts.yml` targets one documentation host in the generic `platform_nodes`
group. Add further hosts under that group when needed.

`group_vars/platform_nodes/main.yml` contains shared, non-secret deployment
choices: platform identity and paths, opt-in applications, monitoring
capabilities, backup capabilities, and component configuration. Application
backup flags publish validated generations below `platform_backup_root`
independently of Restic. `restic_enabled` remains false until the example
repository, schedules, retention, options, and optional backend environment
are reviewed. The configured repository must already be initialized. Secret
backend environment values should be moved to the Vault file rather than
committed in `main.yml`.

`group_vars/platform_nodes/vault.yml.example` documents only secrets consumed
by the current implementation. Copy it to `vault.yml`, replace every
`CHANGE_ME`, encrypt that file with Ansible Vault, and supply Vault access
explicitly when running Ansible. Never commit `vault.yml` or a Vault password
file.

Run a canonical playbook through the repository runner, for example:

```text
./scripts/run-playbook.sh platform01 system --check --diff
```

This inventory is a public contract example, not yet an end-to-end deployable
configuration. Restore selects and stages exact Restic snapshots in Phase 6.
