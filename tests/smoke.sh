#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/source" "$TMP/backups" "$TMP/logs" "$TMP/scan"
printf 'contenido de prueba\n' > "$TMP/source/dato.txt"

BACKUP_SOURCE="$TMP/source" \
BACKUP_DEST="$TMP/backups" \
BACKUP_RETENTION_DAYS=7 \
"$ROOT/scripts/backup.sh" >/dev/null

archive_count="$(find "$TMP/backups" -maxdepth 1 -type f -name 'backup_*.tar.gz' | wc -l)"
if [ "$archive_count" -ne 1 ]; then
    echo "Fallo en backup: se esperaba 1 archivo y hay $archive_count" >&2
    exit 1
fi

SCAN_PATH="$TMP/scan" TOP_N=5 "$ROOT/scripts/disk-report.sh" >/dev/null

touch -d '40 days ago' "$TMP/logs/old.log"
if ! DRY_RUN=1 LOG_DIR="$TMP/logs" LOG_MAX_AGE_DAYS=30 \
    "$ROOT/scripts/log-cleanup.sh" | grep -q 'dry-run'; then
    echo "Fallo en log-cleanup: no reportó el modo simulación" >&2
    exit 1
fi

if [ ! -f "$TMP/logs/old.log" ]; then
    echo "Fallo en log-cleanup: dry-run eliminó el archivo" >&2
    exit 1
fi

DRY_RUN=0 LOG_DIR="$TMP/logs" LOG_MAX_AGE_DAYS=30 \
    "$ROOT/scripts/log-cleanup.sh" >/dev/null

if [ -f "$TMP/logs/old.log" ]; then
    echo "Fallo en log-cleanup: el archivo antiguo no se eliminó" >&2
    exit 1
fi

"$ROOT/scripts/user-audit.sh" >/dev/null
SERVICES="" "$ROOT/scripts/service-health.sh" >/dev/null

echo "Smoke tests OK"
