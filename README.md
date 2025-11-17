# Debian-Auto – Instalador Debian automatizado con Preseed

Este repositorio contiene un **script (`make_iso.sh`)** y un archivo de **preseed (`preseed.cfg`)** para generar una ISO de Debian personalizada/automática, ideal para instalaciones desatendidas con Debian 13.

---

## 📦 Contenido del repositorio

- **`make_iso.sh`**: Script en Bash que:
  1. Monta una ISO original de Debian.
  2. Copia su contenido a una carpeta de trabajo.
  3. Inserta tu `preseed.cfg` en la estructura ISO.
  4. Modifica los menús de arranque (GRUB EFI y ISOLINUX) para añadir una entrada automática.
  5. Regenera la ISO con `xorriso`, conservando la capacidad de arranque en UEFI y BIOS.

- **`preseed.cfg`**: Plantilla de configuración de Debian Installer que permite automatizar pasos como particionado, usuarios, redes, paquetes, etc.

---

## 🚀 Uso

1. Clona este repositorio:

   ```bash
   git clone https://github.com/xs3rgii/debian-auto.git
   cd debian-auto

### Importante
A la hora de descargar la iso, debe de tener el nombre de debian-13.iso o modificar la variable de ISO_ORIGINAL en el script para que apunte a la iso
