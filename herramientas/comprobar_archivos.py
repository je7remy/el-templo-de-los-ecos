#!/usr/bin/env python3
"""Verificar recursos críticos y metadatos de importación antes de ejecutar Godot."""
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent

required = ["project.godot", "scenes/main.tscn", "scenes/defense.tscn",
            "scripts/main.gd", "scripts/defense.gd",
            "tests/smoke_test.gd", "tests/visual_asset_test.gd",
            "assets/visual/protagonist_sheet.png",
            "assets/branding/icon.svg", "assets/branding/logo.svg"]
required += [f"assets/knowledge/rooms/room_{i}.png" for i in range(5)]
required += [f"assets/visual/rooms/room_{i}.png" for i in range(5)]
required += [f"assets/gothic_enemies/angel_{i}.png" for i in range(1, 9)]
required += [f"assets/gothic_enemies/ghoul_{i}.png" for i in range(1, 9)]
required += [f"assets/gothic_enemies/wizard_{i}.png" for i in range(1, 6)]
required += [f"assets/gothic_enemies/fireball_{i}.png" for i in range(1, 4)]

issues = [f"Archivo requerido ausente: {p}" for p in required
          if not (BASE / p).is_file()]
project = (BASE / "project.godot").read_text(encoding="utf-8")
if 'config/features=PackedStringArray("4.3", "GL Compatibility")' not in project:
    issues.append("project.godot debe declarar Godot 4.3 como version de caracteristicas.")
if "textures/canvas_textures/default_texture_filter=0" not in project:
    issues.append("Falta filtrado nearest-neighbor del pixel art.")
if 'run/main_scene="res://scenes/main.tscn"' not in project:
    issues.append("La escena principal del proyecto no coincide con el archivo conocido.")

png_total = 0
uid_total = 0
for folder in (BASE / "assets", BASE / "docs" / "capturas"):
    if not folder.is_dir():
        continue
    for png in folder.rglob("*.png"):
        png_total += 1
        if not Path(str(png) + ".import").is_file():
            issues.append(f"Falta metadato .import: {png.relative_to(BASE)}")
    for imp in folder.rglob("*.png.import"):
        if not Path(str(imp)[:-7]).is_file():
            issues.append(f"Importacion huerfana: {imp.relative_to(BASE)}")

for folder in (BASE / "scripts", BASE / "tests"):
    for uid in folder.rglob("*.gd.uid"):
        uid_total += 1
        if not uid.with_suffix("").is_file():
            issues.append(f"UID huerfano: {uid.relative_to(BASE)}")

if issues:
    print("FALLA: auditoria de archivos")
    for issue in issues:
        print(" -", issue)
    raise SystemExit(1)

print(f"OK: {len(required)} archivos fundamentales verificados.")
print(f"OK: {png_total} PNG con .import y {uid_total} UID existentes sin huerfanos.")
print("OK: Godot 4.3, escena principal y filtro nearest-neighbor verificados.")
