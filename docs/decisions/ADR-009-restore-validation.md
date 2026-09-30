# ADR-009 — Valider les sauvegardes par un restore réel

- **Statut :** Accepté
- **Date :** 2026-07

## Contexte

Un backup réussi peut être inutilisable lors d’un incident.

## Décision

Ne déclarer la capacité DR opérationnelle qu’après une restauration et des tests fonctionnels.

## Conséquences

Temps de test supplémentaire, mais risque de fausse sécurité fortement réduit.
