# ADR-004 — Séparer plateforme backup et logique applicative

- **Statut :** Accepté
- **Date :** 2026-07

## Contexte

Un rôle unique accumulerait les détails de PostgreSQL, GitLab et futurs services.

## Décision

Conserver `platform/backup` générique et un rôle `backup_<application>` par workload.

## Conséquences

Responsabilités claires et évolution indépendante.
