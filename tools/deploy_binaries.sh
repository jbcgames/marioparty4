#!/usr/bin/env bash
set -euo pipefail

TARGET_IP="${1:-192.168.1.70}"
TARGET_USER="${2:-ark}"
TARGET_PASS="${3:-ark}"
TARGET_DIR="/roms/ports/marioparty4"
BUILD_DIR="/home/jbc/build-mp4-arm64"
LOCAL_DIR="/mnt/c/Users/migue/Ports/marioparty4"

echo "=========================================================="
echo " Despliegue de binarios optimizados en RK3326 ($TARGET_IP)"
echo "=========================================================="

echo "[1/3] Asegurando stripping de simbolos en binarios..."
aarch64-linux-gnu-strip --strip-unneeded "$BUILD_DIR/partyboard" "$BUILD_DIR/libdol.so" "$BUILD_DIR"/*.so

echo "[2/3] Sincronizando binarios y librerias DLLs..."
sshpass -p "$TARGET_PASS" rsync -avz --progress \
    -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
    --include='partyboard' \
    --include='libdol.so' \
    --include='*.so' \
    --exclude='*' \
    "$BUILD_DIR/" "$TARGET_USER@$TARGET_IP:$TARGET_DIR/"

echo "[3/3] Actualizando script lanzador y permisos..."
sshpass -p "$TARGET_PASS" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    "$LOCAL_DIR/portmaster/Mario Party 4.sh" "$TARGET_USER@$TARGET_IP:/roms/ports/launcher.sh"
sshpass -p "$TARGET_PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$TARGET_USER@$TARGET_IP" \
    "mv /roms/ports/launcher.sh '/roms/ports/Mario Party 4.sh' && chmod +x '/roms/ports/Mario Party 4.sh' $TARGET_DIR/partyboard"

echo "=========================================================="
echo " Binarios y lanzador desplegados con exito."
echo "=========================================================="
