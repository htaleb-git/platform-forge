# Runbook — Monitoring V1

## Déployer ou remettre en conformité

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

## Contrôles rapides

### Services et conteneurs

```bash
systemctl status node_exporter --no-pager
docker ps --filter name=cadvisor
docker ps --filter name=prometheus
docker ps --filter name=grafana
```

### Endpoints

```bash
curl -s http://localhost:9100/metrics | head
curl -s http://localhost:8080/metrics | head
curl -I http://localhost:9090
curl -I http://localhost:3000
```

### Prometheus

```bash
curl -sG \
  --data-urlencode 'query=up' \
  http://localhost:9090/api/v1/query \
  | python3 -m json.tool
```

Attendu : `prometheus`, `cadvisor` et `node_exporter` à `1`.

## Contrôler les métriques backup

```bash
ls -l /srv/homelab/data/node_exporter/textfile/
```

```bash
curl -s http://localhost:9100/metrics \
  | grep '^homelab_backup'
```

Déclenchement manuel :

```bash
sudo systemctl start backup-n8n.service
sudo systemctl start backup-gitlab.service
```

Puis :

```bash
cat /srv/homelab/data/node_exporter/textfile/backup_n8n.prom
cat /srv/homelab/data/node_exporter/textfile/backup_gitlab.prom
```

## Contrôler Restic

Déclenchement manuel :

```bash
sudo systemctl start restic-maintenance.service
```

Suivi :

```bash
systemctl status restic-maintenance.service --no-pager
journalctl -u restic-maintenance.service -n 100 --no-pager
```

Métriques :

```bash
cat /srv/homelab/data/node_exporter/textfile/restic.prom
```

```bash
curl -s http://localhost:9100/metrics \
  | grep '^homelab_restic'
```

## Contrôler Grafana

Accès :

```text
https://grafana.home.arpa
```

Dashboards attendus :

```text
Node Exporter Full
cAdvisor Docker
HomeLab - Storage & Backup Health
```

Datasource attendue :

```text
Prometheus / uid=prometheus
```

## Grafana inaccessible

### 1. Vérifier Grafana lui-même

```bash
docker ps --filter name=grafana
curl -I http://localhost:3000
curl -I http://192.168.1.144:3000
```

Un `302 Found` vers `/login` est normal.

### 2. Vérifier les réseaux

```bash
docker inspect grafana \
  --format '{{json .NetworkSettings.Networks}}' \
  | python3 -m json.tool
```

Grafana doit être présent sur :

```text
monitoring
proxy
```

### 3. Vérifier le hostname depuis le client

Sur le PC qui ouvre Grafana :

```bash
getent hosts grafana.home.arpa
```

En l'absence de DNS LAN opérationnel, vérifier `/etc/hosts` du client.

## Grafana redémarre en boucle

```bash
docker logs grafana --since 5m
```

Si le log parle de provisioning, vérifier les mounts :

```bash
docker inspect grafana \
  --format '{{range .Mounts}}{{println .Source "->" .Destination}}{{end}}'
```

Attendu :

```text
/srv/homelab/data/grafana/data -> /var/lib/grafana
/srv/homelab/data/grafana/provisioning -> /etc/grafana/provisioning
/srv/homelab/data/grafana/dashboards -> /var/lib/grafana/dashboards
```

## Node Exporter DOWN dans Prometheus

Vérifier :

```bash
ss -lntp | grep 9100
curl -s http://192.168.1.144:9100/metrics | head
sudo ufw status
```

Puis tester depuis le réseau monitoring :

```bash
docker run --rm \
  --network monitoring \
  curlimages/curl:latest \
  http://192.168.1.144:9100/metrics
```

Si le host répond mais le conteneur bloque, contrôler la règle UFW autorisant le subnet monitoring vers `9100/tcp`.

## Dashboard Backup Health sans données Restic

Comparer les noms réellement exposés :

```bash
curl -s http://localhost:9100/metrics | grep '^homelab_restic'
```

Les noms V1 sont :

```text
homelab_restic_check_status
homelab_restic_check_last_run_timestamp
homelab_restic_check_last_success_timestamp
homelab_restic_check_duration_seconds
homelab_restic_snapshots_total
homelab_restic_repository_size_bytes
```

Le dashboard doit utiliser exactement ces noms.

## Vérification après modification d'un dashboard

Les JSON sont gérés par Git. Après modification :

```bash
./scripts/run-playbook.sh hml mon --tags grafana
```

Puis vérifier :

```bash
docker logs grafana --since 2m \
  | grep -Ei 'provision|dashboard|datasource|error'
```

Éviter de considérer les modifications faites directement dans l'UI comme source de vérité.
