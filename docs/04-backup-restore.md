# Backup and Restore

Platform Forge separates two layers:

1. Application backup jobs publish a current, versioned artifact generation
   under `platform_backup_root`.
2. Restic snapshots that backup root to the configured repository.

An application backup timer is not a substitute for a Restic snapshot. Enable
the application backup flags and `restic_enabled` only after the repository is
ready.

## Configure and Initialize Restic

Platform Forge uses the configured Restic repository. It does not provision a
disk, mount an NFS share, create an SFTP account, or create a cloud bucket.

Choose a location, initialize it with a Restic client using the same password
that will be stored in `vault_restic_password`, then configure it in inventory.
For example:

| Target | `restic_repository` example | Additional input |
|---|---|---|
| Local filesystem or mounted disk | `/mnt/platform-backups/restic` | Ensure the filesystem is mounted before scheduled jobs. |
| Mounted NAS/NFS filesystem | `/mnt/nas/platform-forge-restic` | Platform Forge does not create or mount the share. |
| SFTP/SSH | `sftp:backup@example.net:/srv/restic/platform-forge` | Prepare host-key and key access for the account used by scheduled root jobs. |
| S3-compatible object storage | `s3:https://s3.example.net/platform-forge` | Put the access key, secret, region, and endpoint settings in `restic_environment`. |

For a filesystem repository, initialize and verify it from a host with Restic
installed. Keep the password for this repository; use the same value later for
`vault_restic_password`:

```bash
export RESTIC_PASSWORD='choose-a-strong-password'
restic -r /mnt/platform-backups/restic init
restic -r /mnt/platform-backups/restic snapshots
unset RESTIC_PASSWORD
```

For remote and object storage, use the backend syntax and authentication
variables documented by Restic. Keep the mapping in Vault, then reference it
from `main.yml`:

```yaml
# main.yml
restic_environment: "{{ vault_restic_environment }}"
```

```yaml
# vault.yml
vault_restic_environment:
  AWS_ACCESS_KEY_ID: CHANGE_ME
  AWS_SECRET_ACCESS_KEY: CHANGE_ME
  AWS_DEFAULT_REGION: us-east-1
```

Use only variables required by the selected backend. Do not commit their real
values. A local repository is not an off-host backup.

Configure the matching repository and enable flags:

```yaml
backup_n8n_enabled: true
backup_nextcloud_enabled: false
backup_wordpress_enabled: false
backup_gitlab_enabled: false

restic_enabled: true
restic_repository: /mnt/platform-backups/restic
restic_retention:
  keep_daily: 7
  keep_weekly: 4
  keep_monthly: 12
```

Run the backup playbook:

```bash
./scripts/run-playbook.sh platform01 backup \
  -i deploy/inventory/my-platform/hosts.yml \
  --ask-vault-pass
```

It deploys application jobs, Restic jobs, and their systemd timers. The default
application schedules are staggered around 03:00; Restic runs at 04:00. Review
and adjust the schedule and retention variables for your environment.

## Check Backups

On the server, inspect timers and logs:

```bash
systemctl list-timers 'backup-*' --all
sudo systemctl start backup-n8n.service
sudo journalctl -u backup-n8n.service -n 100 --no-pager
sudo journalctl -u backup-restic.service -n 100 --no-pager
```

The maintenance playbook runs the configured Restic repository check when
Restic is enabled. Test recovery periodically; a successful backup job alone
does not prove recoverability.

## Application Backup Scope

| Application | Published artifacts |
|---|---|
| n8n | PostgreSQL dump |
| Nextcloud | `owncloud.db`, `config.php`, and `data.tar.gz` with user data; the archive excludes `owncloud.db` and `nextcloud.log` |
| WordPress | MariaDB SQL dump and `wp-content` archive |
| GitLab | Native GitLab backup, configuration, secrets, and version metadata |

## Restore

Restores are manual and destructive. First list snapshots using the configured
repository, choose one exact snapshot ID, then invoke the runner:

```bash
sudo bash -c 'set -a; . /etc/platform-forge/restic/environment; set +a; restic snapshots'

./scripts/run-playbook.sh platform01 restore nextcloud 0123456789abcdef \
  -i deploy/inventory/my-platform/hosts.yml \
  --ask-vault-pass
```

The runner accepts only `gitlab`, `nextcloud`, `n8n`, or `wordpress` and an
explicit hexadecimal snapshot ID. It rejects implicit selections such as
`latest`.

The workflow asks for `RESTORE`, then `ERASE-AND-RESTORE`. It stages the
selected snapshot outside live application data, validates it, restores the
selected application, and validates the result. A failed application restore
attempts to roll back the live state; if rollback fails, stop and perform
manual recovery from known-good artifacts.

After both confirmations, the protected restore command can remain silent for a
significant period while it downloads, validates, and replaces application
data. The runner prints a start notice, but does not stream protected command
output because it can contain sensitive information.

Nextcloud restore validates its data archive and restores the database,
configuration, and user data. GitLab recovery also requires a compatible
GitLab version. Keep n8n's original encryption key available before restoring
its database.
