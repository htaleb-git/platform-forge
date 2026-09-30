# Référence — Playbooks

| Playbook | Portée | État |
|---|---|---|
| `01-init-server.yml` | bootstrap Ubuntu, SSH, UFW | ✅ |
| `02-network-homelab.yml` | réseau HomeLab | ✅ |
| `02-network-vps.yml` | réseau / règles VPS | ✅ |
| `03-system.yml` | système et paquets | ✅ |
| `04-runtime.yml` | Docker runtime, réseaux, stockage, Traefik | ✅ |
| `05-applications.yml` | applications HomeLab + VPS selon cible/tags | ✅ |
| `06-backup-homelab.yml` | Restic + backups HomeLab + collecte distante | ✅ |
| `06-backup-vps.yml` | accès remote + backups n8n/Nextcloud/WordPress | ✅ |
| `07-operations.yml` | start / stop / restart / status | ✅ |
| `08-restore-homelab.yml` | restores HomeLab | ✅ |
| `08-restore-vps.yml` | restores VPS | ✅ |
| `09-maintenance.yml` | maintenance système + health checks | ✅ |
| `10-monitoring.yml` | Node Exporter, cAdvisor, Prometheus, Grafana | ✅ |

## Applications VPS

```bash
./scripts/run-playbook.sh vps app --tags n8n
./scripts/run-playbook.sh vps app --tags nextcloud
./scripts/run-playbook.sh vps app --tags wordpress
```

## Backups VPS

```bash
./scripts/run-playbook.sh vps bkp --tags backup_n8n
./scripts/run-playbook.sh vps bkp --tags backup_nextcloud
./scripts/run-playbook.sh vps bkp --tags backup_wordpress
```

## Collecte distante sur HomeLab

```bash
./scripts/run-playbook.sh hml bkp --tags backup_remote_collect
```

## HomeLab / Immich

```bash
./scripts/run-playbook.sh hml app --tags immich
./scripts/run-playbook.sh hml ops immich status
./scripts/run-playbook.sh hml bkp --tags immich
```

## Monitoring

```bash
./scripts/run-playbook.sh hml mon
```

Déploiement ciblé :

```bash
./scripts/run-playbook.sh hml mon --tags node_exporter
./scripts/run-playbook.sh hml mon --tags cadvisor
./scripts/run-playbook.sh hml mon --tags prometheus
./scripts/run-playbook.sh hml mon --tags grafana
```
