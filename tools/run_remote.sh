#!/bin/bash
set -x

GAMEDIR="/roms/ports/marioparty4"
cd "$GAMEDIR"

MALI_DIR="/tmp/mp4_mali"
rm -rf "$MALI_DIR"
mkdir -p "$MALI_DIR"

MALI_BLOB="/usr/lib/aarch64-linux-gnu/libmali-bifrost-g31-rxp0-gbm.so"

echo "[mali-setup] Creating clean Mali symlinks -> $MALI_BLOB"
ln -sf "$MALI_BLOB" "$MALI_DIR/libEGL.so.1"
ln -sf "$MALI_BLOB" "$MALI_DIR/libEGL.so"
ln -sf "$MALI_BLOB" "$MALI_DIR/libGLESv2.so.2"
ln -sf "$MALI_BLOB" "$MALI_DIR/libGLESv2.so"
ln -sf "$MALI_BLOB" "$MALI_DIR/libgbm.so.1"
ln -sf "$MALI_BLOB" "$MALI_DIR/libgbm.so"

export LD_LIBRARY_PATH="$MALI_DIR:$GAMEDIR/libs.aarch64:$GAMEDIR:$GAMEDIR/libs:$LD_LIBRARY_PATH"
unset LD_PRELOAD

export SDL_VIDEODRIVER="sdl2"
export SDL3SHIM_SDL2_VIDEODRIVER="kmsdrm"
export SDL_AUDIODRIVER="sdl2"
export SDL_LOG_LEVEL="verbose"

echo "=== EJECUTANDO PARTYBOARD (MELEE SHIM ENVIRONMENT) ==="
./partyboard
RC=$?
echo "=== PARTYBOARD FINALIZO CON CODIGO: $RC ==="
