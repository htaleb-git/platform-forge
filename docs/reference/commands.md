# Référence — Commandes HomeLab

## Runner

```bash
./scripts/run-playbook.sh --help
```

## Media Storage

```bash
./scripts/run-playbook.sh hml run --tags media_storage
```

```bash
lsblk -f
sudo cryptsetup status media01_crypt
findmnt /mnt/medias01
df -h /mnt/medias01
```

Retrait propre :

```bash
sudo umount /mnt/medias01
sudo cryptsetup close media01_crypt
```

Ouverture manuelle :

```bash
sudo cryptsetup open \
  /dev/disk/by-uuid/64e62fa5-c2a0-4402-92b3-b116de022503 \
  media01_crypt
```

## Immich

Déploiement :

```bash
./scripts/run-playbook.sh hml app --tags immich
```

Lifecycle :

```bash
./scripts/run-playbook.sh hml ops immich status
./scripts/run-playbook.sh hml ops immich start
./scripts/run-playbook.sh hml ops immich stop
./scripts/run-playbook.sh hml ops immich restart
```

Containers :

```bash
docker ps --filter name=immich
docker logs immich_server --tail 100
docker logs immich_machine_learning --tail 100
docker stats immich_machine_learning
```

Montages :

```bash
docker inspect immich_server \
  --format '{{range .Mounts}}{{println .Source "->" .Destination "RW=" .RW}}{{end}}'
```

Test RO non destructif :

```bash
docker exec immich_server \
  touch /external/medias01/IMMICH_WRITE_TEST
```

Résultat attendu :

```text
Read-only file system
```

## ML egress

```bash
docker exec immich_machine_learning \
  python -c "import requests; r=requests.get('https://www.modelscope.cn', timeout=30); print(r.status_code)"
```

```bash
docker exec immich_machine_learning \
  du -sh /cache/*
```

## Synchronisation médias

```bash
./sync-medias.sh Pictures
./sync-medias.sh Pictures/2026
./sync-medias.sh Pictures/2026 --dry-run
```

SSH HomeLab :

```text
port 2250
```

## Backup Immich

Déployer :

```bash
./scripts/run-playbook.sh hml bkp --tags immich
```

Manuel :

```bash
sudo systemctl start backup-immich.service
```

Logs :

```bash
sudo journalctl -u backup-immich.service -f
```

Timer :

```bash
systemctl status backup-immich.timer --no-pager
```

Tous les timers :

```bash
systemctl list-timers --all | grep -E 'backup-(gitlab|n8n|immich)'
```

Snapshots :

```bash
sudo restic \
  -r /mnt/backups01/homelab/restic \
  --password-file /etc/homelab/backup/restic-password \
  snapshots --tag immich
```

## Restore Immich

Vérification non destructive :

```bash
sudo /usr/local/sbin/restore-immich.sh \
  <SNAPSHOT_ID> \
  --verify-only
```

Restore destructif :

```bash
sudo /usr/local/sbin/restore-immich.sh <SNAPSHOT_ID>
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

## Collecte VPS → HomeLab

```bash
./scripts/run-playbook.sh hml bkp --tags backup_remote_collect
sudo systemctl start backup-remote-collect.service
sudo systemctl status backup-remote-collect.service --no-pager
```

```bash
sudo find /srv/homelab/backups/vps01/wordpress \
  -maxdepth 1 -type f -printf '%f %s bytes\n'
```

Métriques :

```bash
curl -s http://localhost:9100/metrics | grep backup_remote_collect
```
