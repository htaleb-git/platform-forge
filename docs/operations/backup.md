# Opération — Backup

## Principe

La plateforme possède deux chaînes complémentaires.

### HomeLab

```text
Ansible → scripts/services/timers → artefact applicatif → Restic → BACKUPS01
```

### VPS

```text
Ansible
  ↓
backup applicatif VPS
  ↓
/srv/vps/backups/<app>
  ↓ SSH / rrsync read-only
HomeLab /srv/homelab/backups/vps01/<app>
  ↓
Restic HomeLab
```

## Déployer HomeLab

```bash
./scripts/run-playbook.sh hml bkp
```

## Déployer VPS

```bash
./scripts/run-playbook.sh vps bkp
```

Ciblage :

```bash
./scripts/run-playbook.sh vps bkp --tags backup_n8n
./scripts/run-playbook.sh vps bkp --tags backup_nextcloud
./scripts/run-playbook.sh vps bkp --tags backup_wordpress
```

## Backups manuels VPS

```bash
sudo systemctl start backup-n8n.service
sudo systemctl start backup-nextcloud.service
sudo systemctl start backup-wordpress.service
```

## Timers déclaratifs

Convention :

```text
true  → enabled + started
false → disabled + stopped
```

La tâche `Disable ... timer` garantit la convergence : si un backup est désactivé dans l'inventory, un timer précédemment actif est réellement arrêté.

## Logs

```bash
journalctl -u backup-n8n.service -n 100 --no-pager
journalctl -u backup-nextcloud.service -n 100 --no-pager
journalctl -u backup-wordpress.service -n 100 --no-pager
journalctl -u backup-remote-collect.service -n 100 --no-pager
```

## WordPress

Artefacts :

```text
/srv/vps/backups/wordpress/wordpress.sql
/srv/vps/backups/wordpress/wp-content.tar.gz
```

Le dump est logique ; le répertoire MariaDB brut n'est pas sauvegardé à chaud.

## Nextcloud

Artefacts V1 :

```text
owncloud.db
config.php
```

## Observabilité

Backups applicatifs :

```text
backup_last_status
backup_last_run_timestamp
backup_last_success_timestamp
backup_last_duration_seconds
```

Collecte distante :

```text
backup_remote_collect_status
backup_remote_collect_timestamp
backup_remote_collect_duration_seconds
```

Cela permet de distinguer un backup réussi sur le VPS d'une réplication distante échouée.

## Sécurité

- secrets via Vault ;
- repository Restic chiffré ;
- accès de collecte VPS en lecture seule ;
- groupe `backup-readers` pour les artefacts exportables ;
- restore jamais planifié.
