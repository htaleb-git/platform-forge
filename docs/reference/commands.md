# Référence — Commandes HomeLab

## Runner

```bash
./scripts/run-playbook.sh --help
```

## Restic

```bash
sudo restic \
  -r /mnt/backups01/homelab/restic \
  --password-file /etc/homelab/backup/restic-password \
  check
```

Lock stale seulement après vérification des processus :

```bash
ps aux | grep '[r]estic'
```

```bash
sudo restic \
  -r /mnt/backups01/homelab/restic \
  --password-file /etc/homelab/backup/restic-password \
  unlock
```

Prune :

```bash
sudo restic \
  -r /mnt/backups01/homelab/restic \
  --password-file /etc/homelab/backup/restic-password \
  prune
```

## Docker maintenance

```bash
docker system df
docker system df -v
```

Nettoyages automatisables :

```bash
docker image prune -f
docker builder prune -f --filter "until=720h"
```

Jamais automatiquement :

```text
docker volume prune
docker container prune
docker system prune -a
```

## Monitoring V1

Déployer toute la stack :

```bash
./scripts/run-playbook.sh hml mon
```

Cibler un composant :

```bash
./scripts/run-playbook.sh hml mon --tags node_exporter
./scripts/run-playbook.sh hml mon --tags cadvisor
./scripts/run-playbook.sh hml mon --tags prometheus
./scripts/run-playbook.sh hml mon --tags grafana
```

Targets Prometheus :

```bash
curl -sG \
  --data-urlencode 'query=up' \
  http://localhost:9090/api/v1/query \
  | python3 -m json.tool
```

Métriques backups :

```bash
curl -s http://localhost:9100/metrics | grep '^homelab_backup'
```

Métriques Restic :

```bash
curl -s http://localhost:9100/metrics | grep '^homelab_restic'
```

Grafana :

```text
https://grafana.home.arpa
```

## VPS — WordPress

Déploiement :

```bash
./scripts/run-playbook.sh vps app --tags wordpress
```

Backup :

```bash
./scripts/run-playbook.sh vps bkp --tags backup_wordpress
sudo systemctl start backup-wordpress.service
sudo ls -lh /srv/vps/backups/wordpress/
```

Restore :

```bash
sudo bash -n /usr/local/sbin/restore-wordpress.sh
sudo /usr/local/sbin/restore-wordpress.sh
curl -I https://hicham.taleb.fr
```

## VPS — Nextcloud

```bash
./scripts/run-playbook.sh vps app --tags nextcloud
./scripts/run-playbook.sh vps bkp --tags backup_nextcloud
sudo systemctl start backup-nextcloud.service
```
