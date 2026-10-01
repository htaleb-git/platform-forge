# Monitoring and Maintenance

Monitoring components are independently opt-in:

| Component | Variable | Purpose |
|---|---|---|
| Node Exporter | `node_exporter_enabled` | Host and backup-job metrics |
| cAdvisor | `cadvisor_enabled` | Container metrics |
| Prometheus | `prometheus_enabled` | Metrics collection and retention |
| Grafana | `grafana_enabled` | Dashboards through Traefik |

Grafana requires Prometheus. Enable the components in inventory and deploy:

```bash
./scripts/run-playbook.sh platform01 monitoring \
  -i deploy/inventory/my-platform/hosts.yml \
  --ask-vault-pass
```

Grafana is available at the configured `grafana_hostname`, by default:

```text
https://grafana.example.com
```

Name resolution and TLS trust are operator responsibilities. Prometheus
scrapes itself and enabled exporters. Check targets from the existing Prometheus
container:

```bash
docker exec prometheus wget -qO- \
  'http://localhost:9090/api/v1/query?query=up' | python3 -m json.tool
```

Enabled targets should report `1`. Node Exporter listens on port 9100; cAdvisor
is scraped on port 8080. Backup and Restic jobs publish status metrics through
the Node Exporter textfile collector when it is enabled.

## Maintenance

Run routine maintenance explicitly:

```bash
./scripts/run-playbook.sh platform01 maintenance \
  -i deploy/inventory/my-platform/hosts.yml \
  --ask-vault-pass
```

`07-maintenance.yml` performs a safe APT upgrade, checks failed systemd
services, checks root disk use, checks Docker state and disk use, and runs a
Restic repository check when Restic is enabled. It does not reboot, autoremove,
or clean Docker by default.

Check `/var/run/reboot-required` after updates and schedule a reboot when
needed. To opt into limited Docker cleanup, explicitly set:

```bash
./scripts/run-playbook.sh platform01 maintenance \
  -i deploy/inventory/my-platform/hosts.yml \
  -e maintenance_docker_cleanup_enabled=true \
  --ask-vault-pass
```

This removes dangling images and builder cache older than the configured age.
It does not remove Docker volumes or stopped containers.
