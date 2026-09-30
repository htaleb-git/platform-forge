# ADR-008 — Mutualiser le lifecycle des applications

- **Statut :** Accepté
- **Date :** 2026-07

## Contexte

Créer des rôles start/stop/status par application produirait de la duplication.

## Décision

Utiliser un rôle `manage_application` avec une interface `application_*`.

## Conséquences

Interface homogène pour tous les workloads Docker Compose.
