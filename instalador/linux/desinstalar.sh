#!/usr/bin/env bash
# Quita el juego y su acceso del menú. La partida guardada se conserva en
# ~/.local/share/godot/app_userdata/El Templo de los Ecos (bórrala a mano si quieres).
set -euo pipefail
DATOS="${XDG_DATA_HOME:-$HOME/.local/share}"
rm -f "$DATOS/applications/el-templo-de-los-ecos.desktop"
rm -rf "$DATOS/el-templo-de-los-ecos"
echo "Desinstalado. La partida guardada sigue en $DATOS/godot/app_userdata/El Templo de los Ecos"
