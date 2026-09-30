# ADR-017 — Périmètre de backup WordPress

## Statut

Accepté.

## Contexte

WordPress utilise une image Docker reproductible et une base MariaDB persistante. Copier le datadir MariaDB à chaud serait fragile et le coeur WordPress est reconstructible.

## Décision

Le backup WordPress protège uniquement :

- un dump logique MariaDB `wordpress.sql` ;
- une archive `wp-content.tar.gz`.

Le coeur WordPress n'est pas sauvegardé. Le datadir MariaDB brut n'est pas copié à chaud.

## Restore

Le restore arrête WordPress, recrée la base (`DROP/CREATE`), réimporte le dump, restaure `wp-content`, remet les permissions puis redémarre WordPress.

## Validation

Un test fonctionnel de retour à un état sauvegardé a été réalisé avec succès.
