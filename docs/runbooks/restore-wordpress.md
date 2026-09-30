# Runbook — Restore WordPress VPS

## Attention

Le restore est destructif pour la base WordPress courante. Il n'est jamais exécuté automatiquement.

## Pré-contrôles

```bash
sudo ls -lh /srv/vps/backups/wordpress/
sudo bash -n /usr/local/sbin/restore-wordpress.sh
```

Les deux artefacts doivent être présents et non vides :

```text
wordpress.sql
wp-content.tar.gz
```

## Exécuter

```bash
sudo /usr/local/sbin/restore-wordpress.sh
```

## Comportement

```text
validation backup
→ extraction wp-content
→ stop WordPress
→ DROP/CREATE DB
→ GRANT utilisateur
→ import SQL
→ contrôle tables
→ remplacement wp-content
→ permissions
→ restart WordPress
```

MariaDB reste démarrée pendant l'opération afin de recevoir l'import SQL. Le conteneur WordPress est arrêté pour éviter des accès concurrents pendant la reconstruction.

Un `trap EXIT` redémarre WordPress même en cas d'erreur après son arrêt.

## Contrôles après restore

```bash
docker ps --filter name=wordpress
curl -I https://hicham.taleb.fr
```

Vérifier également la connexion à l'administration WordPress.

## Test fonctionnel validé

Procédure utilisée pour valider réellement le restore :

1. produire un backup frais ;
2. créer une page temporaire `TEST RESTORE` ;
3. ne pas refaire de backup ;
4. exécuter le restore ;
5. vérifier que la page temporaire a disparu.

Ce test valide que la base restaurée correspond bien à l'état sauvegardé.
