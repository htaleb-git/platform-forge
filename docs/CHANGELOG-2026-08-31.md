# Documentation update — 2026-08-31

Cette mise à jour documente le chantier VPS réalisé après la version Monitoring V1 du 21 août 2026.

## Ajouts majeurs

- reconstruction et sécurisation de `vps01` sous Ubuntu 26.04 LTS ;
- séparation HomeLab / VPS dans l'inventory et les playbooks backup/restore ;
- n8n VPS + PostgreSQL ;
- Nextcloud VPS 25.0.2, HTTPS, CalDAV/CardDAV ;
- backup et restore Nextcloud ;
- WordPress 7.1.0 + MariaDB 11.4.13 ;
- `portail.taleb.fr` via Traefik/ACME ;
- persistance WordPress ;
- backup logique MariaDB + `wp-content` ;
- restore WordPress avec DROP/CREATE et test fonctionnel ;
- accès de backup VPS restreint `backup-pull` / `rrsync -ro` ;
- collecte n8n/Nextcloud/WordPress VPS vers HomeLab ;
- permissions `backup-readers` ;
- métriques de collecte distante ;
- extension du dashboard `Backup Health`.

## Documentation créée

- `architecture/vps.md` ;
- `applications/nextcloud.md` ;
- `applications/wordpress.md` ;
- `runbooks/backup-wordpress.md` ;
- `runbooks/restore-wordpress.md` ;
