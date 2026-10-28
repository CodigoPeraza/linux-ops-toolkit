#!/usr/bin/env bash
set -euo pipefail

SERVICES="${SERVICES:-}"

if ! command -v systemctl >/dev/null 2>&1; then
    echo "systemctl no está disponible; no se pueden verificar servicios." >&2
    exit 0
fi

if [ -z "${SERVICES// /}" ]; then
    echo "No hay servicios configurados en SERVICES."
    exit 0
fi

failed=0
for service in $SERVICES; do
    state="$(systemctl is-active "$service" 2>/dev/null || true)"
    enabled="$(systemctl is-enabled "$service" 2>/dev/null || true)"
    printf '%-32s active=%-12s enabled=%s\n' \
        "$service" "${state:-unknown}" "${enabled:-unknown}"

    if [ "$state" != "active" ]; then
        failed=1
    fi
done

if [ "$failed" -ne 0 ]; then
    echo "Hay servicios que no están activos." >&2
fi

exit "$failed"
