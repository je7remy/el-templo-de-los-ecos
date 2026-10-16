#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$(realpath "$0")")/.."
if command -v godot >/dev/null 2>&1; then
  exec godot --editor --path .
elif command -v godot4 >/dev/null 2>&1; then
  exec godot4 --editor --path .
elif command -v flatpak >/dev/null 2>&1 && flatpak info org.godotengine.Godot >/dev/null 2>&1; then
  exec flatpak run org.godotengine.Godot --editor --path .
else
  printf 'No encontré Godot 4. Instálalo y abre project.godot en el gestor de proyectos.\n' >&2
  exit 1
fi
