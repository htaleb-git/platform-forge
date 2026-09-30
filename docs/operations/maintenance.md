# Opération — Maintenance serveur

## Point d'entrée

```text
ansible/playbooks/09-maintenance.yml
```

Le playbook combine :

- `system_update` pour la maintenance APT ;
- `maintain_server` pour les contrôles de santé et la maintenance Docker/Restic.

## Maintenance standard

Commande directe :

```bash
ansible-playbook -K ansible/playbooks/09-maintenance.yml \
  --limit homelab01
```

Via runner :

```bash
./scripts/run-playbook.sh hml mnt
```

Comportement par défaut :

```text
safe upgrade                 oui
autoclean                    oui
autoremove                   non
reboot automatique           non
health checks                oui
Restic check                 oui
Docker cleanup               non
```

## Health checks uniquement

```bash
./scripts/run-playbook.sh hml mnt --tags health
```

Les checks couvrent :

- services systemd failed ;
- utilisation du filesystem racine ;
- présence du mount de backup ;
- repository Restic ;
- service Docker ;
- `docker system df` ;
- état des conteneurs.

Un conteneur `Exited` n'est pas considéré automatiquement comme une erreur : certaines applications du HomeLab sont volontairement exploitées à la demande.

## Mise à jour système uniquement

Simulation :

```bash
./scripts/run-playbook.sh hml mnt \
  --tags system \
  --check --diff
```

Exécution réelle :

```bash
./scripts/run-playbook.sh hml mnt \
  --tags system
```

## Reboot

Par défaut :

```yaml
system_update_reboot_enabled: false
```

Le rôle vérifie néanmoins `/var/run/reboot-required`.

Activation explicite :

```bash
./scripts/run-playbook.sh hml mnt \
  -e system_update_reboot_enabled=true
```

## Autoremove

Par défaut :

```yaml
system_update_autoremove: false
```

Activation explicite :

```bash
./scripts/run-playbook.sh hml mnt \
  -e system_update_autoremove=true
```

`autoclean` supprime les anciennes archives APT ; il ne désinstalle pas les paquets.

## Docker cleanup

Par défaut :

```yaml
maintenance_docker_cleanup_enabled: false
```

Activation :

```bash
./scripts/run-playbook.sh hml mnt \
  --tags health \
  -e maintenance_docker_cleanup_enabled=true
```

Le cleanup est volontairement limité :

```text
docker image prune -f
docker builder prune -f --filter until=<age>
```

Aucun volume ni conteneur arrêté n'est supprimé.

## Fréquence recommandée

Maintenance standard :

```text
toutes les 2 à 4 semaines
```

Maintenance approfondie :

```text
tous les 2 à 3 mois
ou lorsque l'espace disque / Docker / le système le justifie
```

Le playbook reste manuel en V1.
