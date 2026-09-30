# Runbook — Backup n8n

## Contrôler le timer

```bash
systemctl status backup-n8n.timer --no-pager
systemctl list-timers backup-n8n.timer
```

## Déclencher un backup

```bash
sudo systemctl start backup-n8n.service
```

## Contrôler le résultat

```bash
systemctl status backup-n8n.service --no-pager
journalctl -u backup-n8n.service -n 100 --no-pager
```

Un `Type=oneshot` réussi redevient normalement `inactive (dead)` après exécution. Contrôler le code retour et les logs.

## Vérifier le snapshot

```bash
sudo restic \
  -r /mnt/backups01/homelab/restic \
  --password-file /etc/homelab/backup/restic-password \
  snapshots --tag n8n
```

## Contrôler le contenu

```bash
sudo restic \
  -r /mnt/backups01/homelab/restic \
  --password-file /etc/homelab/backup/restic-password \
  ls <SNAPSHOT_ID>
```

Le staging doit contenir le dump PostgreSQL attendu (`n8n.dump` selon la configuration actuelle).

## Critères de succès

- support externe monté ;
- `pg_dump` terminé sans erreur ;
- snapshot récent tagué n8n ;
- rétention exécutée ;
- restore fonctionnel déjà validé.
