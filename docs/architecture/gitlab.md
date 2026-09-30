# Architecture GitLab

## Choix de déploiement

GitLab Community Edition est déployé avec l'image officielle GitLab Omnibus dans une stack Docker Compose unique.

## Flux réseau

```mermaid
flowchart LR
    C[Client] -->|HTTPS| T[Traefik]
    T -->|HTTP interne :80| G[GitLab Omnibus]
    C -->|SSH :2424| G
    G --- P[Docker network proxy]
    T --- P
```

GitLab écoute en HTTP dans le conteneur. Le chiffrement TLS est terminé par Traefik.

## Persistance

| Hôte | Conteneur |
|---|---|
| `.../gitlab/config` | `/etc/gitlab` |
| `.../gitlab/logs` | `/var/log/gitlab` |
| `.../gitlab/data` | `/var/opt/gitlab` |

## Santé

Le conteneur expose un healthcheck sur :

```text
http://localhost/-/health
```

Le rôle attend également une réponse HTTP 200 via le point d'entrée HTTPS local après le déploiement.

## Sauvegarde

```mermaid
flowchart TD
    G[gitlab-backup create] --> A[Archive native]
    G --> C[Configuration]
    A --> S[Staging application]
    C --> S2[Staging config]
    M[Version et nom d'archive] --> S3[Metadata]
    S --> R[Snapshot Restic]
    S2 --> R
    S3 --> R
```

La restauration vérifie la compatibilité de version avant de restaurer les données et la configuration.

## Disaster Recovery

La procédure a été exécutée et validée : retour à un état antérieur, présence des dépôts, accès Web et opérations Git.
