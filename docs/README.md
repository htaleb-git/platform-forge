# Platform Forge Documentation

Documentation de référence de la plateforme HomeLab + VPS de production, automatisée avec Ansible.

Cette documentation distingue :

- **architecture** : conception et principes ;
- **applications** : déploiement et comportement des workloads ;
- **operations** : capacités d'exploitation génériques ;
- **runbooks** : procédures opérationnelles et de reprise ;
- **reference** : commandes, playbooks, variables et conventions ;
- **decisions** : décisions d'architecture durables (ADR).

## Objectifs de la plateforme

- reconstruire le serveur Ubuntu de manière reproductible ;
- fournir un runtime Docker commun aux applications ;
- exposer les services du LAN en HTTPS via Traefik ;
- séparer déploiement, exploitation, sauvegarde, restauration et maintenance ;
- automatiser les sauvegardes avec Restic et systemd ;
- valider les sauvegardes par de vraies restaurations ou des vérifications non destructives ;
- fournir une interface générique `start/stop/restart/status` ;
- superviser le HomeLab avec Node Exporter, cAdvisor, Prometheus et Grafana ;
- exploiter un VPS de production sécurisé pour n8n, Nextcloud et WordPress ;

## État actuel

| Domaine | État |
|---|---|
| Bootstrap Ubuntu / SSH | ✅ |
| Docker Engine / Compose | ✅ |
| Traefik / TLS local | ✅ |
| n8n + PostgreSQL | ✅ |
| GitLab CE Omnibus | ✅ |
| Backup Restic | ✅ |
| Restore n8n | ✅ Validé |
| Disaster Recovery GitLab | ✅ Validé |
| `07-operations.yml` | ✅ |
| `08-restore.yml` | ✅ n8n / GitLab |
| `09-maintenance.yml` | ✅ |
| Runner `run-playbook.sh` | ✅ |
| Monitoring V1 Node Exporter / cAdvisor / Prometheus / Grafana | ✅ |
| Métriques backups / Restic / stockage | ✅ |
| Alerting V1 | ⏳ |
| Backup familial multi-PC | ⏳ |
| VPS Ubuntu 26.04 sécurisé / Ansible | ✅ |
| VPS n8n + PostgreSQL | ✅ |
| VPS Nextcloud / CalDAV / CardDAV | ✅ |
| VPS WordPress + MariaDB | ✅ |
| Backup n8n / Nextcloud / WordPress VPS | ✅ |
| Restore Nextcloud / WordPress | ✅ Validé |

## Navigation

### Architecture

- [Vue d'ensemble](architecture/overview.md)
- [Backup & Recovery](architecture/backup-recovery.md)
- [GitLab](architecture/gitlab.md)
- [Maintenance](architecture/maintenance.md)
- [Monitoring V1](architecture/monitoring.md)
- [VPS Production](architecture/vps.md)

### Applications

- [n8n](applications/n8n.md)
- [GitLab](applications/gitlab.md)
- [Nextcloud VPS](applications/nextcloud.md)
- [WordPress VPS](applications/wordpress.md)

### Opérations

- [Gestion générique des applications](operations/manage-application.md)
- [Sauvegarde](operations/backup.md)
- [Restauration](operations/restore.md)
- [Maintenance serveur](operations/maintenance.md)

### Runbooks

- [Backup n8n](runbooks/backup-n8n.md)
- [Restore n8n](runbooks/restore-n8n.md)
- [GitLab](runbooks/gitlab.md)
- [Maintenance](runbooks/maintenance.md)
- [Monitoring V1](runbooks/monitoring.md)
- [Backup WordPress VPS](runbooks/backup-wordpress.md)
- [Restore WordPress VPS](runbooks/restore-wordpress.md)

### Référence

- [Commandes](reference/commands.md)
- [Runner Ansible](reference/run-playbook.md)
- [Playbooks](reference/playbooks.md)
- [Inventory et variables](reference/inventory-variables.md)
- [Organisation du dépôt](reference/repository-layout.md)
- [État et écarts connus](reference/known-gaps.md)

### ADR

- [Index](decisions/README.md)

## Playbooks

```text
01-init-server
      ↓
02-network-homelab
      ↓
03-system
      ↓
04-runtime
      ↓
05-applications
      ↓
06-backup-homelab / 06-backup-vps
      ↓
07-operations       on demand
08-restore          on demand / destructif
09-maintenance      on demand
      ↓
10-monitoring
```

## Runner

```bash
./scripts/run-playbook.sh --help
```

Exemples :

```bash
./scripts/run-playbook.sh hml mon
```

`-K` est ajouté automatiquement par le runner.

> Les secrets, keyfiles LUKS et Vault déchiffrés ne doivent jamais être documentés ou versionnés en clair.

## Dernière mise à jour

- [Changelog VPS / WordPress / Remote Backup — 2026-08-31](CHANGELOG-2026-08-31.md)
