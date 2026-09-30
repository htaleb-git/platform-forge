# Opération — Restore

## Principe

Les restores sont volontairement explicites, manuels et destructifs lorsqu'ils modifient une application. Aucun restore n'est planifié par timer.

## Contrat V1

La commande requiert une cible, une application V1 et l'identifiant hexadécimal explicite d'un snapshot Restic :

```bash
./scripts/run-playbook.sh platform01 restore n8n 0123456789abcdef
```

`latest`, les sélections implicites et les chemins de destination fournis par l'opérateur sont interdits. Le workflow extrait uniquement le sous-arbre `platform_backup_root/<application>` dans un staging unique sous `restic_restore_staging_root`, valide `current` et sa génération, puis passe cette génération explicitement au script applicatif.

Deux confirmations restent obligatoires : `RESTORE`, puis `ERASE-AND-RESTORE`.

## Rollback et validation

- GitLab conserve une copie locale des volumes de données et des deux fichiers de configuration avant remplacement. Le rollback est une copie de fichiers puis une recréation du conteneur, pas une transaction atomique.
- n8n produit un dump PostgreSQL de rollback avant de recréer la base. La validation contrôle PostgreSQL puis l'état du conteneur n8n.
- WordPress conserve un dump MariaDB et une archive de `wp-content`. La validation contrôle les tables, le contenu et le conteneur.
- Nextcloud conserve SQLite et `config.php`, restaure sous maintenance et contrôle SQLite puis `occ status`.

Un échec de restauration ou de validation déclenche une tentative de rollback. Un rollback qui échoue est signalé comme critique et exige une récupération manuelle.

## Limite Nextcloud

Le format de backup Nextcloud V1 contient uniquement `owncloud.db` et `config.php`. Il ne contient pas le répertoire des fichiers utilisateurs. Ce workflow n'est donc pas une récupération Nextcloud complète et ne doit jamais être présenté comme telle.

## Règle

Un backup n'est considéré comme fiable que si sa restauration ou au minimum sa vérification a été testée.
