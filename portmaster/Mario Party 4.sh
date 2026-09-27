#!/bin/bash
# PortMaster Launch Script for Mario Party 4 (RK3326 / Mali-G31 / GLES 3.0)

# Pre-kill any stale instances to ensure DRM master is completely free
sudo killall -9 partyboard gptokeyb gptokeyb2 2>/dev/null || true
sudo pkill -9 -f partyboard 2>/dev/null || true

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source "$controlfolder/control.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/roms/ports/marioparty4"
cd "$GAMEDIR" || exit 1

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# =============================================================================
# HARDWARE AUDIO SETUP
# =============================================================================
amixer -c 0 sset 'Playback Path' 'SPK' >/dev/null 2>&1 || true
amixer -c 0 sset 'Playback' 95% >/dev/null 2>&1 || true

# =============================================================================
# AUTO-DETECT MALI GPU DRIVER & CREATE SYMLINKS
# =============================================================================
MALI_DIR="/tmp/mp4_mali"
rm -rf "$MALI_DIR"
mkdir -p "$MALI_DIR"

MALI_BLOB="/usr/lib/aarch64-linux-gnu/libmali-bifrost-g31-rxp0-gbm.so"
for candidate in \
  /usr/lib/aarch64-linux-gnu/libmali-bifrost-g31-rxp0-gbm.so \
  /usr/lib/aarch64-linux-gnu/libmali-bifrost-g31-*.so \
  /usr/lib/aarch64-linux-gnu/libmali.so \
  /usr/lib/libmali.so; do
  if [ -f "$candidate" ]; then
    MALI_BLOB="$candidate"
    break
  fi
done

if [ -n "$MALI_BLOB" ]; then
  echo "[mali-setup] Creating Mali symlinks -> $MALI_BLOB"
  ln -sf "$MALI_BLOB" "$MALI_DIR/libEGL.so.1"
  ln -sf "$MALI_BLOB" "$MALI_DIR/libEGL.so"
  ln -sf "$MALI_BLOB" "$MALI_DIR/libGLESv2.so.2"
  ln -sf "$MALI_BLOB" "$MALI_DIR/libGLESv2.so"
  ln -sf "$MALI_BLOB" "$MALI_DIR/libgbm.so.1"
  ln -sf "$MALI_BLOB" "$MALI_DIR/libgbm.so"
fi

export LD_LIBRARY_PATH="$MALI_DIR:$GAMEDIR/libs.aarch64:$GAMEDIR:$GAMEDIR/libs:$LD_LIBRARY_PATH"
unset LD_PRELOAD

# Driver settings for SDL3-over-SDL2 shim
export SDL_VIDEODRIVER="sdl2"
export SDL3SHIM_SDL2_VIDEODRIVER="kmsdrm"
export SDL_AUDIODRIVER="sdl2"

# =============================================================================
# HARDWARE PERFORMANCE GOVERNORS & MEMORY TUNING
# =============================================================================
# Online all available CPU cores
for cpu in /sys/devices/system/cpu/cpu[0-3]/online; do
  [ -f "$cpu" ] && echo 1 | sudo tee "$cpu" >/dev/null 2>&1 || true
done

# CPU performance governor
if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
  echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null 2>&1 || true
fi

# Mali GPU devfreq governor -> performance (locks Mali-G31 clock from 200MHz to 520MHz)
for gpu_gov in /sys/devices/platform/*.gpu/devfreq/*.gpu/governor /sys/class/devfreq/*gpu*/governor; do
  [ -f "$gpu_gov" ] && echo performance | sudo tee "$gpu_gov" >/dev/null 2>&1 || true
done

# DMC (Dynamic Memory Controller / DRAM) governor -> performance (locks DDR clock to max 666MHz)
for dmc_gov in /sys/devices/platform/dmc/devfreq/dmc/governor /sys/class/devfreq/*dmc*/governor; do
  [ -f "$dmc_gov" ] && echo performance | sudo tee "$dmc_gov" >/dev/null 2>&1 || true
done

# Kernel virtual memory performance tunings & cache drop
echo ark | sudo -S /sbin/sysctl -w vm.overcommit_memory=1 >/dev/null 2>&1 || true
echo ark | sudo -S /sbin/sysctl -w vm.min_free_kbytes=32768 >/dev/null 2>&1 || true
echo ark | sudo -S /sbin/sysctl -w vm.vfs_cache_pressure=200 >/dev/null 2>&1 || true
echo ark | sudo -S /sbin/sysctl -w vm.swappiness=100 >/dev/null 2>&1 || true
echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null 2>&1 || true

# Auto-protect partyboard from OOM killer
(
  for _ in {1..30}; do
    PID=$(pgrep -f partyboard | head -n 1)
    if [ -n "$PID" ]; then
      echo ark | sudo -S sh -c "echo -800 > /proc/$PID/oom_score_adj" 2>/dev/null
      break
    fi
    sleep 0.5
  done
) &

# =============================================================================
# GAMEPAD CONFIGURATION (SUPPORT BOTH KERNEL CRC AND LEGACY GUID)
# =============================================================================
MAP_GO="190000004b4800000011000000010000,GO-Super Gamepad,a:b1,b:b0,back:b12,dpdown:b9,dpleft:b10,dpright:b11,dpup:b8,guide:b16,leftshoulder:b4,leftstick:b14,lefttrigger:b6,leftx:a0,lefty:a1,rightshoulder:b5,rightstick:b15,righttrigger:b7,rightx:a2,righty:a3,start:b13,x:b2,y:b3,platform:Linux,"
MAP_GO_DEB="1900bb3e4b4800000011000000010000,GO-Super Gamepad,a:b1,b:b0,back:b12,dpdown:b9,dpleft:b10,dpright:b11,dpup:b8,guide:b16,leftshoulder:b4,leftstick:b14,lefttrigger:b6,leftx:a0,lefty:a1,rightshoulder:b5,rightstick:b15,righttrigger:b7,rightx:a2,righty:a3,start:b13,x:b2,y:b3,platform:Linux,"

if [ -n "$sdl_controllerconfig" ]; then
  cfg_deb=$(echo "$sdl_controllerconfig" | sed 's/190000004b4800000011000000010000/1900bb3e4b4800000011000000010000/g')
  export SDL_GAMECONTROLLERCONFIG="${sdl_controllerconfig}"$'\n'"${cfg_deb}"$'\n'"${MAP_GO}"$'\n'"${MAP_GO_DEB}"
else
  export SDL_GAMECONTROLLERCONFIG="${MAP_GO}"$'\n'"${MAP_GO_DEB}"
fi

BIN="$GAMEDIR/partyboard"
chmod +x "$BIN"

# =============================================================================
# CONTROLLER HOTKEY DAEMON (SELECT + START EXIT)
# =============================================================================
if [ -f "$GAMEDIR/marioparty4.ini" ]; then
  if [ -n "$GPTOKEYB2" ]; then
    $GPTOKEYB2 "$(basename "$BIN")" -c "$GAMEDIR/marioparty4.ini" &
  elif [ -n "$GPTOKEYB" ]; then
    $GPTOKEYB "$(basename "$BIN")" -c "$GAMEDIR/marioparty4.ini" &
  fi
fi

pm_platform_helper "$BIN"

# Ejecutar el juego nativo
"$BIN"
ret=$?

echo "=== Mario Party 4 finalizó con código $ret ==="
pm_finish
