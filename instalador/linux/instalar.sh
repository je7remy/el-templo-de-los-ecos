#!/usr/bin/env bash
# Instala «El Templo de los Ecos» para el usuario actual (sin sudo):
#   ~/.local/share/el-templo-de-los-ecos/      el juego
#   ~/.local/share/applications/…desktop       acceso en el menú de aplicaciones
# Volver a ejecutarlo actualiza el juego; la partida guardada no se toca.
set -euo pipefail
AQUI="$(cd "$(dirname "$0")" && pwd)"
DESTINO="${XDG_DATA_HOME:-$HOME/.local/share}/el-templo-de-los-ecos"
APPS="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
mkdir -p "$DESTINO" "$APPS"
install -m 755 "$AQUI/ElTemploDeLosEcos.x86_64" "$DESTINO/ElTemploDeLosEcos.x86_64"
install -m 644 "$AQUI/icono.png" "$DESTINO/icono.png"
install -m 644 "$AQUI/LEEME.txt" "$DESTINO/LEEME.txt"
install -m 755 "$AQUI/desinstalar.sh" "$DESTINO/desinstalar.sh"
cat > "$APPS/el-templo-de-los-ecos.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=El Templo de los Ecos
Comment=Roguelike de terror (versión de prueba)
Exec="$DESTINO/ElTemploDeLosEcos.x86_64"
Icon=$DESTINO/icono.png
Terminal=false
Categories=Game;
DESKTOP
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$APPS" >/dev/null 2>&1 || true
echo "Instalado en $DESTINO"
echo "Búscalo en el menú de aplicaciones como «El Templo de los Ecos»."
