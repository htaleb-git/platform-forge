# ADR-007 — Déployer GitLab Omnibus avec Docker Compose

- **Statut :** Accepté
- **Date :** 2026-07

## Contexte

Une solution GitLab complète mais exploitable simplement est nécessaire.

## Décision

Utiliser l’image officielle GitLab CE Omnibus dans une stack Compose.

## Conséquences

Backup natif et maintenance simplifiée, au prix d’une empreinte mémoire importante.
