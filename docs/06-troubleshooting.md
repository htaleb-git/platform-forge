# Troubleshooting

## Bootstrap Cannot Connect

Use the existing Ubuntu bootstrap account in inventory. If it uses SSH password
authentication, add `--ask-pass` to the `init` command. The runner always adds
the sudo password prompt.

If bootstrap reports a missing administrator key, check that every
`platform_admin_authorized_keys` entry is an existing public-key file on the
Ansible controller, not a path on the target server.

## Cannot Connect After Bootstrap

Set `ansible_user: platform-admin` after `init`. If you changed
`platform_ssh_port`, update `ansible_port` too. Use the configured public key;
SSH password authentication is disabled.

## TLS or Hostname Does Not Work

For internal TLS with `traefik_internal_tls_source: provided`, verify that both
certificate and private key are present in Vault and trusted by the client. For
`generated`, verify the generated material remains in the Traefik certificate
directory and that the client resolves the configured hostname and trusts its
self-signed certificate. For ACME, verify public A/AAAA DNS, TCP 80/443
reachability through every firewall/NAT layer, a real ACME email, and DNS
propagation. Platform Forge does not configure client DNS or trust.

## Nextcloud Is Not Configured

The first playbook run starts Nextcloud but the web installer remains
interactive. Complete it in the browser, then rerun `applications` so proxy
settings can be applied.

## Restic Fails

Confirm that the repository was initialized with the same password as
`vault_restic_password`, that any mounted storage is present, and that backend
credentials in `restic_environment` are valid. Inspect the relevant service:

```bash
sudo journalctl -u backup-restic.service -n 100 --no-pager
sudo journalctl -u check-restic.service -n 100 --no-pager
```

## Monitoring Is Missing Data

Confirm every enabled component was deployed and inspect Prometheus targets from
inside the existing Prometheus container:

```bash
docker exec prometheus wget -qO- \
  'http://localhost:9090/api/v1/query?query=up' | python3 -m json.tool
```

For Grafana access failures, verify its configured hostname resolves from the
browser client and that TLS is trusted.

## Restore Is Rejected or Fails

Use a supported application and an explicit hexadecimal snapshot ID. Do not use
`latest`. Read the prompt before entering both confirmations. If restoration or
rollback reports failure, do not retry blindly: retain logs and recover from a
known-good snapshot after identifying the failed stage. A protected restore can
remain silent after its start notice while it operates on application data.
