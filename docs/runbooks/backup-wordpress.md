# Runbook — Backup WordPress VPS

## Déployer la capacité

```bash
./scripts/run-playbook.sh vps bkp --tags backup_wordpress
```

## Lancer manuellement

```bash
sudo systemctl start backup-wordpress.service
sudo systemctl status backup-wordpress.service --no-pager
```

## Artefacts attendus

```bash
sudo ls -lh /srv/vps/backups/wordpress/
```

```text
wordpress.sql
wp-content.tar.gz
```

## Vérifier

```bash
sudo test -s /srv/vps/backups/wordpress/wordpress.sql && echo "DB backup OK"
```

```bash
sudo tar -tzf /srv/vps/backups/wordpress/wp-content.tar.gz >/dev/null \
  && echo "wp-content backup OK"
```

## Timer

```bash
systemctl status backup-wordpress.timer --no-pager
systemctl list-timers backup-wordpress.timer
```

## Logs

```bash
sudo journalctl -u backup-wordpress.service -n 100 --no-pager
```

## Métriques

```bash
curl -s http://localhost:9100/metrics | grep 'backup_.*wordpress'
```
