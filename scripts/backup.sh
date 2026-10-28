#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_SOURCE="${BACKUP_SOURCE:-/etc}"
BACKUP_DEST="${BACKUP_DEST:-$SCRIPT_DIR/../backups}"
BACKUP_RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-7}"
BACKUP_NAME="${BACKUP_NAME:-backup}"

case "$BACKUP_RETENTION_DAYS" in
    ''|*[!0-9]*)
        echo "BACKUP_RETENTION_DAYS debe ser un número entero." >&2
        exit 1
        ;;
esac

if [ ! -d "$BACKUP_SOURCE" ]; then
    echo "No existe el directorio de origen: $BACKUP_SOURCE" >&2
    exit 1
fi

mkdir -p "$BACKUP_DEST"

timestamp="$(date +%Y%m%d_%H%M%S)"
archive="$BACKUP_DEST/${BACKUP_NAME}_${timestamp}.tar.gz"

tar -czf "$archive" -C "$(dirname "$BACKUP_SOURCE")" "$(basename "$BACKUP_SOURCE")"

if ! tar -tzf "$archive" >/dev/null 2>&1; then
    echo "El archivo generado no es un tar.gz válido: $archive" >&2
    exit 1
fi

find "$BACKUP_DEST" -maxdepth 1 -type f \
    -name "${BACKUP_NAME}_*.tar.gz" \
    -mtime "+${BACKUP_RETENTION_DAYS}" \
    -delete

echo "Backup generado: $archive"
echo "Retención aplicada: ${BACKUP_RETENTION_DAYS} días"
