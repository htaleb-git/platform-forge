# Applications

Applications are opt-in. Set the relevant `*_enabled` variable, provide its
required Vault values, run `applications`, then complete any documented web
setup.

```bash
./scripts/run-playbook.sh platform01 applications \
  -i deploy/inventory/my-platform/hosts.yml \
  --ask-vault-pass
```

Hostnames below are defaults; they derive from `platform_domain` and can be
overridden in inventory.

| Application | Enable variable | Default URL | First-run note |
|---|---|---|---|
| n8n | `n8n_enabled` | `https://n8n.example.com` | Create the initial n8n account in the web UI. |
| Nextcloud | `nextcloud_enabled` | `https://nextcloud.example.com` | Complete web installation, then rerun `applications`. |
| WordPress | `wordpress_enabled` | `https://wordpress.example.com` | Complete the WordPress web installer. |
| GitLab | `gitlab_enabled` | `https://gitlab.example.com` | Startup can take several minutes. |

## n8n

n8n is an automation platform backed by PostgreSQL. Preserve
`vault_n8n_encryption_key`: it is needed to use encrypted n8n credentials after
recovery. Its PostgreSQL password is
`vault_n8n_postgres_password`.

## Nextcloud

Nextcloud provides file, calendar, contact, and collaboration services. V1 uses
SQLite. The first deployment starts the container but does not complete the web
installer. Finish setup in the browser, then rerun the applications playbook so
trusted-proxy and URL settings can be applied with `occ`.

Its V1 backup covers SQLite, configuration, and user data. It excludes the
database file and Nextcloud log from the user-data archive because those are
handled separately.

## WordPress

WordPress provides a web site backed by MariaDB. Set both WordPress Vault
passwords, deploy the stack, then complete the site and administrator setup
through the web installer.

## GitLab

GitLab CE provides Git repositories and its web interface. It is optional and
more resource-intensive than the other applications. Allow time for its health
check after deployment. Its native backup and restore are version-sensitive;
use the same compatible GitLab version when recovering.

## Operations

Use the runner rather than direct Compose commands for normal lifecycle work:

```bash
./scripts/run-playbook.sh platform01 operation n8n status \
  -i deploy/inventory/my-platform/hosts.yml --ask-vault-pass

./scripts/run-playbook.sh platform01 operation nextcloud restart \
  -i deploy/inventory/my-platform/hosts.yml --ask-vault-pass
```

Replace the application with `gitlab`, `nextcloud`, `n8n`, or `wordpress`, and
the operation with `start`, `stop`, `restart`, or `status`.

Pinned images are the tested Platform Forge baseline. Platform Forge does not
orchestrate application or database migrations. Back up and follow each
application's upstream migration process before changing image versions.
