# Architecture — Backup & Recovery

## Objectif

La plateforme sépare clairement :

1. création d'un artefact applicatif cohérent ;
2. stockage local temporaire ;
3. réplication hors de l'hôte de production ;
4. protection Restic sur le HomeLab ;
5. rétention ;
6. vérification et restauration.

## HomeLab

### n8n

```text
PostgreSQL dump → Restic
```

### GitLab

```text
GitLab native backup
+ gitlab.rb
+ gitlab-secrets.json
+ metadata/version
→ Restic
```

### Immich

```text
PostgreSQL dump
+ données internes utiles
- thumbs
- encoded-video
- backups Immich
- ML cache
- MEDIAS01/MEDIAS02
→ Restic
```

Les médias originaux restent indépendants du backup applicatif Immich.

## VPS

### n8n

Le backup produit les artefacts nécessaires à la restauration de l'instance n8n/PostgreSQL dans `/srv/vps/backups/n8n`.

### Nextcloud

Backup V1 minimal :

```text
owncloud.db
config.php
```

Nextcloud passe en maintenance pendant la copie cohérente de SQLite. Les données volumineuses sont hors scope V1.

### WordPress

```text
MariaDB logical dump → wordpress.sql
wp-content            → wp-content.tar.gz
```

Le répertoire MariaDB brut n'est jamais copié à chaud. Le coeur WordPress est reconstructible depuis l'image Docker et l'IAC.

## Réplication VPS → HomeLab

## Timers déclaratifs

Les flags d'activation sont spécifiques à l'environnement. Convention :

```text
true  → timer enabled + started
false → timer disabled + stopped
```

La tâche de désactivation est importante : un timer précédemment actif doit être arrêté si la variable passe à `false`.

## Monitoring

Les backups applicatifs publient :

```text
backup_last_status{backup="..."}
backup_last_run_timestamp{backup="..."}
backup_last_success_timestamp{backup="..."}
backup_last_duration_seconds{backup="..."}
```

La réplication VPS → HomeLab publie séparément :

```text
backup_remote_collect_status{source="vps01",backup="..."}
backup_remote_collect_timestamp{source="vps01",backup="..."}
backup_remote_collect_duration_seconds{source="vps01",backup="..."}
```

Cette séparation permet de détecter le cas `backup VPS OK / copie HomeLab FAILED`.

## Restore validé

- n8n : restore validé ;
- GitLab : disaster recovery validé ;
- Immich : `--verify-only` validé ;
- Nextcloud VPS : restore validé ;
- WordPress VPS : restore DB + `wp-content` validé fonctionnellement.

### WordPress

Le restore WordPress effectue `DROP/CREATE`, réimporte le dump, contrôle les tables, restaure `wp-content` puis redémarre le conteneur. Un test avec une page temporaire créée après backup a confirmé le retour réel à l'état sauvegardé.

## Restic locks

Un backup interrompu peut laisser un lock stale. Avant `restic unlock`, vérifier qu'aucun processus Restic correspondant n'est réellement actif.

## Rétention

La politique de rétention est centralisée dans `group_vars/all/backup.yml`. Une politique de rétention ne remplace jamais un test de restore.
