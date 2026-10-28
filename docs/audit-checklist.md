# Checklist de auditoría básica de Linux

Lista de verificación para revisar un servidor Linux de forma ordenada. No sustituye un análisis de vulnerabilidades ni una auditoría formal.

## 1. Cuentas y privilegios

- [ ] Revisar cuentas con UID >= 1000: `./scripts/user-audit.sh`.
- [ ] Confirmar que las cuentas de servicio no tienen shell interactivo.
- [ ] Revisar quién pertenece a `sudo` o `wheel`: `getent group sudo wheel`.
- [ ] Deshabilitar cuentas que no se usan: `sudo usermod -L usuario`.
- [ ] Revisar contraseñas bloqueadas o vacías: `sudo passwd -S usuario`.
- [ ] Confirmar que `root` no inicia sesión directamente por SSH.

## 2. Acceso remoto

- [ ] Revisar `/etc/ssh/sshd_config`:
  - `PermitRootLogin no`
  - `PasswordAuthentication no` cuando se usan llaves
  - `PubkeyAuthentication yes`
- [ ] Revisar llaves autorizadas: `~/.ssh/authorized_keys`.
- [ ] Validar permisos: `chmod 700 ~/.ssh` y `chmod 600 ~/.ssh/authorized_keys`.
- [ ] Revisar intentos fallidos: `sudo journalctl -u sshd --since "24 hours ago"`.
- [ ] Confirmar que el firewall solo expone los puertos necesarios.

## 3. Actualizaciones y paquetes

- [ ] Consultar actualizaciones disponibles.
- [ ] Aplicar parches de seguridad.
- [ ] Revisar si el sistema requiere reinicio.
- [ ] Eliminar paquetes que ya no se usan.

En Fedora/RHEL:

```bash
sudo dnf check-update
sudo dnf upgrade --refresh
sudo needs-restarting -r
```

## 4. Servicios y tareas programadas

- [ ] Listar servicios fallidos: `systemctl --failed`.
- [ ] Revisar servicios habilitados: `systemctl list-unit-files --state=enabled`.
- [ ] Comprobar los servicios críticos: `./scripts/service-health.sh`.
- [ ] Revisar tareas de `root`: `sudo crontab -l`.
- [ ] Revisar timers: `systemctl list-timers --all`.
- [ ] Confirmar que no hay tareas desconocidas en `/etc/cron.*`.

## 5. Red

- [ ] Revisar interfaces y direcciones: `ip address`.
- [ ] Revisar rutas: `ip route`.
- [ ] Revisar puertos en escucha: `ss -tulpn`.
- [ ] Confirmar que los servicios escuchan solo donde deben.
- [ ] Revisar reglas de firewall: `sudo firewall-cmd --list-all` o `sudo nft list ruleset`.

## 6. Disco y capacidad

- [ ] Revisar espacio: `./scripts/disk-report.sh`.
- [ ] Revisar inodos.
- [ ] Buscar archivos grandes: `sudo find / -xdev -type f -size +1G -ls 2>/dev/null`.
- [ ] Revisar logs que crecen demasiado.
- [ ] Confirmar que `/var` y `/home` tienen espacio suficiente.

## 7. Logs

- [ ] Revisar errores recientes: `sudo journalctl -p err --since "24 hours ago"`.
- [ ] Revisar autenticaciones: `sudo journalctl -u sshd`.
- [ ] Revisar arranques del sistema: `sudo journalctl --list-boots`.
- [ ] Confirmar rotación de logs.
- [ ] Ejecutar la limpieza en modo simulación: `./scripts/log-cleanup.sh`.

## 8. Permisos y archivos sensibles

- [ ] Revisar archivos con permisos excesivos:
  `sudo find /etc /home -xdev -type f -perm -0002 -ls 2>/dev/null`.
- [ ] Confirmar permisos de `/etc/shadow` y `/etc/passwd`.
- [ ] Revisar directorios world-writable:
  `sudo find / -xdev -type d -perm -0002 -ls 2>/dev/null`.
- [ ] Revisar archivos con SUID/SGID innecesarios.
- [ ] Confirmar que los secretos no están en repositorios ni en texto plano.

## 9. Respaldos

- [ ] Confirmar que el respaldo se ejecuta: `systemctl list-timers ops-backup.timer`.
- [ ] Verificar que el archivo generado se puede abrir: `tar -tzf archivo.tar.gz`.
- [ ] Probar una restauración en un entorno aislado.
- [ ] Confirmar que el respaldo se guarda fuera del servidor.
- [ ] Revisar la retención configurada.

## 10. Cierre de la auditoría

- [ ] Registrar hallazgos, riesgo y acción recomendada.
- [ ] Priorizar primero accesos, exposiciones de red y respaldos.
- [ ] Asignar responsable y fecha de corrección.
- [ ] Volver a verificar los hallazgos corregidos.
