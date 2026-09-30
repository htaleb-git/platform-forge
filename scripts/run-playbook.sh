#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
PLAYBOOK_DIR="${PROJECT_DIR}/deploy/playbooks"

declare -A PLAYBOOKS=(
  [init]="01-init-server.yml"
  [system]="02-system.yml"
  [runtime]="03-runtime.yml"
  [applications]="04-applications.yml"
  [backup]="05-backup.yml"
  [restore]="06-restore.yml"
  [maintenance]="07-maintenance.yml"
  [monitoring]="08-monitoring.yml"
)

ALLOWED_OPERATION_APPS=(gitlab nextcloud n8n)
ALLOWED_OPERATIONS=(start stop restart status)
ALLOWED_RESTORE_APPS=(gitlab nextcloud n8n wordpress)

usage() {
  cat <<'EOF'
Usage:
  ./scripts/run-playbook.sh <target> <command> [ansible-playbook options]
  ./scripts/run-playbook.sh <target> operation <application> <operation> [options]
  ./scripts/run-playbook.sh <target> restore <application> [options]

Canonical commands:
  init          01-init-server.yml
  system        02-system.yml
  runtime       03-runtime.yml
  applications  04-applications.yml
  backup        05-backup.yml
  restore       06-restore.yml (requires an application)
  maintenance   07-maintenance.yml
  monitoring    08-monitoring.yml

Application operations:
  Applications: gitlab, nextcloud, n8n
  Operations:   start, stop, restart, status

Restore applications:
  gitlab, nextcloud, n8n, wordpress

Examples:
  ./scripts/run-playbook.sh platform01 init
  ./scripts/run-playbook.sh platform01 applications --tags n8n
  ./scripts/run-playbook.sh platform01 operation n8n status
  ./scripts/run-playbook.sh platform01 maintenance --check --diff
  ./scripts/run-playbook.sh platform01 restore n8n

The target "all" is rejected. Restore selects only explicitly tagged,
fail-closed tasks and still requires interactive destructive confirmations.
Additional options are passed unchanged to ansible-playbook. The runner adds
-K / --ask-become-pass automatically.
EOF
}

error() {
  printf 'ERROR: %s\n\n' "$*" >&2
  printf "Use '%s --help' for usage.\n" "$0" >&2
  exit 1
}

contains() {
  local expected="$1"
  shift
  local value

  for value in "$@"; do
    if [[ "${value}" == "${expected}" ]]; then
      return 0
    fi
  done

  return 1
}

reject_selection_options() {
  local option

  for option in "$@"; do
    case "${option}" in
      -t|--tags|--tags=*|--skip-tags|--skip-tags=*)
        error "Tag selection cannot override a protected operation or restore command."
        ;;
    esac
  done
}

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

case "$1" in
  -h|--help|help)
    usage
    exit 0
    ;;
esac

[[ $# -ge 2 ]] || error "A target and command are required."

TARGET="$1"
COMMAND="$2"
shift 2

[[ -n "${TARGET}" && "${TARGET}" != -* ]] \
  || error "The target must be a non-option value."

case "${TARGET}" in
  all|"*"|all:\*)
    error "The target '${TARGET}' is forbidden; select one host or explicit group."
    ;;
esac

PLAYBOOK=""
COMMAND_DESCRIPTION="${COMMAND}"
SPECIAL_ARGS=()

case "${COMMAND}" in
  operation)
    [[ $# -ge 2 ]] \
      || error "Expected: operation <application> <start|stop|restart|status>."

    APPLICATION="$1"
    OPERATION="$2"
    shift 2
    reject_selection_options "$@"

    contains "${APPLICATION}" "${ALLOWED_OPERATION_APPS[@]}" \
      || error "Unsupported operation application: '${APPLICATION}'."
    contains "${OPERATION}" "${ALLOWED_OPERATIONS[@]}" \
      || error "Unsupported application operation: '${OPERATION}'."

    PLAYBOOK="${PLAYBOOKS[applications]}"
    COMMAND_DESCRIPTION="operation ${APPLICATION} ${OPERATION}"
    SPECIAL_ARGS+=(
      --tags "operate-${APPLICATION}"
      --extra-vars "operation=${OPERATION}"
    )
    ;;

  restore)
    [[ $# -ge 1 && "$1" != -* ]] \
      || error "Restore requires an explicit application."

    APPLICATION="$1"
    shift
    reject_selection_options "$@"

    contains "${APPLICATION}" "${ALLOWED_RESTORE_APPS[@]}" \
      || error "Unsupported restore application: '${APPLICATION}'."

    PLAYBOOK="${PLAYBOOKS[restore]}"
    COMMAND_DESCRIPTION="restore ${APPLICATION}"
    SPECIAL_ARGS+=(--tags "restore-${APPLICATION}")
    ;;

  *)
    [[ -n "${PLAYBOOKS[${COMMAND}]:-}" ]] \
      || error "Unknown command: '${COMMAND}'."
    PLAYBOOK="${PLAYBOOKS[${COMMAND}]}"
    ;;
esac

PLAYBOOK_PATH="${PLAYBOOK_DIR}/${PLAYBOOK}"
[[ -f "${PLAYBOOK_PATH}" ]] || error "Playbook not found: ${PLAYBOOK_PATH}"

ANSIBLE_ARGS=(
  -K
  "${PLAYBOOK_PATH}"
  --limit "${TARGET}"
  "$@"
  "${SPECIAL_ARGS[@]}"
)

printf '%s\n' '============================================================'
printf '%s\n' ' Ansible Playbook Runner'
printf '%s\n' '============================================================'
printf 'Project : %s\n' "${PROJECT_DIR}"
printf 'Target  : %s\n' "${TARGET}"
printf 'Command : %s\n' "${COMMAND_DESCRIPTION}"
printf 'Playbook: %s\n\n' "${PLAYBOOK_PATH}"
printf 'Command : ansible-playbook'
printf ' %q' "${ANSIBLE_ARGS[@]}"
printf '\n\n'

cd "${PROJECT_DIR}"
exec ansible-playbook "${ANSIBLE_ARGS[@]}"
