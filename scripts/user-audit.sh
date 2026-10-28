#!/usr/bin/env bash
set -euo pipefail

HUMAN_MIN_UID="${HUMAN_MIN_UID:-1000}"

case "$HUMAN_MIN_UID" in
    ''|*[!0-9]*)
        echo "HUMAN_MIN_UID debe ser un número entero." >&2
        exit 1
        ;;
esac

echo "== Usuarios con UID >= $HUMAN_MIN_UID =="
awk -F: -v min="$HUMAN_MIN_UID" '
    $3 >= min && $1 != "nobody" {
        printf "%-20s UID=%-6s GID=%-6s HOME=%-25s SHELL=%s\n", $1, $3, $4, $6, $7
    }
' /etc/passwd

echo
echo "== Estado de contraseñas =="
if command -v passwd >/dev/null 2>&1; then
    while IFS=: read -r user _ uid _ _ _ _; do
        [ "$uid" -ge "$HUMAN_MIN_UID" ] || continue
        [ "$user" = "nobody" ] && continue
        status="$(passwd -S "$user" 2>/dev/null || echo "sin acceso a /etc/shadow")"
        printf '%-20s %s\n' "$user" "$status"
    done < /etc/passwd
else
    echo "El comando passwd no está disponible."
fi

echo
echo "== Grupos administrativos =="
getent group sudo wheel 2>/dev/null || echo "No se encontraron grupos sudo/wheel."

echo
echo "== Llaves SSH autorizadas =="
found=0
while IFS=: read -r user _ uid _ _ home _; do
    [ "$uid" -ge "$HUMAN_MIN_UID" ] || continue
    [ "$user" = "nobody" ] && continue
    keys="$home/.ssh/authorized_keys"
    if [ -f "$keys" ]; then
        count="$(grep -cE '^(ssh-|ecdsa-|sk-)' "$keys" 2>/dev/null || true)"
        printf '%-20s %s llave(s) en %s\n' "$user" "${count:-0}" "$keys"
        found=1
    fi
done < /etc/passwd
[ "$found" -eq 1 ] || echo "Sin llaves autorizadas en cuentas humanas."

echo
echo "== Últimos accesos =="
if command -v lastlog >/dev/null 2>&1; then
    lastlog | awk 'NR == 1 || $2 != "**Never"'
else
    echo "El comando lastlog no está disponible."
fi
