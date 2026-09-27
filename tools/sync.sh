#!/usr/bin/env bash
set -e

echo "1. Copiando libpng16..."
sshpass -p ark scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /home/jbc/build-mp4-arm64/_deps/png-build/libpng16.so.16 ark@192.168.1.70:/roms/ports/marioparty4/

echo "2. Copiando launcher..."
sshpass -p ark scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "/mnt/c/Users/migue/Ports/marioparty4/portmaster/Mario Party 4.sh" ark@192.168.1.70:/roms/ports/launcher.sh
sshpass -p ark ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ark@192.168.1.70 'mv /roms/ports/launcher.sh "/roms/ports/Mario Party 4.sh" && chmod +x "/roms/ports/Mario Party 4.sh" /roms/ports/marioparty4/partyboard'

echo "3. Sincronizando files/ (assets 570 MB)..."
sshpass -p ark rsync -avz --progress -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" /mnt/c/Users/migue/Ports/marioparty4/orig/GMPE01_01/files/ ark@192.168.1.70:/roms/ports/marioparty4/files/

echo "Completado con exito!"
