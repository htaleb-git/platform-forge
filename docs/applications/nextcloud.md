# Application — Nextcloud VPS

## Rôle

Nextcloud fournit sur le VPS les fonctions personnelles légères nécessitant un accès permanent depuis Internet, notamment contacts et calendriers.

## État validé

- image : `nextcloud:25.0.2` ;
- version applicative observée : 25.0.2.3 ;
- hostname : `cloud.taleb.fr` ;
- HTTPS via Traefik ;
- base SQLite : `owncloud.db` ;
- CalDAV/CardDAV iPhone : validés ;
- maintenance mode désactivé après reconstruction ;
- persistance applicative validée.

## Backup V1

Le backup VPS protège :

```text
owncloud.db
config.php
```

Le script place temporairement Nextcloud en maintenance pour obtenir une copie cohérente de SQLite et effectue un contrôle d'intégrité.

Les données Nextcloud volumineuses sont volontairement hors scope du backup minimal V1 et devront faire l'objet d'une politique dédiée si elles deviennent critiques.

## Restore

Le restore Nextcloud a été testé avec succès. Il remet la base SQLite et la configuration puis permet la remise en service de l'application.

## Commandes utiles

```bash
./scripts/run-playbook.sh vps app --tags nextcloud
./scripts/run-playbook.sh vps bkp --tags backup_nextcloud
sudo systemctl start backup-nextcloud.service
sudo journalctl -u backup-nextcloud.service -n 100 --no-pager
```
