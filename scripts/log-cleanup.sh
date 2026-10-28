#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="${LOG_DIR:-/var/log}"
LOG_PATTERN="${LOG_PATTERN:-*.log}"
LOG_MAX_AGE_DAYS="${LOG_MAX_AGE_DAYS:-30}"
DRY_RUN="${DRY_RUN:-1}"

case "$LOG_MAX_AGE_DAYS" in
    ''|*[!0-9]*)
        echo "LOG_MAX_AGE_DAYS debe ser un número entero." >&2
        exit 1
        ;;
esac

if [ ! -d "$LOG_DIR" ]; then
    echo "No existe el directorio de logs: $LOG_DIR" >&2
    exit 1
fi

mapfile -d '' files < <(
    find "$LOG_DIR" -type f \
        -name "$LOG_PATTERN" \
        -mtime "+${LOG_MAX_AGE_DAYS}" \
        -print0 2>/dev/null
)

if [ "${#files[@]}" -eq 0 ]; then
    echo "No hay archivos que coincidan con $LOG_PATTERN con más de ${LOG_MAX_AGE_DAYS} días."
    exit 0
fi

for file in "${files[@]}"; do
    if [ "$DRY_RUN" = "1" ]; then
        printf '[dry-run] eliminaría %s\n' "$file"
    else
        rm -f -- "$file"
        printf 'eliminado %s\n' "$file"
    fi
done

if [ "$DRY_RUN" = "1" ]; then
    echo "Modo simulación. Ejecuta con DRY_RUN=0 para eliminar."
fi
