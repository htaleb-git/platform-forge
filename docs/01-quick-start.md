# Quick Start

This guide installs Platform Forge on a fresh Ubuntu 24.04 server. It assumes
the Ansible controller can reach the server over SSH and has Ansible plus the
collections in `requirements.yml` available.

## 1. Prepare the Controller

Clone the repository and inspect the runner:

```bash
git clone <repository-url>
cd platform-forge
./scripts/run-playbook.sh --help
```

Install the collections on the controller if they are not already available:

```bash
ansible-galaxy collection install -r requirements.yml
```

## 2. Create an Inventory

Copy the example inventory. The example address is documentation-only; replace
it with the server address.

```bash
cp -a deploy/inventory/example deploy/inventory/my-platform
```

Edit these files:

```text
deploy/inventory/my-platform/hosts.yml
deploy/inventory/my-platform/group_vars/platform_nodes/main.yml
deploy/inventory/my-platform/group_vars/platform_nodes/vault.yml
```

In `hosts.yml`, set `ansible_host` and set `ansible_user` to the existing
Ubuntu installer/bootstrap account, for example `ubuntu-user`:

```yaml
platform01:
  ansible_host: 203.0.113.10
  ansible_user: ubuntu-user
  ansible_port: 22
```

Use `-i deploy/inventory/my-platform/hosts.yml` in every command below. The
repository default inventory remains the unmodified example.

## 3. Configure Access and Secrets

In `main.yml`, set a domain, choose an administrator key, and enable only the
applications and monitoring components you need. `platform_admin_authorized_keys`
contains paths to public key files **on this controller**, not paths on the
server:

```yaml
platform_domain: example.com
platform_admin_authorized_keys:
  - /path/to/id_ed25519.pub

n8n_enabled: true
nextcloud_enabled: false
wordpress_enabled: false
gitlab_enabled: false

node_exporter_enabled: true
cadvisor_enabled: true
prometheus_enabled: true
grafana_enabled: true
```

Generate a Linux password hash for `platform-admin` sudo/console use, then put
the output in `vault_platform_admin_password_hash` in `vault.yml`. It is not an
SSH password:

```bash
openssl passwd -6
```

Copy `vault.yml.example` to `vault.yml`, replace the required placeholders,
and encrypt it. See [Configuration and secrets](02-configuration.md) for the full
variable and Vault guidance.

```bash
cp deploy/inventory/my-platform/group_vars/platform_nodes/vault.yml.example \
  deploy/inventory/my-platform/group_vars/platform_nodes/vault.yml
ansible-vault encrypt deploy/inventory/my-platform/group_vars/platform_nodes/vault.yml
```

Choose TLS before deployment. For a private LAN, retain
`traefik_tls_mode: internal` and choose either Vault-provided material
(`traefik_internal_tls_source: provided`) or an opt-in generated self-signed
certificate (`traefik_internal_tls_source: generated`). Clients still need local
name resolution and must trust a self-signed certificate. For a public host,
set `traefik_tls_mode: acme`, set a real `traefik_acme_email`, and meet the
public DNS and port prerequisites in [Configuration and secrets](02-configuration.md).

## 4. Bootstrap the Server

Run server initialization. Add `--ask-pass` if the bootstrap account uses an
SSH password. The runner adds `-K`, so it also prompts for the bootstrap
account's sudo password.

```bash
./scripts/run-playbook.sh platform01 init \
  -i deploy/inventory/my-platform/hosts.yml \
  --ask-pass --ask-vault-pass
```

`01-init-server.yml` creates `platform-admin`, installs the configured public
keys, hardens SSH, and enables UFW.

Change `ansible_user` in `hosts.yml` to `platform-admin`. If you set
`platform_ssh_port`, also set `ansible_port` to that value. Verify key-based
SSH access in a separate terminal before discarding the bootstrap session:

```bash
ssh -p <ansible_port> platform-admin@<ansible_host>
```

## 5. Configure the Platform

Run the system playbook:

```bash
./scripts/run-playbook.sh platform01 system \
  -i deploy/inventory/my-platform/hosts.yml \
  --ask-vault-pass
```

It can require a reboot. Check on the server and reboot deliberately when the
file exists:

```bash
test -f /var/run/reboot-required && cat /var/run/reboot-required
```

After a reboot, confirm SSH access as `platform-admin`, then run the runtime
and enabled applications:

```bash
./scripts/run-playbook.sh platform01 runtime \
  -i deploy/inventory/my-platform/hosts.yml \
  --ask-vault-pass

./scripts/run-playbook.sh platform01 applications \
  -i deploy/inventory/my-platform/hosts.yml \
  --ask-vault-pass
```

Complete the web installer for each enabled Nextcloud or WordPress instance.
For Nextcloud, the browser installation is the first step only: rerun
`applications` after it completes so Platform Forge can apply its proxy
settings through `occ`.

## 6. Enable Monitoring and Backups

Deploy enabled monitoring components:

```bash
./scripts/run-playbook.sh platform01 monitoring \
  -i deploy/inventory/my-platform/hosts.yml \
  --ask-vault-pass
```

Configure and initialize the Restic repository before setting
`restic_enabled: true`. Platform Forge uses the configured repository; it does
not provision disks, NAS shares, SFTP accounts, or cloud storage. See
[Backup and restore](04-backup-restore.md).

Enable the desired application backup flags and Restic in `main.yml`, then
deploy backup timers and scripts:

```bash
./scripts/run-playbook.sh platform01 backup \
  -i deploy/inventory/my-platform/hosts.yml \
  --ask-vault-pass
```

Use `maintenance` for routine checks and `restore` only for a deliberate,
destructive recovery. Their procedures are documented in the linked guides.
