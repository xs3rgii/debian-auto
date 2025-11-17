#!/bin/bash
set -e

# ----- Configuración -----
ISO_ORIGINAL="debian-13.iso"
ISO_NUEVA="debian-13-auto.iso"
MOUNT_DIR="/tmp/debian_iso_mount"
ISOFILES_DIR="isofiles"
PRESEED_FILE="preseed.cfg"

echo "[1] Limpiando..."
sudo umount "$MOUNT_DIR" 2>/dev/null || true
rm -rf "$MOUNT_DIR" "$ISOFILES_DIR" "$ISO_NUEVA"
mkdir -p "$MOUNT_DIR" "$ISOFILES_DIR"

echo "[2] Montando ISO original..."
sudo mount -o loop "$ISO_ORIGINAL" "$MOUNT_DIR"

echo "[3] Copiando contenido de la ISO original..."
rsync -a --exclude=md5sum.txt "$MOUNT_DIR/" "$ISOFILES_DIR/"

echo "[4] Añadiendo preseed.cfg en /preseed/"
mkdir -p "$ISOFILES_DIR/preseed"
cp "$PRESEED_FILE" "$ISOFILES_DIR/preseed/preseed.cfg"

# ----- Entradas GRUB EFI -----
echo "[5] Añadiendo entrada GRUB EFI automática..."
sudo bash -c "cat <<EOF >> $ISOFILES_DIR/boot/grub/grub.cfg

menuentry 'Install (Automatic Preseed)' {
    linux /install.amd/vmlinuz auto=true priority=critical preseed/file=/cdrom/preseed/preseed.cfg preseed/interactive=false
    initrd /install.amd/initrd.gz
}
EOF"

# ----- Entradas ISOLINUX BIOS Legacy -----
echo "[6] Añadiendo entrada ISOLINUX Legacy..."
sudo bash -c "cat <<EOF >> $ISOFILES_DIR/isolinux/txt.cfg

label auto
  menu label ^Install (Automatic Preseed)
  kernel /install.amd/vmlinuz
  append auto=true priority=critical preseed/file=/cdrom/preseed/preseed.cfg preseed/interactive=false initrd=/install.amd/initrd.gz
EOF"

# ----- Configurar predeterminada y timeout -----
sudo sed -i '/^set default=/d' $ISOFILES_DIR/boot/grub/grub.cfg
sudo bash -c "echo 'set default=\"0\"' >> $ISOFILES_DIR/boot/grub/grub.cfg"
sudo sed -i '/^set timeout=/d' $ISOFILES_DIR/boot/grub/grub.cfg
sudo bash -c "echo 'set timeout=5' >> $ISOFILES_DIR/boot/grub/grub.cfg"

sudo sed -i '/^default /d' $ISOFILES_DIR/isolinux/isolinux.cfg
sudo bash -c "echo 'default auto' >> $ISOFILES_DIR/isolinux/isolinux.cfg"
sudo sed -i '/^timeout /d' $ISOFILES_DIR/isolinux/isolinux.cfg
sudo bash -c "echo 'timeout 50' >> $ISOFILES_DIR/isolinux/isolinux.cfg"

# ----- Generar ISO nueva manteniendo estructura original -----
echo "[7] Generando nueva ISO..."
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
echo "[8] Desmontando..."
sudo umount "$MOUNT_DIR" 2>/dev/null || true

# ----- Limpiar carpeta temporal -----
echo "[9] Limpiando carpeta temporal..."
rm -rf "$ISOFILES_DIR" "$MOUNT_DIR"

echo "ISO generada correctamente: $ISO_NUEVA"
