#!/usr/bin/env bash
set -euo pipefail

TARGET_IP="${1:-192.168.1.70}"
TARGET_USER="${2:-ark}"
TARGET_PASS="${3:-ark}"
TARGET_DIR="/roms/ports/marioparty4"
BUILD_DIR="/home/jbc/build-mp4-arm64"
ASSETS_DIR="/mnt/c/Users/migue/Ports/marioparty4/orig/GMPE01_01/files"

echo "=========================================================="
echo " Despliegue de Mario Party 4 en RK3326 ($TARGET_IP)"
echo "=========================================================="

# 1. Crear estructura en la consola remota
echo "[1/4] Creando directorios remotos..."
sshpass -p "$TARGET_PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$TARGET_USER@$TARGET_IP" \
    "mkdir -p $TARGET_DIR/libs"

# 2. Sincronizar binarios y módulos .so
echo "[2/4] Sincronizando binarios ejecutables y módulos dinámicos..."
sshpass -p "$TARGET_PASS" rsync -avz --progress \
    -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
    --include='partyboard' \
    --include='libdol.so' \
    --include='*.so' \
    --exclude='*' \
    "$BUILD_DIR/" "$TARGET_USER@$TARGET_IP:$TARGET_DIR/"

# Sincronizar libpng compilada
echo "       Copiando libpng16..."
sshpass -p "$TARGET_PASS" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    "$BUILD_DIR/_deps/png-build/libpng16.so.16" "$TARGET_USER@$TARGET_IP:$TARGET_DIR/libs/"

# 3. Sincronizar assets extraídos (570 MB)
echo "[3/4] Sincronizando directorio files/ (assets)..."
sshpass -p "$TARGET_PASS" rsync -avz --progress \
    -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
    "$ASSETS_DIR" "$TARGET_USER@$TARGET_IP:$TARGET_DIR/"

# 4. Actualizar launcher y permisos
echo "[4/4] Actualizando launcher y permisos..."
sshpass -p "$TARGET_PASS" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    "/mnt/c/Users/migue/Ports/marioparty4/portmaster/Mario Party 4.sh" "$TARGET_USER@$TARGET_IP:/roms/ports/launcher.sh"
sshpass -p "$TARGET_PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$TARGET_USER@$TARGET_IP" \
    "mv /roms/ports/launcher.sh '/roms/ports/Mario Party 4.sh' && chmod +x '/roms/ports/Mario Party 4.sh' $TARGET_DIR/partyboard"

echo "=========================================================="
echo " Despliegue completado con éxito."
echo " Para probar ejecución: sshpass -p ark ssh ark@$TARGET_IP 'cd $TARGET_DIR && LD_LIBRARY_PATH=.:libs ./partyboard'"
echo "=========================================================="
