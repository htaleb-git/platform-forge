# Configuration and Secrets

The example inventory is the reference configuration:

```text
deploy/inventory/example/hosts.yml
deploy/inventory/example/group_vars/platform_nodes/main.yml
deploy/inventory/example/group_vars/platform_nodes/vault.yml.example
```

Copy it to a private inventory directory under `deploy/inventory/` and pass
that inventory using `-i`. Do not commit `vault.yml`.

## Access

The initial `ansible_user` is the Ubuntu account that already exists on the
server. `01-init-server.yml` creates `platform-admin`; change the inventory to
that account after bootstrap.

`platform_admin_authorized_keys` is a list of **local controller paths** to
public SSH key files. The bootstrap playbook verifies and reads those files on
the controller, then installs their contents for `platform-admin`.

```yaml
platform_admin_user: platform-admin
platform_admin_authorized_keys:
  - /path/to/id_ed25519.pub
```

Generate `vault_platform_admin_password_hash` on the controller with a
SHA-512 crypt hash:

```bash
openssl passwd -6
```

Put the output in `vault.yml`:

```yaml
vault_platform_admin_password_hash: '$6$CHANGE_ME'
```

This hash sets the local account password used for console login and `sudo`.
It is **not** an SSH password. Bootstrap disables SSH password and keyboard
interactive authentication; use the configured public key for SSH.

## Vault

`vault.yml.example` lists the currently consumed secrets. Copy it, replace
only the variables required by enabled features, and encrypt it:

```bash
cp deploy/inventory/my-platform/group_vars/platform_nodes/vault.yml.example \
  deploy/inventory/my-platform/group_vars/platform_nodes/vault.yml
ansible-vault encrypt deploy/inventory/my-platform/group_vars/platform_nodes/vault.yml
```

Pass `--ask-vault-pass` to the runner, or use your established local Vault
password-file workflow. Never version a Vault password file or decrypted Vault.

Required secrets by feature:

| Feature | Vault variables |
|---|---|
| Bootstrap | `vault_platform_admin_password_hash` |
| n8n | `vault_n8n_encryption_key`, `vault_n8n_postgres_password` |
| WordPress | `vault_wordpress_db_password`, `vault_wordpress_mariadb_root_password` |
| Restic | `vault_restic_password` |
| Internal TLS with `traefik_internal_tls_source: provided` | `vault_traefik_tls_private_key`, `vault_traefik_tls_certificate` |

## Platform Variables

Set the basic identity in `main.yml`:

```yaml
platform_admin_user: platform-admin
platform_domain: example.com
platform_timezone: Etc/UTC
platform_root: /srv/platform-forge
```

Application hostnames default to `n8n`, `nextcloud`, `wordpress`, `gitlab`,
and `grafana` below `platform_domain`. Override an individual hostname only
when needed. Enable each capability explicitly:

```yaml
n8n_enabled: true
nextcloud_enabled: true
wordpress_enabled: false
gitlab_enabled: false

node_exporter_enabled: true
cadvisor_enabled: true
prometheus_enabled: true
grafana_enabled: true
```

Grafana requires Prometheus. Application backups require their application to
be enabled.

## TLS

For a private LAN, use `traefik_tls_mode: internal`. Choose one explicit source:

```yaml
# Keep operator-provided certificate/key material in Vault.
traefik_tls_mode: internal
traefik_internal_tls_source: provided
```

```yaml
# Generate one self-signed certificate on the managed host.
traefik_tls_mode: internal
traefik_internal_tls_source: generated
```

Generated material is retained on normal reruns. The private key stays on the
managed host, and its certificate SANs cover the platform hostname and enabled
service hostnames. Platform Forge does not configure local DNS/hosts files or
client trust; arrange both before using the service. To replace generated
material after a hostname change, deliberately remove the existing certificate
and key on the server, then rerun `runtime`.

For a publicly reachable domain, set `traefik_tls_mode: acme` and provide a
real `traefik_acme_email`. Traefik obtains certificates with Let's Encrypt ACME
HTTP-01. Before deployment, ensure every enabled hostname has a public A
record; publish an AAAA record only when IPv6 reaches the same host. TCP ports
80 and 443 must reach Traefik through any router/NAT, cloud firewall, and host
firewall, and must not be occupied by another service. Bootstrap permits the
configured Traefik HTTP/HTTPS ports in host UFW; configure any external firewall
as well. Wait for DNS propagation. Platform Forge does not configure DNS.

## Paths and Versions

By default, application definitions, persistent data, and published backup
artifacts are below:

```text
/srv/platform-forge/apps
/srv/platform-forge/data
/srv/platform-forge/backups
```

Role defaults contain exact pinned container images. Treat them as the tested
Platform Forge baseline, not as an automatic upgrade policy. Upgrades to
GitLab, Nextcloud, PostgreSQL, MariaDB, or other application data formats can
require application-specific migrations outside Platform Forge.

## Restic Inputs

Set `restic_enabled: true` only after selecting and initializing a repository.
Set `restic_repository` to the repository location and keep backend credentials
in `restic_environment` when the backend needs them. `vault_restic_password`
protects the repository password. See [Backup and restore](04-backup-restore.md).
