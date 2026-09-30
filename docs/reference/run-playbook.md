# Référence — `run-playbook.sh`

## Objectif

`scripts/run-playbook.sh` est une couche ergonomique autour de `ansible-playbook`.

Il ne masque pas Ansible :

- les options Ansible restent disponibles ;
- `-e` reste fourni explicitement par l'opérateur ;
- les noms complets restent acceptés ;
- le runner ajoute seulement des alias, des validations et `-K`.

## Syntaxe

```bash
./scripts/run-playbook.sh <target> <playbook> [options ansible-playbook]
```

Cas spécial opérations :

```bash
./scripts/run-playbook.sh <target> ops <application> <operation> [options]
```

## Targets

| Alias | Cible |
|---|---|
| `hml` | `homelab01` |
| `vps` | `vps01` |

Les noms complets restent acceptés.

La cible `all` est interdite pour éviter les exécutions globales accidentelles.

## Playbooks

| Alias | Playbook |
|---|---|
| `ini` | `01-init-server.yml` |
| `net` | `02-network-homelab.yml` |
| `sys` | `03-system.yml` |
| `run` | `04-runtime.yml` |
| `app` | `05-applications.yml` |
| `bkp` | `06-backup-<environment>.yml` selon la cible |
| `ops` | `07-operations.yml` |
| `rst` | `08-restore-<environment>.yml` selon la cible |
| `mnt` | `09-maintenance.yml` |
| `mon` | `10-monitoring.yml` |

## `-K`

Le runner ajoute automatiquement :

```text
-K
```

Il n'est donc pas nécessaire de le saisir.

## Options Ansible

Toutes les options restantes sont transmises telles quelles.

```bash
./scripts/run-playbook.sh hml mon --tags grafana
```

```bash
./scripts/run-playbook.sh hml mnt --check --diff
```

```bash
./scripts/run-playbook.sh hml app --tags gitlab
```

```bash
./scripts/run-playbook.sh hml mnt \
  -e system_update_reboot_enabled=true
```

## Opérations raccourcies

```bash
./scripts/run-playbook.sh hml ops gitlab status
./scripts/run-playbook.sh hml ops gitlab start
./scripts/run-playbook.sh hml ops gitlab stop
./scripts/run-playbook.sh hml ops gitlab restart
```

Même interface pour `n8n`.

Le runner traduit :

```text
ops gitlab status
```

en :

```text
--tags gitlab -e operation=status
```

## Restore

Le restore utilise une interface fail-closed avec application et identifiant de snapshot explicites :

```bash
./scripts/run-playbook.sh platform01 restore n8n 0123456789abcdef
```

Le runner refuse les applications hors V1, les tags fournis par l'opérateur et les identifiants non hexadécimaux. Il fournit au playbook `restore_application`, `restore_snapshot_id` et le seul tag applicatif autorisé. `latest` n'est pas accepté.

## Aide

```bash
./scripts/run-playbook.sh --help
```

L'aide documente :

- targets ;
- alias playbooks ;
- opérations ;
- options Ansible ;
- exemples.

## Validations

Le runner refuse notamment :

- `all`, `*`, `all:*` ;
- une cible commençant par `-` ;
- un playbook commençant par `-` ;
- un playbook inexistant ;
- une opération applicative inconnue ;
- une application non supportée par le raccourci `ops`.

Le runner doit rester une aide opérateur, pas devenir un framework parallèle à Ansible.


## Exemples VPS

```bash
./scripts/run-playbook.sh vps app --tags wordpress
./scripts/run-playbook.sh vps bkp --tags backup_wordpress
./scripts/run-playbook.sh vps app --tags nextcloud
```

La cible reste obligatoire et `all` demeure interdite.
