# Inventory et variables

## Groupes

```text
all
├── homelab
│   └── homelab01
└── vps
    └── vps01
```

## Répartition

| Emplacement | Contenu |
|---|---|
| `group_vars/all` | images, chemins communs, politique backup, rétention |
| `group_vars/homelab` | applications HomeLab, monitoring, collecte distante |
| `group_vars/vps` | applications et activations VPS |
| `host_vars/homelab01` | réalité physique HomeLab et secrets spécifiques |
| `host_vars/vps01` | réalité VPS, permissions de backup et secrets spécifiques |
| Vault | secrets |

## Racines

```yaml
host_root: /srv/homelab
host_apps_root: "{{ host_root }}/apps"
host_data_root: "{{ host_root }}/data"
host_backup_root: "{{ host_root }}/backups"
```

## Backup

La politique globale est centralisée dans :

```text
group_vars/all/backup.yml
```

Exemples :

```yaml
backup_n8n_enabled: true
backup_gitlab_enabled: true
backup_immich_enabled: true
```

Les rôles utilisent désormais réellement ces flags.

## Images

```text
group_vars/all/images.yml
```

Immich y centralise notamment :

- serveur ;
- machine-learning ;
- Valkey ;
- PostgreSQL/VectorChord.

Éviter `latest`.

## Monitoring

Les variables fonctionnelles du monitoring sont regroupées dans :

```text
group_vars/homelab/monitoring.yml
```

Elles décrivent notamment les chemins persistants, ports, hostnames et paramètres des composants de monitoring. Les données suivent la convention `/srv/homelab` :

```text
/srv/homelab/apps/prometheus
/srv/homelab/data/prometheus/config
/srv/homelab/data/prometheus/data
/srv/homelab/data/grafana/data
/srv/homelab/data/grafana/provisioning
/srv/homelab/data/grafana/dashboards
/srv/homelab/data/node_exporter/textfile
```

Le réseau Docker `monitoring` utilise actuellement le subnet `172.23.0.0/16`.


## VPS

Racines VPS :

```yaml
host_root: /srv/vps
host_apps_root: "{{ host_root }}/apps"
host_data_root: "{{ host_root }}/data"
host_backup_root: "{{ host_root }}/backups"
```

Les flags d'activation ne doivent pas être dupliqués dans `all` s'ils diffèrent entre HomeLab et VPS.

### Collecte distante

Dans `group_vars/homelab/backup.yml` :

```yaml
backup_remote_root: "{{ host_backup_root }}/vps01"
backup_remote_host: "{{ hostvars['vps01'].ansible_host }}"
backup_remote_port: "{{ hostvars['vps01'].ansible_port }}"
backup_remote_ssh_key: "/root/.ssh/backup_vps_pull"

backup_remote_sources:
  - name: n8n
    local_path: "{{ backup_remote_root }}/n8n"
  - name: nextcloud
    local_path: "{{ backup_remote_root }}/nextcloud"
  - name: wordpress
    local_path: "{{ backup_remote_root }}/wordpress"
```

### Permissions WordPress collectable

Exemple VPS :

```yaml
backup_wordpress_group: backup-readers
backup_wordpress_dir_mode: "0750"
backup_wordpress_file_mode: "0640"
```
