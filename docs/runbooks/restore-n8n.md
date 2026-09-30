# Runbook — Restore n8n

> **Opération destructive :** la base PostgreSQL n8n courante est remplacée par celle du snapshot.

## Prérequis

- disque de backup monté sur `/mnt/backups01` ;
- repository Restic accessible ;
- conteneur PostgreSQL disponible ;
- conteneur n8n présent ;
- même `N8N_ENCRYPTION_KEY` que lors du backup ;
- snapshot Restic n8n connu.

La clé de chiffrement n8n est critique : restaurer uniquement la base sans la clé d'origine peut rendre les credentials inutilisables.

## 1. Vérifier le support de backup

```bash
findmnt /mnt/backups01
```

## 2. Lister les snapshots n8n

```bash
sudo restic \
  -r /mnt/backups01/homelab/restic \
  --password-file /etc/homelab/backup/restic-password \
  snapshots --tag n8n
```

Noter le snapshot à restaurer.

## 3. Lancer le restore via Ansible

```bash
ansible-playbook -K ansible/playbooks/08-restore.yml \
  --limit homelab01 \
  --tags n8n \
  -e snapshot_id=<SNAPSHOT_ID>
```

Le playbook valide le snapshot et demande confirmation avant d'exécuter le script.

## 4. Fonctionnement du script

`/usr/local/sbin/restore-n8n.sh` :

```text
Restic snapshot
      ↓
/tmp/n8n-restore
      ↓
validation n8n.dump
      ↓
stop n8n
      ↓
drop/create PostgreSQL DB
      ↓
pg_restore
      ↓
pg_isready
      ↓
start n8n
```

Le script protège son répertoire temporaire avant toute suppression récursive. Le chemin doit correspondre à `/tmp/n8n-*`.

## 5. Validation technique

PostgreSQL :

```bash
docker exec n8n-postgres \
  pg_isready -U n8n -d n8n
```

Conteneurs :

```bash
cd /srv/homelab/apps/n8n
docker compose ps
```

Logs :

```bash
docker logs n8n --tail 100
```

HTTPS :

```bash
curl -k -I https://n8n.home.arpa
```

## 6. Validation fonctionnelle

Dans l'interface n8n, vérifier :

- workflows ;
- credentials ;
- état des workflows ;
- exécutions pertinentes ;
- capacité à ouvrir et exécuter un workflow connu.

## 7. Retour arrière

En cas d'échec :

1. arrêter les modifications manuelles ;
2. conserver les logs ;
3. diagnostiquer l'étape exacte ayant échoué ;
4. sélectionner un snapshot connu ;
5. relancer la procédure uniquement après correction.

Ne jamais enchaîner plusieurs restores au hasard.
