# État et écarts connus

## VPS Production

Socle V1 terminé :

- Ubuntu 26.04 LTS reconstruit ;
- SSH sécurisé par clés ;
- Traefik / HTTPS ;
- n8n + PostgreSQL ;
- Nextcloud léger + CalDAV/CardDAV ;
- WordPress + MariaDB ;
- backups n8n / Nextcloud / WordPress ;
- collecte read-only VPS → HomeLab ;
- restore Nextcloud et WordPress validés ;
- métriques backup et collecte distante.

Prochain workload prévu : application KPI/SaaS Node.js/TypeScript/PostgreSQL.

## WordPress

Infrastructure V1 close. Reste côté produit :

- identité visuelle ;
- structure du portail ;
- contenu profil / expertise / réalisations / services ;
- blog ;
- éventuelle chaîne n8n + IA → brouillon WordPress → validation humaine.

## Nextcloud

Le backup V1 protège SQLite + configuration. La sauvegarde des données volumineuses reste à définir si l'usage devient critique.

## Monitoring

Monitoring V1 opérationnel avec HomeLab + métriques VPS/backups. La collecte distante est désormais observable séparément.

Reste pour les versions suivantes :

- Alerting V1 ;
- durcissement des ports exposés ;
- monitoring services systemd et timers ;
- métriques Traefik ;
- métriques PostgreSQL/MariaDB ;
- monitoring applicatif GitLab/n8n/Immich/Nextcloud/WordPress ;
- Loki pour les logs ;
- Alertmanager ;
- températures / SMART ;
- disponibilité Internet / DNS ;
- amélioration dashboards ;
- tests de restauration automatisés ;
- second disque `backups02` ;
- gestion `medias02` ;
- sauvegarde externe / hors site.

## Media Center

V1 infrastructure terminée : stockage LUKS multi-volumes, MEDIAS01, Immich, External Library read-only, ML, backup et verify-only restore.

## DNS / Unbound

Le chantier DNS local reste utile pour les noms `home.arpa` et les clients LAN.

## Backup familial

À concevoir séparément du Media Center : machines Ubuntu, politique Restic, off-site et Mac selon besoin.

## Refactoring

- homogénéiser `main.yml` / `main.yaml` ;
- poursuivre FQCN ;
- pinning des images ;
- lint/CI ;
- garder une seule source de vérité pour chaque variable.

## Sécurité

Ne jamais versionner en clair : Vault, `.env`, keyfiles LUKS, CA private key, `gitlab-secrets.json`.
