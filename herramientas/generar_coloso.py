#!/usr/bin/env python3
"""Genera los sprites ORIGINALES del Piso IX: el Ariete de Piedra y el Coloso.

Ariete (assets/visual/enemies/ariete.png): golem bajo de piedra con cabeza de
carnero. Celdas de 48 x 64, pies en y = 61. Filas: 0 abajo, 1 arriba,
2 derecha, 3 izquierda. Columnas: 0-1 reposo, 2-5 embestida, 6 preparar
(polvo y ojos rojos), 7 aturdido (agrietado, con estrellas).

Coloso (assets/visual/enemies/coloso.png): estatua viva que ocupa media sala.
Celdas de 128 x 160, pies en y = 154, siempre de frente. Columnas: 0-1
reposo, 2-3 caminar, 4 alzar el pie, 5 pisotón, 6 aturdido (piedras sueltas).

Uso:  python3 herramientas/generar_coloso.py [--vista-previa RUTA.png]
"""
from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageDraw

RAIZ = Path(__file__).resolve().parent.parent
SALIDA = RAIZ / "assets" / "visual" / "enemies"
CONTORNO = (19, 24, 30, 255)


def c(hexa: str, a: int = 255) -> tuple:
    hexa = hexa.lstrip("#")
    return (int(hexa[0:2], 16), int(hexa[2:4], 16), int(hexa[4:6], 16), a)


PIEDRA, PIEDRA_OSC, PIEDRA_LUZ = c("#7d7a72"), c("#4f4c47"), c("#a8a49a")
MUSGO = c("#4f6a3a")
GRIETA = c("#2a2724")
OJO, OJO_ROJO = c("#e3bd7b"), c("#e0443c")
CUERNO, CUERNO_OSC = c("#c9b8a0"), c("#8a7a64")


def contorno(img: Image.Image) -> Image.Image:
    a = img.load()
    out = img.copy()
    o = out.load()
    w, h = img.size
    for y in range(h):
        for x in range(w):
            if a[x, y][3]:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                xx, yy = x + dx, y + dy
                if 0 <= xx < w and 0 <= yy < h and a[xx, yy][3]:
                    o[x, y] = CONTORNO
                    break
    return out


# ------------------------------------------------------------- ARIETE
def ariete(direccion: int, frame: int) -> Image.Image:
    img = Image.new("RGBA", (48, 64), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    pie = 61
    corre = 2 <= frame <= 5
    paso = [0, 2, 0, -2][(frame - 2) % 4] if corre else 0
    prepara = frame == 6
    aturdido = frame == 7
    baja = 4 if (corre or prepara) else 0  # agacha la cabeza para embestir
    cx = 24
    if direccion in (2, 3):
        s = 1
        cx = 20
        # Cuerpo de lado: bloque bajo y ancho, patas cortas.
        d.rectangle([cx - 14, pie - 28, cx + 12, pie - 8], fill=PIEDRA)
        d.rectangle([cx - 14, pie - 28, cx + 12, pie - 24], fill=PIEDRA_LUZ)
        d.rectangle([cx - 14, pie - 12, cx + 12, pie - 8], fill=PIEDRA_OSC)
        for px, ph in ((cx - 10, paso), (cx + 6, -paso)):
            d.rectangle([px, pie - 8 - max(0, ph), px + 5, pie - max(0, ph)], fill=PIEDRA_OSC)
        hx = cx + s * 14
        hy = pie - 30 + baja
        d.rectangle([min(hx, hx + s * 12), hy, max(hx, hx + s * 12), hy + 14], fill=PIEDRA)
        # Cuerno en espiral.
        d.arc([hx - 7, hy - 6, hx + 7, hy + 8], 180 if s > 0 else 0, 360 if s > 0 else 180, fill=CUERNO, width=3)
        d.point((hx + s * 8, hy + 4), fill=OJO_ROJO if prepara or corre else OJO)
        if prepara:
            for k in range(3):
                d.ellipse([cx - 18 - k * 5, pie - 4 - k * 2, cx - 14 - k * 5, pie - k * 2], fill=c("#8a8170"))
    else:
        # De frente o de espaldas: bloque ancho con dos cuernos.
        d.rectangle([cx - 13, pie - 30, cx + 13, pie - 8], fill=PIEDRA)
        d.rectangle([cx - 13, pie - 30, cx + 13, pie - 26], fill=PIEDRA_LUZ)
        d.rectangle([cx + 4, pie - 30, cx + 13, pie - 8], fill=PIEDRA_OSC)
        for px, ph in ((cx - 11, paso), (cx + 5, -paso)):
            d.rectangle([px, pie - 8 - max(0, ph), px + 6, pie - max(0, ph)], fill=PIEDRA_OSC)
        hy = pie - 40 + baja
        d.rectangle([cx - 8, hy, cx + 8, hy + 14], fill=PIEDRA)
        for s in (-1, 1):
            d.arc([cx + s * 10 - 7, hy - 6, cx + s * 10 + 7, hy + 8], 0, 360, fill=CUERNO, width=3)
        if direccion == 0:
            for s in (-1, 1):
                d.point((cx + s * 4, hy + 6), fill=OJO_ROJO if prepara or corre else OJO)
    d.line([(cx - 9, pie - 24), (cx - 4, pie - 18), (cx - 7, pie - 12)], fill=MUSGO)
    if aturdido:
        d.line([(cx - 2, pie - 30), (cx + 3, pie - 20), (cx - 1, pie - 12)], fill=GRIETA, width=2)
        for k, (sx, sy) in enumerate(((cx - 10, 10), (cx + 2, 6), (cx + 12, 11))):
            d.point((sx, sy), fill=OJO)
            d.point((sx + 1, sy + 1), fill=OJO)
    return contorno(img)


# ------------------------------------------------------------- COLOSO
def coloso(frame: int) -> Image.Image:
    W_, H_ = 128, 160
    img = Image.new("RGBA", (W_, H_), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    pie = 154
    cx = 64
    alza = frame == 4
    pisa = frame == 5
    aturdido = frame == 6
    paso = [0, 0, 4, -4, 0, 0, 0][frame]
    resp = 1 if frame == 1 else 0
    top = 18 + resp
    # Piernas como columnas.
    for s, ph in ((-1, paso), (1, -paso)):
        lift = 18 if (alza and s > 0) else 0
        x0 = cx + s * 22 - 11
        d.rectangle([x0, pie - 52 - lift - max(0, ph), x0 + 22, pie - lift - max(0, ph)], fill=PIEDRA)
        d.rectangle([x0, pie - 52 - lift, x0 + 4, pie - lift], fill=PIEDRA_LUZ)
        d.rectangle([x0 - 3, pie - 8 - lift, x0 + 25, pie - lift], fill=PIEDRA_OSC)
    # Torso de sillares.
    d.rectangle([cx - 38, top + 34, cx + 38, pie - 50], fill=PIEDRA)
    for y in range(top + 40, pie - 50, 12):
        d.line([(cx - 38, y), (cx + 38, y)], fill=PIEDRA_OSC)
    d.rectangle([cx + 14, top + 34, cx + 38, pie - 50], fill=PIEDRA_OSC)
    # Brazos enormes.
    for s in (-1, 1):
        ax = cx + s * 46
        up = 14 if (alza or pisa) else 0
        d.rectangle([ax - 10, top + 36 - up, ax + 10, top + 96 - up], fill=PIEDRA)
        d.rectangle([ax - 13, top + 92 - up, ax + 13, top + 108 - up], fill=PIEDRA_OSC)
    # Cabeza de estatua sin rostro, con una grieta que brilla.
    d.rectangle([cx - 18, top, cx + 18, top + 34], fill=PIEDRA_LUZ)
    d.rectangle([cx + 4, top, cx + 18, top + 34], fill=PIEDRA)
    glow = OJO_ROJO if (alza or pisa) else OJO
    d.line([(cx - 4, top + 6), (cx + 2, top + 16), (cx - 2, top + 28)], fill=glow, width=3)
    # Musgo y grietas.
    for x, y in ((cx - 30, top + 60), (cx + 20, top + 80), (cx - 10, pie - 56)):
        d.rectangle([x, y, x + 8, y + 3], fill=MUSGO)
    if aturdido:
        d.line([(cx - 20, top + 40), (cx, top + 70), (cx - 12, top + 100)], fill=GRIETA, width=3)
        d.line([(cx + 10, top + 4), (cx + 4, top + 20)], fill=GRIETA, width=2)
        for x, y in ((cx - 40, top + 4), (cx + 36, top + 10), (cx - 6, top - 8)):
            d.rectangle([x, y, x + 5, y + 5], fill=PIEDRA_LUZ)
    if pisa:
        for k in range(5):
            d.ellipse([cx + 8 + k * 9, pie - 6 - k % 2 * 3, cx + 16 + k * 9, pie], fill=c("#8a8170"))
    return contorno(img)


def main() -> None:
    parser = argparse.ArgumentParser(description="Genera el Ariete y el Coloso.")
    parser.add_argument("--vista-previa", type=Path, help="Lámina ampliada x3 para revisar.")
    args = parser.parse_args()
    SALIDA.mkdir(parents=True, exist_ok=True)
    hoja_a = Image.new("RGBA", (48 * 8, 64 * 4), (0, 0, 0, 0))
    for fila in range(4):
        for col in range(8):
            # Izquierda = espejo de derecha (la cabeza no se sale de la celda).
            celda = ariete(2, col).transpose(Image.FLIP_LEFT_RIGHT) if fila == 3 else ariete(fila, col)
            hoja_a.alpha_composite(celda, (col * 48, fila * 64))
    hoja_a.save(SALIDA / "ariete.png", optimize=True)
    hoja_c = Image.new("RGBA", (128 * 7, 160), (0, 0, 0, 0))
    for col in range(7):
        hoja_c.alpha_composite(coloso(col), (col * 128, 0))
    hoja_c.save(SALIDA / "coloso.png", optimize=True)
    print("Ariete y Coloso en assets/visual/enemies/")
    if args.vista_previa:
        lam = Image.new("RGBA", (max(hoja_a.width, hoja_c.width), hoja_a.height + hoja_c.height + 8), (60, 64, 58, 255))
        lam.alpha_composite(hoja_a, (0, 0))
        lam.alpha_composite(hoja_c, (0, hoja_a.height + 8))
        lam.resize((lam.width * 2, lam.height * 2), Image.NEAREST).save(args.vista_previa)


if __name__ == "__main__":
    main()
