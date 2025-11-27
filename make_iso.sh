#!/bin/bash
set -e

# ----- Variables de Configuracion -----
ISO_ORIGINAL="debian-13.iso"
ISO_NUEVA="debian-13-auto.iso"
MOUNT_DIR="/tmp/debian_iso_mount"
ISOFILES_DIR="isofiles"

# ----- Configuracion de la ISO -----
echo "[1] Limpiando..."
sudo umount "$MOUNT_DIR" 2>/dev/null || true
rm -rf "$MOUNT_DIR" "$ISOFILES_DIR" "$ISO_NUEVA"
mkdir -p "$MOUNT_DIR" "$ISOFILES_DIR"

echo "[2] Montando ISO original..."
sudo mount -o loop "$ISO_ORIGINAL" "$MOUNT_DIR"

echo "[3] Copiando contenido de la ISO original..."
rsync -a --exclude=md5sum.txt "$MOUNT_DIR/" "$ISOFILES_DIR/"

# ----- Entradas GRUB UEFI -----
echo "[4] Añadiendo entrada de preseed remoto al menú UEFI..."
sudo bash -c "cat <<EOF >> $ISOFILES_DIR/boot/grub/grub.cfg

menuentry 'Install with Network Preseed' {
    linux /install.amd/vmlinuz auto=true priority=critical preseed/url=https://preseed.mysrg.es/preseed.cfg interface=auto
    initrd /install.amd/initrd.gz
}
EOF"

# ----- Entradas ISOLINUX BIOS Legacy -----
echo "[5] Añadiendo entrada de preseed remoto al menú clásico (BIOS)..."
sudo bash -c "cat <<EOF >> $ISOFILES_DIR/isolinux/isolinux.cfg

label network-preseed
  MENU LABEL ^Install with Network Preseed
  KERNEL /install.amd/vmlinuz
  APPEND auto=true priority=critical preseed/url=https://preseed.mysrg.es/preseed.cfg interface=auto initrd=/install.amd/initrd.gz
EOF"

# ----- Generar ISO nueva manteniendo estructura original -----
echo "[6] Generando nueva ISO..."
xorriso -as mkisofs \
  -r -V "Debian-Auto" \
  -o "$ISO_NUEVA" \
  -J -joliet-long \
  -cache-inodes \
  -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
  -b isolinux/isolinux.bin \
  -c isolinux/boot.cat \
  -boot-load-size 4 \
  -boot-info-table \
  -no-emul-boot \
  -eltorito-alt-boot \
  -e boot/grub/efi.img \
  -no-emul-boot \
  -isohybrid-gpt-basdat \
  "$ISOFILES_DIR"

# ----- Desmontar -----
echo "[7] Desmontando..."
sudo umount "$MOUNT_DIR" 2>/dev/null || true

# ----- Limpiar carpeta temporal -----
echo "[8] Limpiando carpeta temporal..."
rm -rf "$ISOFILES_DIR" "$MOUNT_DIR"

echo "ISO generada correctamente: $ISO_NUEVA"
