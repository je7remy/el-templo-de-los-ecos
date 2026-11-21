#!/usr/bin/env python3
"""Genera el sprite ORIGINAL de La Que No Aparta la Vista (Piso VII).

Figura alta y delgada con túnica de luto, la cabeza encerrada en un yelmo
liso sin visera; de las rendijas del yelmo caen dos regueros de sangre. En
el pecho, abierta en la tela, una hilera de ojos que siempre te miran.

Salida: assets/visual/enemies/vigia.png
  * Celdas de 64 x 96 px, base de la túnica en y = 92.
  * Columnas: 0-1 flota y mira, 2 provocada (ojos rojos, brazos alzados),
    3 golpe (se lanza hacia delante).

Uso:  python3 herramientas/generar_vigia.py [--vista-previa RUTA.png]
"""
from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageDraw

RAIZ = Path(__file__).resolve().parent.parent
SALIDA = RAIZ / "assets" / "visual" / "enemies" / "vigia.png"
CW, CH = 64, 96
BASE = 92
CONTORNO = (19, 24, 30, 255)


def c(hexa: str, a: int = 255) -> tuple:
    hexa = hexa.lstrip("#")
    return (int(hexa[0:2], 16), int(hexa[2:4], 16), int(hexa[4:6], 16), a)


TUNICA, TUNICA_SOMBRA, TUNICA_LUZ = c("#2a2a30"), c("#18181d"), c("#3d3d46")
YELMO, YELMO_SOMBRA, YELMO_LUZ = c("#8d8f94"), c("#5d6066"), c("#c4c7cc")
SANGRE = c("#8e1f2c")
PIEL = c("#c9b8a6")
OJO, PUPILA, OJO_ROJO = c("#e9e4d6"), c("#1a1418"), c("#d23a3a")
MANO = c("#b8a894")


def fotograma(frame: int) -> Image.Image:
    img = Image.new("RGBA", (CW, CH), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx = 32
    flota = (0, -1, -2, 0)[frame]
    furia = frame >= 2
    golpe = frame == 3
    top = 12 + flota
    lean = 3 if golpe else 0
    # Túnica larga y estrecha, deshilachada abajo (flota: no toca el suelo).
    d.polygon([(cx - 8 + lean, top + 22), (cx + 8 + lean, top + 22), (cx + 13, BASE - 4), (cx - 13, BASE - 4)], fill=TUNICA)
    d.polygon([(cx + 2 + lean, top + 22), (cx + 8 + lean, top + 22), (cx + 13, BASE - 4), (cx + 5, BASE - 4)], fill=TUNICA_SOMBRA)
    for x in range(cx - 12, cx + 13, 4):
        d.line([(x, BASE - 4), (x + 1, BASE - 1)], fill=TUNICA_SOMBRA)
    # Pecho abierto con la hilera de ojos.
    d.ellipse([cx - 7 + lean, top + 27, cx + 7 + lean, top + 45], fill=PIEL)
    for k, (x, y) in enumerate(((-3, 31), (3, 31), (0, 37), (-3, 42), (3, 42))):
        ex, ey = cx + x + lean, top + y
        d.ellipse([ex - 2, ey - 1, ex + 2, ey + 2], fill=OJO_ROJO if furia else OJO)
        d.point((ex, ey), fill=PUPILA)
    # Brazos: caídos y largos; alzados cuando la provocas.
    for lado in (-1, 1):
        hx = cx + lado * 9 + lean
        if furia:
            d.line([(hx, top + 24), (hx + lado * 6, top + 10 - (4 if golpe else 0))], fill=TUNICA_LUZ, width=3)
            for f in range(3):
                d.line([(hx + lado * 6, top + 10 - (4 if golpe else 0)), (hx + lado * (6 + f), top + 4 - (4 if golpe else 0))], fill=MANO)
        else:
            d.line([(hx, top + 24), (hx + lado * 3, top + 56)], fill=TUNICA_LUZ, width=3)
            for f in range(3):
                d.line([(hx + lado * 3, top + 56), (hx + lado * (2 + f), top + 62)], fill=MANO)
    # Cuello y yelmo cerrado.
    d.rectangle([cx - 3 + lean, top + 16, cx + 3 + lean, top + 22], fill=PIEL)
    d.rounded_rectangle([cx - 8 + lean, top - 4, cx + 8 + lean, top + 18], radius=6, fill=YELMO)
    d.rectangle([cx + 2 + lean, top - 2, cx + 8 + lean, top + 17], fill=YELMO_SOMBRA)
    d.line([(cx - 6 + lean, top - 1), (cx - 6 + lean, top + 12)], fill=YELMO_LUZ)
    # Rendijas y sangre.
    for x in (cx - 4, cx + 3):
        d.line([(x + lean - 1, top + 6), (x + lean + 1, top + 6)], fill=CONTORNO)
        d.line([(x + lean, top + 7), (x + lean, top + 15 + (3 if furia else 0))], fill=SANGRE)
    d.line([(cx + lean, top - 4), (cx + lean, top + 17)], fill=YELMO_SOMBRA)  # cresta
    # Contorno de 1 px.
    a = img.load()
    out = img.copy()
    o = out.load()
    for y in range(CH):
        for x in range(CW):
            if a[x, y][3]:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                xx, yy = x + dx, y + dy
                if 0 <= xx < CW and 0 <= yy < CH and a[xx, yy][3]:
                    o[x, y] = CONTORNO
                    break
    return out


def main() -> None:
    parser = argparse.ArgumentParser(description="Genera el sprite de La Que No Aparta la Vista.")
    parser.add_argument("--vista-previa", type=Path, help="Lámina ampliada x4 para revisar.")
    args = parser.parse_args()
    hoja = Image.new("RGBA", (CW * 4, CH), (0, 0, 0, 0))
    for f in range(4):
        hoja.alpha_composite(fotograma(f), (f * CW, 0))
    SALIDA.parent.mkdir(parents=True, exist_ok=True)
    hoja.save(SALIDA, optimize=True)
    print(f"Vigía en {SALIDA.relative_to(RAIZ)}")
    if args.vista_previa:
        fondo = Image.new("RGBA", hoja.size, (60, 64, 58, 255))
        fondo.alpha_composite(hoja)
        fondo.resize((hoja.width * 4, hoja.height * 4), Image.NEAREST).save(args.vista_previa)


if __name__ == "__main__":
    main()
