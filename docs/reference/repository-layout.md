# Référence — Organisation du dépôt

```text
infrastructure/
├── ansible.cfg
├── requirements.yml
├── scripts/
│   └── run-playbook.sh
├── ansible/
│   ├── inventory/
│   │   ├── group_vars/
│   │   │   ├── all/
│   │   │   │   ├── applications.yml
│   │   │   │   ├── backup.yml
│   │   │   │   └── images.yml
│   │   │   ├── homelab/
│   │   │   └── vps/
│   │   └── host_vars/
│   │       ├── homelab01/
│   │       │   ├── main.yml
│   │       │   ├── vault.yml
│   │       │   └── vault_luks.yml
│   │       └── vps01/
│   │           ├── main.yml
│   │           └── vault.yml
│   ├── playbooks/
│   │   ├── 01-init-server.yml
│   │   ├── 02-network-homelab.yml
│   │   ├── 02-network-vps.yml
│   │   ├── 03-system.yml
│   │   ├── 04-runtime.yml
│   │   ├── 05-applications.yml
│   │   ├── 06-backup-homelab.yml
│   │   ├── 06-backup-vps.yml
│   │   ├── 07-operations.yml
│   │   ├── 08-restore-homelab.yml
│   │   ├── 08-restore-vps.yml
│   │   ├── 09-maintenance.yml
│   │   └── 10-monitoring.yml
│   └── roles/
│       ├── system/
│       ├── platform/
│       ├── applications/
│       │   ├── n8n/
│       │   ├── gitlab/
│       │   ├── immich/
│       │   ├── nextcloud/
│       │   └── wordpress/
│       ├── monitoring/
│       │   ├── node_exporter/
│       │   ├── cadvisor/
│       │   ├── prometheus/
│       │   └── grafana/
│       └── operations/
│           ├── backup_n8n/
│           ├── backup_gitlab/
│           ├── backup_immich/
│           ├── backup_nextcloud/
│           ├── backup_wordpress/
│           ├── backup_remote_access/
│           ├── backup_remote_collect/
│           ├── manage_application/
│           └── maintain_server/
└── docs/
```

## Responsabilités

- `system` : capacités OS ;
- `platform` : runtime, stockage et capacités partagées ;
- `applications` : workloads ;
- `monitoring` : observabilité ;
- `operations` : lifecycle, backup, restore, collecte distante et maintenance.

## Principe de variables

Avant d'ajouter une variable ou un rôle, rechercher l'existant. Les variables communes restent dans `group_vars/all`; les activations et différences d'environnement restent dans `group_vars/homelab`, `group_vars/vps` ou les `host_vars`.
