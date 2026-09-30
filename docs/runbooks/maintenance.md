# Runbook — Maintenance HomeLab

## Objectif

Maintenir `homelab01` à jour et contrôler sa santé sans suppression agressive ni reboot non demandé.

## 1. Pré-check

```bash
./scripts/run-playbook.sh hml mnt --tags health
```

Attendu :

- aucun service système critique en échec ;
- filesystem sous le seuil critique ;
- backup mount présent ;
- `restic check` réussi ;
- Docker actif ;
- état des conteneurs affiché.

## 2. Simuler les mises à jour

```bash
./scripts/run-playbook.sh hml mnt \
  --tags system \
  --check --diff
```

Examiner particulièrement :

- kernel ;
- Docker Engine ;
- containerd ;
- Docker Compose plugin ;
- bibliothèques système.

Un `changed` en check mode signifie que la tâche modifierait la machine.

## 3. Lancer la maintenance standard

```bash
./scripts/run-playbook.sh hml mnt
```

Par défaut :

- upgrade safe ;
- autoclean ;
- aucun autoremove ;
- aucun reboot automatique ;
- aucun Docker cleanup.

## 4. Vérifier après update

```bash
systemctl status docker --no-pager
docker ps
```

```bash
test -f /var/run/reboot-required \
  && cat /var/run/reboot-required \
  || echo "No reboot required"
```

Puis :

```bash
./scripts/run-playbook.sh hml mnt --tags health
```

## 5. Reboot planifié

Si nécessaire :

```bash
./scripts/run-playbook.sh hml mnt \
  -e system_update_reboot_enabled=true
```

Après reboot :

```bash
./scripts/run-playbook.sh hml mnt --tags health
```

## 6. Maintenance approfondie

Avant cleanup :

```bash
docker system df
docker system df -v
```

Puis :

```bash
./scripts/run-playbook.sh hml mnt \
  -e system_update_autoremove=true \
  -e maintenance_docker_cleanup_enabled=true
```

Comparer ensuite :

```bash
docker system df
```

## 7. Règles de sécurité Docker

Ne jamais automatiser dans cette V1 :

```bash
docker volume prune
docker container prune
docker system prune -a
```

Un conteneur arrêté peut correspondre à une application on-demand valide.

## 8. En cas d'échec Restic

```bash
findmnt /mnt/backups01
df -h /mnt/backups01
```

Puis :

```bash
sudo restic \
  -r /mnt/backups01/homelab/restic \
  --password-file /etc/homelab/backup/restic-password \
  check
```

Ne jamais lancer de réparation destructive avant d'avoir identifié précisément la cause.
