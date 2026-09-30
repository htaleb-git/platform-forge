# ADR-010 — Maintenance serveur sûre et explicite

## Status

Accepted

## Context

Le HomeLab doit être maintenu régulièrement sans transformer une opération de routine en risque pour :

- les applications on-demand ;
- les volumes Docker ;
- les données persistantes ;
- le repository Restic.

Un nettoyage Docker agressif serait incompatible avec le modèle d'exploitation du HomeLab, où un conteneur arrêté peut être volontairement conservé.

## Decision

Créer :

- `09-maintenance.yml` comme point d'entrée ;
- `system/system_update` pour les mises à jour APT ;
- `operations/maintain_server` pour les contrôles de santé et opérations de maintenance.

Les valeurs destructives restent désactivées par défaut.

### Valeurs par défaut

```text
autoremove             false
reboot                 false
Docker cleanup         false
Restic check           true
```

### Docker cleanup autorisé

Uniquement sur activation explicite :

- images dangling ;
- cache builder ancien.

Sont exclus de l'automatisation :

- volumes ;
- conteneurs arrêtés ;
- `docker system prune -a`.

## Consequences

### Benefits

- maintenance reproductible ;
- risque réduit ;
- état du serveur visible après maintenance ;
- conservation du modèle on-demand ;
- interface commune réutilisable sur le futur VPS.

### Trade-offs

- certaines ressources inutilisées nécessitent toujours une décision humaine ;
- le playbook n'est pas un garbage collector autonome ;
- `restic check` peut devenir plus coûteux lorsque le repository grossit.

## Operational policy

- maintenance standard toutes les 2 à 4 semaines ;
- maintenance approfondie tous les 2 à 3 mois ou selon métriques ;
- reboot uniquement lorsque planifié ;
- cleanup Docker uniquement sur demande explicite.
