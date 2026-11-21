#!/usr/bin/env python3
"""Genera el sprite ORIGINAL del Mercader Silencioso (Piso VI).

Figura alta y encapuchada, sin rostro: solo dos brasas doradas en la
sombra de la capucha. El manto llega al suelo y se abre en el último
fotograma, cuando algo agarra la mano de quien la mete debajo.

Salida: assets/visual/enemies/mercader.png
  * Celdas de 64 x 96 px, base del manto en y = 92.
  * Columnas: 0-1 reposo (el manto se mece), 2 el manto se abre.

Uso:  python3 herramientas/generar_mercader.py [--vista-previa RUTA.png]
"""
from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageDraw

RAIZ = Path(__file__).resolve().parent.parent
SALIDA = RAIZ / "assets" / "visual" / "enemies" / "mercader.png"
CW, CH = 64, 96
BASE = 92
CONTORNO = (19, 24, 30, 255)


def c(hexa: str, a: int = 255) -> tuple:
    hexa = hexa.lstrip("#")
    return (int(hexa[0:2], 16), int(hexa[2:4], 16), int(hexa[4:6], 16), a)


MANTO, MANTO_SOMBRA, MANTO_LUZ = c("#2b2232"), c("#1a1420"), c("#3f3349")
BORDE = c("#6a5440")
ORO, ORO_LUZ = c("#c9a25e"), c("#ffe2a0")
VACIO = c("#07060a")
GARRA = c("#c9c2b0")


def fotograma(frame: int) -> Image.Image:
    img = Image.new("RGBA", (CW, CH), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx = 32
    mece = (0, 1, 0)[frame]
    abierto = frame == 2
    top = 14
    # Manto: campana alta que toca el suelo, con pliegues.
    d.polygon([(cx - 10, top + 16), (cx + 10, top + 16), (cx + 19 + mece, BASE), (cx - 19 + mece, BASE)], fill=MANTO)
    d.polygon([(cx + 3, top + 16), (cx + 10, top + 16), (cx + 19 + mece, BASE), (cx + 7 + mece, BASE)], fill=MANTO_SOMBRA)
    for k, x in enumerate((-12, -5, 2)):
        d.line([(cx + x // 3, top + 24), (cx + x + mece, BASE - 1)], fill=MANTO_LUZ if k != 2 else MANTO_SOMBRA)
    # Ribete gastado del bajo.
    d.line([(cx - 19 + mece, BASE), (cx + 19 + mece, BASE)], fill=BORDE, width=2)
    if abierto:
        # El manto se abre: oscuridad y dedos pálidos que salen de dentro.
        d.polygon([(cx - 6, top + 34), (cx + 6, top + 34), (cx + 11, BASE - 1), (cx - 11, BASE - 1)], fill=VACIO)
        for k, (x, y) in enumerate(((-7, 60), (-3, 66), (3, 64), (7, 70), (0, 74))):
            d.line([(cx + x, top + y - 6), (cx + x + (1 if k % 2 else -1), top + y)], fill=GARRA)
            d.point((cx + x + (1 if k % 2 else -1), top + y + 1), fill=c("#8e1f2c"))
    # Brazos cruzados bajo las mangas anchas.
    d.polygon([(cx - 13, top + 22), (cx + 13, top + 22), (cx + 11, top + 32), (cx - 11, top + 32)], fill=MANTO_LUZ)
    d.line([(cx - 11, top + 32), (cx + 11, top + 32)], fill=BORDE)
    # Capucha alta y puntiaguda.
    d.polygon([(cx, top - 10), (cx + 12, top + 10), (cx + 10, top + 20), (cx - 10, top + 20), (cx - 12, top + 10)], fill=MANTO)
    d.polygon([(cx, top - 10), (cx + 12, top + 10), (cx + 10, top + 20), (cx + 2, top + 20)], fill=MANTO_SOMBRA)
    d.ellipse([cx - 7, top + 2, cx + 7, top + 18], fill=VACIO)
    # Dos brasas por ojos, sin rostro.
    for x in (cx - 3, cx + 3):
        d.point((x, top + 9), fill=ORO_LUZ if frame != 1 else ORO)
    # Cuentas de alma colgando del cinto.
    for k in range(3):
        d.ellipse([cx - 6 + k * 5, top + 36, cx - 4 + k * 5, top + 38], fill=c("#8fc7d7"))
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
    parser = argparse.ArgumentParser(description="Genera el sprite del Mercader Silencioso.")
    parser.add_argument("--vista-previa", type=Path, help="Lámina ampliada x4 para revisar.")
    args = parser.parse_args()
    hoja = Image.new("RGBA", (CW * 3, CH), (0, 0, 0, 0))
    for f in range(3):
        hoja.alpha_composite(fotograma(f), (f * CW, 0))
    SALIDA.parent.mkdir(parents=True, exist_ok=True)
    hoja.save(SALIDA, optimize=True)
    print(f"Mercader en {SALIDA.relative_to(RAIZ)}")
    if args.vista_previa:
        fondo = Image.new("RGBA", hoja.size, (60, 64, 58, 255))
        fondo.alpha_composite(hoja)
        fondo.resize((hoja.width * 4, hoja.height * 4), Image.NEAREST).save(args.vista_previa)


if __name__ == "__main__":
    main()
