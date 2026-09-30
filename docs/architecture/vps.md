# Architecture — VPS Production

## Objectif

Le VPS constitue la zone de production publique de la plateforme. Il est séparé du HomeLab, qui reste un laboratoire reconstructible et le point de centralisation des sauvegardes distantes.

## Hôte

- OS : Ubuntu 26.04 LTS ;
- hostname : `vps01` ;
- administration : utilisateur `kimoooon` ;
- SSH par clés uniquement ;
- login root SSH désactivé ;
- authentification SSH par mot de passe désactivée ;
- port SSH personnalisé ;
- déploiement et exploitation via Ansible depuis le dépôt d'infrastructure.

## Architecture logique

```mermaid
flowchart TB
    Internet -->|HTTPS 443| T[Traefik VPS]
    T --> N[n8n]
    T --> NC[Nextcloud]
    T --> WP[WordPress]
    N --> NP[(PostgreSQL n8n)]
    WP --> MDB[(MariaDB WordPress)]

    BN[backup-n8n] --> VB[/srv/vps/backups/n8n]
    BNC[backup-nextcloud] --> VNC[/srv/vps/backups/nextcloud]
    BWP[backup-wordpress] --> VWP[/srv/vps/backups/wordpress]

    VB --> SSH[backup-pull / rrsync read-only]
    VNC --> SSH
    VWP --> SSH
    SSH --> HB[/srv/homelab/backups/vps01]
    HB --> R[Restic HomeLab]
    R --> D[(BACKUPS01)]

    NE[Node Exporter VPS] --> P[Prometheus]
    CA[cAdvisor] --> P
    P --> G[Grafana]
```

## Applications publiques

| Application | Backend | Exposition | État |
|---|---|---|---|
| n8n | PostgreSQL 16 | Traefik / HTTPS | ✅ |
| Nextcloud | SQLite, version 25.0.2 | `cloud.taleb.fr` | ✅ |
| WordPress | MariaDB 11.4.13 | `hicham.taleb.fr` | ✅ |

Les bases de données ne publient pas de port directement sur Internet.

## WordPress

Architecture :

```text
Internet
   │ HTTPS
Traefik
   │
WordPress
   │ wordpress_backend
MariaDB
```

Persistance :

```text
/srv/vps/apps/wordpress/
├── compose.yml
└── .env

/srv/vps/data/wordpress/
├── html/
└── mariadb/
```

Le coeur WordPress est fourni par l'image Docker. Les données métier à protéger sont principalement la base MariaDB et `wp-content`.

## Nextcloud

Nextcloud est volontairement léger sur le VPS :

- version `25.0.2` épinglée ;
- base SQLite `owncloud.db` ;
- accès HTTPS via Traefik ;
- CalDAV/CardDAV validés depuis iPhone ;
- backup minimal de la base SQLite et de `config.php` ;
- les données volumineuses ne font pas encore partie du backup VPS V1.

## Backup hors VPS

Le VPS ne constitue pas l'unique emplacement des sauvegardes.

```text
Application VPS
   ↓
/srv/vps/backups/<application>/
   ↓ SSH restreint / rrsync -ro
HomeLab /srv/homelab/backups/vps01/<application>/
   ↓
Restic HomeLab
   ↓
BACKUPS01
```

Le compte distant `backup-pull` appartient au groupe `backup-readers`. Les artefacts destinés à être collectés sont donc typiquement `root:backup-readers`, répertoire `0750`, fichiers `0640`.

La clé SSH est restreinte côté VPS avec `rrsync -ro /srv/vps/backups` afin de fournir un accès en lecture seule au périmètre de backup.

## Monitoring

Le monitoring est centralisé autour de Prometheus/Grafana. Les scripts de backup publient des métriques via le Textfile Collector de Node Exporter.

La collecte VPS → HomeLab publie en plus :

```text
backup_remote_collect_status{source="vps01",backup="..."}
backup_remote_collect_timestamp{source="vps01",backup="..."}
backup_remote_collect_duration_seconds{source="vps01",backup="..."}
```

Cela distingue explicitement :

1. succès du backup applicatif sur le VPS ;
2. succès de sa réplication vers le HomeLab.

## Principes de sécurité

- secrets dans Ansible Vault ;
- `.env` applicatifs en permissions restrictives ;
- aucun secret Vault versionné en clair ;
- bases backend privées ;
- Traefik comme point d'entrée HTTPS ;
- SSH par clés ;
- backup distant en lecture seule ;
- restore jamais planifié automatiquement.
