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

## Immich

Paramètres fonctionnels HomeLab :

```text
group_vars/homelab/applications.yml
```

Exemples :

```yaml
immich_hostname: immich.home.arpa
immich_network_proxy: proxy
immich_network_backend: immich_backend
immich_network_egress: immich_egress

immich_postgres_user: immich
immich_postgres_db: immich
```

Le mot de passe reste fourni depuis le Vault du host via la variable exposée par le rôle.

## Media Storage

Les disques physiques appartiennent à `homelab01`.

```yaml
media_storage_volumes:
  - name: medias01
    enabled: true
    luks_uuid: "64e62fa5-c2a0-4402-92b3-b116de022503"
    mapper_name: "media01_crypt"
    key_file: "/etc/homelab/luks/medias01.key"
    filesystem_uuid: "ec2e985e-3c88-45e2-9462-fbf583c443bd"
    filesystem: "ext4"
    label: "MEDIAS01"
    mount_point: "/mnt/medias01"
    expose_to_immich: true
    immich_container_path: "/external/medias01"
```

Les clés sont stockées dans :

```text
host_vars/homelab01/vault_luks.yml
```

sous forme Base64 chiffrée par Ansible Vault.

## Backup Immich defaults

Le rôle `backup_immich` mappe l'application vers le framework commun :

```yaml
backup_immich_dir: "{{ host_backup_root }}/immich"
backup_immich_container_name: "{{ immich_container_name }}"
backup_immich_postgres_container_name: "{{ immich_postgres_container_name }}"
backup_immich_postgres_user: "{{ immich_postgres_user }}"
backup_immich_postgres_db: "{{ immich_postgres_db }}"
backup_immich_data_dir: "{{ immich_upload_dir }}"
```

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

Les chemins de backup applicatifs sont centralisés dans `group_vars/all/backup.yml`, par exemple :

```yaml
backup_n8n_dir: "{{ host_backup_root }}/n8n"
backup_nextcloud_dir: "{{ host_backup_root }}/nextcloud"
backup_wordpress_dir: "{{ host_backup_root }}/wordpress"
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
