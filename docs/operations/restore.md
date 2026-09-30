# Opération — Restore

## Principe

Les restores sont volontairement explicites, manuels et destructifs lorsqu'ils modifient une application. Aucun restore n'est planifié par timer.

## HomeLab

### n8n / GitLab

Les restores sont orchestrés par les playbooks de restore HomeLab selon les tags et variables nécessaires.

### Immich

```bash
sudo /usr/local/sbin/restore-immich.sh <SNAPSHOT_ID> --verify-only
```

Le mode `--verify-only` est privilégié pour les contrôles réguliers.

## VPS — Nextcloud

Le restore Nextcloud V1 remet la base SQLite et `config.php`. La procédure a été validée après reconstruction du VPS.

## VPS — WordPress

Script :

```text
/usr/local/sbin/restore-wordpress.sh
```

Pré-contrôle :

```bash
sudo bash -n /usr/local/sbin/restore-wordpress.sh
sudo ls -lh /srv/vps/backups/wordpress/
```

Restore :

```bash
sudo /usr/local/sbin/restore-wordpress.sh
```

Séquence :

```text
validation dump/archive
→ extraction staging wp-content
→ stop WordPress
→ DROP DATABASE
→ CREATE DATABASE
→ GRANT
→ import SQL
→ contrôle tables
→ remplacement wp-content
→ permissions
→ restart WordPress
```

MariaDB reste active pour recevoir le dump. WordPress est arrêté pendant la reconstruction. Un `trap EXIT` garantit la tentative de redémarrage même en cas d'échec.

## Validation fonctionnelle WordPress

Test réellement exécuté :

1. backup frais ;
2. création d'une page `TEST RESTORE` ;
3. aucun nouveau backup ;
4. restore ;
5. disparition de la page.

Cela prouve que le restore revient réellement à l'état sauvegardé.

## Règle

Un backup n'est considéré comme fiable que si sa restauration ou au minimum sa vérification a été testée.
