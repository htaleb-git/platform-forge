# Runbook — GitLab

## 1. Vérifier l'état

```bash
ansible-playbook -K ansible/playbooks/07-operations.yml \
  --tags gitlab \
  -e operation=status
```

```bash
curl -k -I https://gitlab.home.arpa
ssh -T -p 2424 git@gitlab.home.arpa
```

## 2. GitLab indisponible

```bash
cd /srv/homelab/apps/gitlab
docker compose ps
docker compose logs --tail 200 gitlab
```

Vérifier Traefik :

```bash
docker logs traefik --tail 200
```

Redémarrer :

```bash
ansible-playbook -K ansible/playbooks/07-operations.yml \
  --tags gitlab \
  -e operation=restart
```

GitLab Omnibus peut nécessiter plusieurs minutes pour devenir healthy.

## 3. Déclencher un backup manuel

```bash
sudo systemctl start backup-gitlab.service
```

```bash
systemctl status backup-gitlab.service --no-pager
journalctl -u backup-gitlab.service -n 200 --no-pager
```

Snapshots :

```bash
sudo restic \
  -r /mnt/backups01/homelab/restic \
  --password-file /etc/homelab/backup/restic-password \
  snapshots --tag gitlab
```

## 4. Restaurer via Ansible

> Le restore remplace l'état courant de GitLab.

```bash
ansible-playbook -K ansible/playbooks/08-restore.yml \
  --limit homelab01 \
  --tags gitlab \
  -e snapshot_id=<SNAPSHOT_ID>
```

Le playbook orchestre le script `/usr/local/sbin/restore-gitlab.sh`.

Le script vérifie notamment :

- montage du support ;
- présence des artefacts ;
- version du backup ;
- version GitLab déployée ;
- configuration et secrets ;
- confirmations destructives ;
- restauration native ;
- état de santé.

## 5. Validation post-restore

```bash
curl -k -I https://gitlab.home.arpa
ssh -T -p 2424 git@gitlab.home.arpa
```

Puis vérifier :

- authentification Web ;
- utilisateurs et groupes ;
- `platform/devops-platform` ;
- branches et historique ;
- clone/push SSH ;
- absence d'erreur critique dans les logs.

Depuis un clone local :

```bash
git fetch origin
git log --oneline origin/main -5
git log --oneline origin/develop -5
```

## 6. Compatibilité de version

Ne jamais forcer un backup GitLab natif sur une version différente.

La version du backup et celle de l'instance cible doivent correspondre avant la restauration.
