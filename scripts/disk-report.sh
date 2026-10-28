#!/usr/bin/env bash
set -euo pipefail

SCAN_PATH="${SCAN_PATH:-/home}"
TOP_N="${TOP_N:-10}"

case "$TOP_N" in
    ''|*[!0-9]*)
        echo "TOP_N debe ser un número entero." >&2
        exit 1
        ;;
esac

echo "== Uso de disco =="
df -hP

echo
echo "== Uso de inodos =="
df -iP

echo
if [ ! -d "$SCAN_PATH" ]; then
    echo "No existe el directorio a analizar: $SCAN_PATH" >&2
    exit 1
fi

echo "== Directorios más grandes en $SCAN_PATH =="
du -xhd1 "$SCAN_PATH" 2>/dev/null | sort -hr | head -n "$TOP_N"
