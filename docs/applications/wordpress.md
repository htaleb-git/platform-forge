# Application — WordPress VPS

## Rôle

WordPress héberge le portail professionnel public sur `hicham.taleb.fr`.

Le portail est destiné à présenter profil, expertise, réalisations, services et contenus techniques. L'automatisation éditoriale n8n/IA est prévue dans une phase ultérieure.

## Architecture

```text
Internet
   │ HTTPS
Traefik
   │
WordPress 7.1.0 / PHP 8.2 / Apache
   │ réseau wordpress_backend
MariaDB 11.4.13
```

Le conteneur WordPress rejoint également le réseau externe `proxy` de Traefik. MariaDB reste uniquement sur le backend privé.

## Images

```yaml
wordpress:
  repository: wordpress
  tag: "7.1.0-php8.2-apache"

mariadb:
  repository: mariadb
  tag: "11.4.13"
```

## Persistance

```text
/srv/vps/apps/wordpress/
├── compose.yml
├── .env
└── wp-cli.yml

/srv/vps/data/wordpress/
├── html/
└── mariadb/
```

`html` appartient numériquement à l'UID/GID WordPress (`33:33`). MariaDB utilise `999:999`. L'affichage d'un autre nom de compte sur l'hôte pour UID 999 n'est pas une erreur : Docker travaille avec les identifiants numériques.

Le rôle rend `wp-cli.yml` dans le répertoire applicatif et le monte en lecture
seule sur `/wp-cli.yml` dans `wordpress-cli`. La variable d'environnement
`WP_CLI_CONFIG_PATH` sélectionne explicitement ce fichier, qui déclare
`mod_rewrite` dans `apache_modules`. WP-CLI peut ainsi effectuer un flush dur des
règles dans `.htaccess` sans configuration manuelle du VPS.

## Secrets

MariaDB et WordPress utilisent des mots de passe aléatoires bruts stockés dans Ansible Vault : ils ne doivent pas être remplacés par des hashes `openssl passwd`.

Variables attendues :

```yaml
vault_wordpress_db_password: "..."
vault_wordpress_mariadb_root_password: "..."
```

## Déploiement

```bash
./scripts/run-playbook.sh vps app --tags wordpress
```

## Backup

Le backup ne copie pas le répertoire MariaDB à chaud.

Il produit :

```text
/srv/vps/backups/wordpress/
├── wordpress.sql
└── wp-content.tar.gz
```

- `wordpress.sql` : dump logique MariaDB ;
- `wp-content.tar.gz` : uploads, thèmes et plugins ;
- le coeur WordPress est reconstructible depuis l'image Docker/IAC.

Le timer systemd est déclaratif : `backup_wordpress_enabled=true` l'active ; `false` l'arrête et le désactive.

## Collecte hors VPS

Les permissions VPS permettent au groupe `backup-readers` de lire les artefacts. Le rôle HomeLab `backup_remote_collect` récupère la source `wordpress` vers :

```text
/srv/homelab/backups/vps01/wordpress/
```

La collecte a été testée avec succès.

## Restore

Le restore WordPress a été validé de bout en bout :

1. validation du dump et de l'archive ;
2. extraction de `wp-content` en staging ;
3. arrêt du conteneur WordPress ;
4. `DROP DATABASE` ;
5. `CREATE DATABASE` ;
6. réattribution des droits à l'utilisateur WordPress ;
7. import du dump SQL ;
8. contrôle du nombre de tables ;
9. remplacement de `wp-content` ;
10. correction des permissions ;
11. redémarrage WordPress via `trap EXIT`.

Le test fonctionnel a consisté à créer une page après le backup, lancer le restore sans refaire de backup et vérifier la disparition de cette page.

## État V1

```text
Déploiement Ansible       OK
Docker / MariaDB          OK
Traefik / HTTPS           OK
Persistance               OK
Backup DB + wp-content    OK
Timer systemd             OK
Métriques monitoring      OK
Collecte VPS -> HomeLab   OK
Restore DB DROP/CREATE    OK
Restore wp-content        OK
Test fonctionnel restore  OK
```
