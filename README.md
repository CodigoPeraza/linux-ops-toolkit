<div align="center">

# Linux Ops Toolkit

**Scripts de operación, auditoría y mantenimiento para servidores Linux.**

![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)
![systemd](https://img.shields.io/badge/systemd-000000?style=for-the-badge&logo=systemd&logoColor=white)
![ShellCheck](https://img.shields.io/badge/ShellCheck-2E8B57?style=for-the-badge&logo=gnu-bash&logoColor=white)

</div>

## Descripción

Kit de herramientas en Bash para tareas comunes de soporte y administración Linux: respaldos con retención, reporte de disco, auditoría de usuarios y llaves SSH, limpieza segura de logs y verificación de servicios.

El proyecto prioriza la seguridad operativa: las acciones destructivas inician en modo simulación, las rutas se configuran por variables de entorno y los scripts fallan de forma explícita cuando falta un requisito.

## Scripts

| Script | Función |
| --- | --- |
| `scripts/backup.sh` | Crea un `.tar.gz`, verifica su integridad y aplica retención. |
| `scripts/disk-report.sh` | Muestra espacio, inodos y directorios más grandes. |
| `scripts/user-audit.sh` | Revisa usuarios, grupos administrativos, contraseñas y llaves SSH. |
| `scripts/log-cleanup.sh` | Encuentra logs antiguos; por defecto solo simula la eliminación. |
| `scripts/service-health.sh` | Verifica el estado de servicios con `systemctl`. |

## Requisitos

- Linux con Bash 4.4 o superior.
- `tar`, `find`, `df`, `du`, `awk` y `sort`.
- `systemctl` para el script de servicios y el timer.
- `shellcheck` solo para desarrollo y pruebas.

## Configuración

```bash
cp config/ops.env.example config/ops.env
```

Ajusta las rutas y úsalo desde la terminal:

```bash
set -a
source config/ops.env
set +a
```

Variables principales:

| Variable | Valor por defecto | Uso |
| --- | --- | --- |
| `BACKUP_SOURCE` | `/etc` | Directorio que se respalda. |
| `BACKUP_DEST` | `backups/` | Destino de los respaldos. |
| `BACKUP_RETENTION_DAYS` | `7` | Días que se conservan los respaldos. |
| `SCAN_PATH` | `/home` | Ruta para el reporte de disco. |
| `LOG_DIR` | `/var/log` | Directorio para la limpieza de logs. |
| `LOG_MAX_AGE_DAYS` | `30` | Antigüedad mínima para considerar un log. |
| `DRY_RUN` | `1` | `1` simula; `0` elimina. |
| `SERVICES` | vacío | Servicios separados por espacios. |

## Uso

```bash
make backup
make disk
make users
make logs
make health
```

Ejemplos directos:

```bash
# Respaldo de /etc con retención de 14 días
BACKUP_SOURCE=/etc BACKUP_DEST=/var/backups/linux-ops-toolkit \
BACKUP_RETENTION_DAYS=14 ./scripts/backup.sh

# Reporte de los 15 directorios más grandes de /var
SCAN_PATH=/var TOP_N=15 ./scripts/disk-report.sh

# Simulación de limpieza de logs de más de 60 días
DRY_RUN=1 LOG_DIR=/var/log LOG_MAX_AGE_DAYS=60 ./scripts/log-cleanup.sh

# Verificación de servicios
SERVICES="sshd.service crond.service" ./scripts/service-health.sh
```

## Timer de systemd

El repositorio incluye un servicio y un timer para ejecutar el respaldo a diario.

Instalación en un servidor:

```bash
sudo mkdir -p /opt/linux-ops-toolkit /etc/linux-ops-toolkit
sudo cp -r scripts systemd config /opt/linux-ops-toolkit/
sudo cp config/ops.env.example /etc/linux-ops-toolkit/ops.env
sudo cp systemd/ops-backup.service systemd/ops-backup.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now ops-backup.timer
```

Verificación:

```bash
systemctl list-timers ops-backup.timer
systemctl status ops-backup.service
journalctl -u ops-backup.service
```

El servicio usa `EnvironmentFile=/etc/linux-ops-toolkit/ops.env` y ejecuta `/opt/linux-ops-toolkit/scripts/backup.sh`.

## Pruebas

```bash
make test
```

`make test` ejecuta ShellCheck, valida la sintaxis de los scripts y corre pruebas de humo en directorios temporales. Las pruebas no tocan `/etc`, `/var/log` ni respaldos reales.

## Seguridad operativa

- `log-cleanup.sh` inicia con `DRY_RUN=1`; revisar la salida antes de usar `DRY_RUN=0`.
- `backup.sh` verifica el archivo generado con `tar -tzf`.
- Los respaldos pueden contener información sensible; aplicar permisos y cifrado fuera del alcance del laboratorio.
- No se deben versionar `config/ops.env` ni los archivos generados.
- Ejecutar auditorías con el mínimo privilegio necesario.

## Checklist de auditoría

El documento [docs/audit-checklist.md](docs/audit-checklist.md) reúne verificaciones de cuentas, SSH, actualizaciones, servicios, red, disco, logs, permisos y respaldos.

## Limitaciones

- Está diseñado para distribuciones Linux con utilidades GNU.
- No implementa cifrado, almacenamiento remoto ni deduplicación de respaldos.
- La verificación de servicios depende de systemd.
- La auditoría es una lista de comprobación, no un escáner de vulnerabilidades.

## Materias que respalda

- Sistemas Operativos I y II.
- Soporte Técnico y Operaciones.
- Automatización y Administración de Servidores.
- Auditoría de Sistemas.

## Autor

**Francisco Javier Peraza** · [GitHub](https://github.com/CodigoPeraza) · [contacto.peraza@gmail.com](mailto:contacto.peraza@gmail.com)
