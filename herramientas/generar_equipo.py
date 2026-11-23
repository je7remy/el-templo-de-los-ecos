#!/usr/bin/env python3
"""Iconos ORIGINALES (pixel art 32 x 32) de las armas y piezas de equipo.

Salida: assets/visual/iconos/<nombre>.png — mismo estilo que
herramientas/generar_iconos.py (colores planos, luz arriba, contorno de 1 px).
No toca los iconos existentes: solo escribe los de esta lista.

  Armas:  daga, espada, lanza, hacha, maza
  Equipo: yelmo, peto, botas

Uso:  python3 herramientas/generar_equipo.py
"""
from pathlib import Path

from PIL import Image, ImageDraw

RAIZ = Path(__file__).resolve().parent.parent
SALIDA = RAIZ / "assets" / "visual" / "iconos"
T = 32
CONTORNO = (19, 24, 30, 255)


def c(h: str) -> tuple:
    h = h.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), 255)


ACERO, ACERO_OSC, ACERO_LUZ = c("#9aa3ab"), c("#5d656d"), c("#e2e8ec")
HUESO, HUESO_OSC = c("#e3dac0"), c("#a99e80")
MADERA, MADERA_OSC = c("#8a5a35"), c("#5c3a22")
CUERO, CUERO_OSC = c("#7a4f36"), c("#4e3122")
ORO, ORO_OSC = c("#e3bd7b"), c("#a37a3d")
HIERRO, HIERRO_OSC, HIERRO_LUZ = c("#6f6a63"), c("#45413c"), c("#a19b91")
ROJO = c("#b5413a")


def lienzo():
    im = Image.new("RGBA", (T, T), (0, 0, 0, 0))
    return im, ImageDraw.Draw(im)


def contorno(im: Image.Image) -> Image.Image:
    px = im.load()
    out = im.copy()
    op = out.load()
    for y in range(T):
        for x in range(T):
            if px[x, y][3] == 0 and any(0 <= x + dx < T and 0 <= y + dy < T and px[x + dx, y + dy][3] > 0
                                        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                op[x, y] = CONTORNO
    return out


def diagonal(d, x0, y0, x1, y1, col, ancho=1):
    d.line([(x0, y0), (x1, y1)], fill=col, width=ancho)


def daga():
    im, d = lienzo()
    diagonal(d, 9, 23, 21, 11, ACERO, 3)
    diagonal(d, 10, 22, 21, 11, ACERO_LUZ)
    d.polygon([(21, 9), (24, 8), (23, 11)], fill=ACERO)
    diagonal(d, 6, 22, 12, 28, HUESO_OSC, 2)  # guarda de hueso
    diagonal(d, 5, 26, 8, 23, HUESO, 3)
    d.point((4, 27), fill=HUESO_OSC)
    return contorno(im)


def espada():
    im, d = lienzo()
    diagonal(d, 8, 24, 25, 7, ACERO, 4)
    diagonal(d, 9, 23, 25, 7, ACERO_LUZ)
    diagonal(d, 10, 24, 25, 9, ACERO_OSC)
    d.polygon([(25, 5), (28, 4), (27, 8)], fill=ACERO)
    diagonal(d, 5, 21, 11, 27, ORO_OSC, 3)  # guarda
    diagonal(d, 4, 28, 8, 24, CUERO, 3)
    d.point((3, 29), fill=ORO)
    for x, y in ((14, 18), (19, 13)):  # óxido
        d.point((x, y), fill=c("#8a5a3a"))
    return contorno(im)


def lanza():
    im, d = lienzo()
    diagonal(d, 4, 28, 22, 10, MADERA, 2)
    diagonal(d, 5, 28, 22, 11, MADERA_OSC)
    d.polygon([(21, 8), (28, 3), (25, 11), (23, 12)], fill=ACERO)
    d.line([(22, 9), (27, 4)], fill=ACERO_LUZ)
    d.rectangle([19, 12, 21, 14], fill=ROJO)  # cinta
    return contorno(im)


def hacha():
    im, d = lienzo()
    diagonal(d, 7, 28, 20, 9, MADERA, 3)
    diagonal(d, 8, 28, 20, 10, MADERA_OSC)
    d.polygon([(16, 6), (27, 4), (29, 13), (22, 17), (18, 12)], fill=HIERRO)
    d.line([(27, 4), (29, 13)], fill=ACERO_LUZ, width=2)
    d.polygon([(18, 8), (21, 7), (22, 12), (19, 12)], fill=HIERRO_OSC)
    return contorno(im)


def maza():
    im, d = lienzo()
    diagonal(d, 6, 27, 17, 14, MADERA, 3)
    diagonal(d, 7, 27, 17, 15, MADERA_OSC)
    d.ellipse([15, 4, 28, 17], fill=HIERRO)
    d.ellipse([17, 5, 24, 11], fill=HIERRO_LUZ)
    for x, y in ((21, 2), (29, 10), (21, 18), (13, 10), (27, 4), (27, 16)):
        d.point((x, y), fill=HIERRO_OSC)
        d.point((x + (1 if x < 21 else -1), y), fill=HIERRO_OSC)
    return contorno(im)


def yelmo():
    im, d = lienzo()
    d.pieslice([6, 5, 26, 27], 180, 360, fill=HIERRO)
    d.rectangle([6, 15, 26, 24], fill=HIERRO)
    d.rectangle([9, 15, 23, 17], fill=HIERRO_OSC)  # visera
    d.rectangle([15, 17, 17, 24], fill=HIERRO_OSC)
    d.arc([8, 6, 24, 24], 200, 300, fill=HIERRO_LUZ)
    d.polygon([(14, 5), (16, 1), (18, 5)], fill=ROJO)  # cresta
    d.point((22, 10), fill=HIERRO_OSC)  # abolladura
    d.point((23, 11), fill=HIERRO_OSC)
    return contorno(im)


def peto():
    im, d = lienzo()
    d.polygon([(7, 6), (12, 4), (20, 4), (25, 6), (24, 26), (16, 29), (8, 26)], fill=HIERRO)
    d.polygon([(12, 4), (16, 9), (20, 4)], fill=HIERRO_OSC)  # cuello
    d.line([(16, 10), (16, 27)], fill=HIERRO_OSC)
    d.line([(10, 8), (10, 24)], fill=HIERRO_LUZ)
    for y in (14, 19):
        d.line([(9, y), (23, y)], fill=HIERRO_OSC)
    d.rectangle([3, 7, 7, 13], fill=CUERO)  # hombreras
    d.rectangle([25, 7, 29, 13], fill=CUERO)
    return contorno(im)


def botas():
    im, d = lienzo()
    for dx in (0, 13):
        d.rectangle([5 + dx, 8, 11 + dx, 22], fill=CUERO)
        d.rectangle([5 + dx, 22, 15 + dx, 26], fill=CUERO)
        d.line([(6 + dx, 9), (6 + dx, 21)], fill=c("#a06a48"))
        d.rectangle([5 + dx, 8, 11 + dx, 10], fill=CUERO_OSC)
        d.rectangle([5 + dx, 26, 15 + dx, 27], fill=CUERO_OSC)
        d.point((9 + dx, 15), fill=ORO)  # hebilla
    return contorno(im)


ICONOS = {"daga": daga, "espada": espada, "lanza": lanza, "hacha": hacha, "maza": maza,
          "yelmo": yelmo, "peto": peto, "botas": botas}

if __name__ == "__main__":
    SALIDA.mkdir(parents=True, exist_ok=True)
    for nombre, fn in ICONOS.items():
        fn().save(SALIDA / f"{nombre}.png", optimize=True)
        print(f"{nombre}.png")
