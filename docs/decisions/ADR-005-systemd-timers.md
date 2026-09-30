# ADR-005 — Utiliser les timers systemd

- **Statut :** Accepté
- **Date :** 2026-07

## Contexte

Ansible configure l’état mais ne doit pas servir de scheduler quotidien.

## Décision

Déployer scripts, services et timers avec Ansible ; laisser systemd exécuter.

## Conséquences

Logs dans journald, exécution persistante après reboot, couche opérationnelle à surveiller.
