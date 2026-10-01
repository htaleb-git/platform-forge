# V1 Limitations

- Ubuntu 24.04 is the validated target platform.
- Platform Forge is a single-server platform, not a high-availability or
  multi-node orchestrator.
- Nextcloud uses SQLite. Its first installation is interactive, but its V1
  backup and restore cover SQLite, configuration, and user data.
- WordPress requires its web installer after infrastructure deployment.
- Internal TLS supports either operator-provided material or one generated
  self-signed certificate. DNS/name resolution and client trust remain operator
  responsibilities; Platform Forge does not provide a private CA or certificate
  lifecycle platform.
- Platform Forge uses a configured Restic repository but does not provision
  storage, mounts, remote accounts, or cloud buckets.
- Pinned images are the tested Platform Forge baseline. There is no automatic
  application migration framework for GitLab, Nextcloud, PostgreSQL, MariaDB,
  or other application data formats.
- Restores are manual, destructive operations with exact snapshot selection and
  confirmations. Protected restore execution can remain silent while it works.
  An application rollback is attempted on failure but cannot replace a tested
  recovery plan.
- Resource needs depend on enabled applications, data size, traffic, and
  retention. An 8 GiB disposable validation VM worked at idle; it is not a
  universal production sizing recommendation, especially with GitLab.
