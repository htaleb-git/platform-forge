# Rôle `manage_application`

## Objectif

Fournir une interface commune pour exploiter les applications Docker Compose.

## Interface

| Variable | Requise | Description |
|---|---:|---|
| `application_name` | oui | nom de l'application |
| `application_compose_dir` | oui | répertoire contenant `compose.yml` |
| `application_operation` | oui | `start`, `stop`, `restart`, `status` |

## Applications intégrées

- n8n ;
- GitLab ;
- Immich.

## Runner

```bash
./scripts/run-playbook.sh hml ops n8n status
./scripts/run-playbook.sh hml ops gitlab status
./scripts/run-playbook.sh hml ops immich status
```

Remplacer `status` par :

```text
start
stop
restart
```

## Sémantique

- `start` : converge vers une stack démarrée ;
- `stop` : stoppe sans supprimer conteneurs/volumes ;
- `restart` : redémarre ;
- `status` : affiche `docker compose ps` sans changement.

Backup, restore et upgrade restent dans des rôles/scripts dédiés.
