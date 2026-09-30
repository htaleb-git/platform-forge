# ADR-003 — Utiliser Restic comme moteur de sauvegarde

- **Statut :** Accepté
- **Date :** 2026-07

## Contexte

Le projet a besoin de snapshots chiffrés, dédupliqués et vérifiables.

## Décision

Utiliser Restic pour stocker les artefacts cohérents produits par chaque workload.

## Conséquences

Rétention et intégrité communes ; le mot de passe Restic devient critique.
