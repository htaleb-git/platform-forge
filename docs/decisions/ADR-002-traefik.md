# ADR-002 — Utiliser Traefik comme reverse proxy partagé

- **Statut :** Accepté
- **Date :** 2026-07

## Contexte

Plusieurs applications doivent être exposées en HTTPS sans publier chaque port.

## Décision

Déployer Traefik comme composant plateforme, avec `exposedByDefault=false` et des labels applicatifs.

## Conséquences

Centralise TLS et l’exposition, mais devient une dépendance partagée.
