# Application — GitLab

## Rôle

GitLab CE fournit les dépôts Git et l'interface de gestion de code du HomeLab. L'application est déployée avec l'image GitLab Omnibus officielle dans Docker Compose.

## Déploiement

```bash
ansible-playbook -K ansible/playbooks/05-applications.yml \
  --tags gitlab
```

## Accès

| Usage | Endpoint |
|---|---|
| Web | `https://gitlab.home.arpa` |
| SSH Git | `gitlab.home.arpa:2424` |

Le trafic HTTP applicatif passe par Traefik. SSH est publié directement vers le port 22 du conteneur.

## Persistance

```text
/srv/homelab/data/gitlab/
├── config
├── logs
└── data
```

Correspondances :

- `config` → `/etc/gitlab`
- `logs` → `/var/log/gitlab`
- `data` → `/var/opt/gitlab`

## Exploitation

```bash
ansible-playbook -K ansible/playbooks/07-operations.yml \
  --tags gitlab \
  -e operation=status
```

Remplacer `status` par `start`, `stop` ou `restart`.

## Backup

Le rôle `backup_gitlab` déploie :

- `/usr/local/sbin/backup-gitlab.sh` ;
- `/usr/local/sbin/restore-gitlab.sh` ;
- `backup-gitlab.service` ;
- `backup-gitlab.timer`.

Le backup inclut :

- archive GitLab native ;
- `gitlab.rb` ;
- `gitlab-secrets.json` ;
- version GitLab ;
- métadonnées nécessaires au restore.

## Restore

```bash
ansible-playbook -K ansible/playbooks/08-restore.yml \
  --limit homelab01 \
  --tags gitlab \
  -e snapshot_id=<SNAPSHOT_ID>
```

La restauration GitLab a été validée par un test Disaster Recovery réel.

Voir [Runbook — GitLab](../runbooks/gitlab.md).
