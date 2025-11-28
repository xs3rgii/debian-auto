# Debian-Auto – Instalador Debian Automatizado con Preseed

Repositorio para la instalación automática de Debian 13 basado en un fichero de preconfiguración (preseed.cfg) vía red.

> **Nota:** La variable de la ISO puede cambiarse de nombre sin problemas.

## Uso

### 1. Clonar el repositorio
```bash
git clone https://github.com/xs3rgii/debian-auto.git
cd debian-auto
```

### 2. Ejecutar el script
```bash
sudo ./make_iso.sh
```

## Diagnóstico

### Comandos para monitorizar el estado de la instalación
```bash
# Ver el log del sistema en tiempo real
tail -f /var/log/syslog

# Ver el log principal de partman
tail -f /var/log/partman
```

### Herramienta útil para diagnóstico

Transferencia de logs mediante netcat:
```bash
# En el equipo receptor (escucha en el puerto 4444 y guarda en 'log')
nc -l -p 4444 > log

# En el equipo emisor (envía el log de partman a la IP 172.22.15.228)
nc 172.22.15.228 4444 < /var/log/partman
```
