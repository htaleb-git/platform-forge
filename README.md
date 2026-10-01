# Platform Forge

Platform Forge deploys a small self-managed application platform on one Ubuntu
24.04 server with Ansible. It is intended for individuals, homelabs,
developers, and small organizations.

V1 deploys an opt-in set of applications behind Traefik, with backups,
monitoring, restore, and maintenance workflows:

- n8n with PostgreSQL
- Nextcloud with SQLite
- WordPress with MariaDB
- GitLab CE
- Node Exporter, cAdvisor, Prometheus, and Grafana

The validated V1 sequence is:

```text
01-init-server -> 02-system -> 03-runtime -> 04-applications
-> 08-monitoring -> 05-backup
```

`06-restore` and `07-maintenance` are on-demand operations. Run every
playbook through `scripts/run-playbook.sh`; it requires an explicit target and
adds the sudo password prompt automatically.

## Start Here

1. [Quick start](docs/01-quick-start.md)
2. [Configuration and secrets](docs/02-configuration.md)
3. [Applications](docs/03-applications.md)
4. [Backup and restore](docs/04-backup-restore.md)
5. [Monitoring and maintenance](docs/05-monitoring-maintenance.md)
6. [Troubleshooting](docs/06-troubleshooting.md)
7. [V1 limitations](docs/07-limitations.md)

## Repository Layout

```text
deploy/inventory/  Inventory and per-environment variables
deploy/playbooks/  Canonical Ansible entry points
deploy/roles/      Implementation roles and their defaults
scripts/           The supported playbook runner
```

Container versions pinned in role defaults are the tested Platform Forge
baseline. Platform Forge does not perform application data or schema
migrations. Plan, back up, and follow the upstream migration procedure before
upgrading applications or their databases.

V1 is single-node. Storage provisioning, internal DNS, and internal TLS client
trust remain operator responsibilities. Never commit Vault files, private keys,
certificates, or passwords. Restores replace live application state and require
explicit confirmations.
