# ADR-015 — Monitoring séparé et métriques de jobs via Textfile Collector

- Status: Accepted
- Date: 2026-08-20

## Contexte

Le HomeLab doit superviser l'hôte, Docker et des jobs ponctuels de backup/maintenance. Les scripts n8n, GitLab, Immich et Restic ne sont pas des services HTTP permanents et ne justifient pas chacun un exporter dédié.

## Décision

1. Déployer le monitoring via un playbook dédié `10-monitoring.yml`.
2. Utiliser Node Exporter pour l'hôte et cAdvisor pour Docker.
3. Utiliser Prometheus comme collecteur et Grafana comme interface.
4. Utiliser le Node Exporter Textfile Collector pour les métriques produites par les scripts de backup et Restic.
5. Écrire les fichiers `.prom` de manière atomique.
6. Versionner les dashboards Grafana dans Git et provisionner la datasource avec l'UID stable `prometheus`.
7. Utiliser un réseau Docker `monitoring` distinct du réseau `proxy`.

## Conséquences

### Positives

- architecture simple ;
- pas d'exporter custom à maintenir pour chaque backup ;
- métriques disponibles même après la fin du job ;
- dashboards reproductibles ;
- séparation claire entre runtime applicatif et observabilité ;
- extension simple aux futurs volumes `backups02` / `medias02`.

### Contraintes

- un fichier `.prom` peut devenir obsolète si le job ne tourne plus ; le dashboard doit donc surveiller l'âge du dernier succès ;
- les noms de métriques deviennent une interface à maintenir ;
- Grafana et les dashboards doivent partager un UID de datasource stable ;
- l'accès Node Exporter depuis Docker nécessite une règle réseau/UFW adaptée.
