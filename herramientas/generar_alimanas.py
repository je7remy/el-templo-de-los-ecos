#!/usr/bin/env python3
"""Alimañas del osario y cursor gótico (arte original, pixel art).

  assets/visual/enemies/alimana.png   4 x 2 celdas de 24 x 16 (fila 0: correr
                                      a la derecha; fila 1: morir, 4 fotogramas)
  assets/visual/cursor.png            32 x 32, garra dorada con gema de alma

Idea del primer juego del autor: enemigos menores que patrullan entre dos
puntos, mueren de un dash y reaparecen desde un nido.

Uso:  python3 herramientas/generar_alimanas.py
"""
from pathlib import Path
from PIL import Image, ImageDraw

RAIZ = Path(__file__).resolve().parents[1]
CW, CH = 24, 16


def c(h: str) -> tuple:
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4)) + (255,)


PIEL, PIEL_SOMBRA, PIEL_LUZ = c("#5a4c48"), c("#3a302e"), c("#7d6a62")
HUESO, OJO, SANGRE, CONTORNO = c("#cfc3a8"), c("#ff3b3b"), c("#8e1f2c"), c("#120c0d")


def contorno(im: Image.Image) -> Image.Image:
    px = im.load()
    out = im.copy()
    op = out.load()
    for y in range(im.height):
        for x in range(im.width):
            if px[x, y][3] == 0 and any(
                    0 <= x + dx < im.width and 0 <= y + dy < im.height and px[x + dx, y + dy][3] > 0
                    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                op[x, y] = CONTORNO
    return out


def alimana(frame: int, muerta: int = -1) -> Image.Image:
    im = Image.new("RGBA", (CW, CH), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    if muerta >= 0:
        # Panza arriba, cada vez más aplastada y con sangre.
        y0 = 9 + min(muerta, 2)
        d.ellipse([5, y0 - 3, 17, y0 + 3], fill=PIEL_SOMBRA)
        for x in (7, 10, 13, 15):
            d.line([(x, y0 - 3), (x + (1 if muerta else 0), y0 - 6 + muerta)], fill=PIEL)
        d.ellipse([3 - muerta, 13, 20 + muerta, 15], fill=SANGRE)
        d.line([(17, y0), (22, y0 - 1)], fill=HUESO)
        return contorno(im)
    paso = [0, 1, 0, -1][frame % 4]
    # Cola huesuda.
    d.line([(1, 9 - paso), (4, 8), (6, 9)], fill=HUESO)
    # Cuerpo encorvado con costillas a la vista.
    d.ellipse([4, 5, 16, 12], fill=PIEL)
    d.ellipse([4, 9, 16, 12], fill=PIEL_SOMBRA)
    d.line([(6, 6), (14, 6)], fill=PIEL_LUZ)
    for x in (8, 10, 12):
        d.line([(x, 7), (x, 10)], fill=HUESO)
    # Cabeza alargada, hocico y ojo rojo.
    d.polygon([(15, 6), (20, 8), (22, 10), (15, 11)], fill=PIEL)
    d.point((22, 10), fill=SANGRE)
    d.point((18, 8), fill=OJO)
    d.line([(15, 5), (16, 3)], fill=PIEL_LUZ)  # oreja
    # Patas.
    for x, fase in ((6, paso), (9, -paso), (12, paso), (15, -paso)):
        d.line([(x, 12), (x + fase, 14)], fill=PIEL_SOMBRA)
    return contorno(im)


def hoja() -> Image.Image:
    s = Image.new("RGBA", (CW * 4, CH * 2), (0, 0, 0, 0))
    for f in range(4):
        s.paste(alimana(f), (f * CW, 0))
        s.paste(alimana(0, muerta=f), (f * CW, CH))
    return s


def cursor() -> Image.Image:
    im = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    oro, oro_luz, oro_sombra = c("#b8955a"), c("#e3c88a"), c("#6e5530")
    # Punta en (1, 1): una garra/estilete dorado.
    d.polygon([(1, 1), (14, 9), (9, 11), (12, 18), (9, 19), (6, 12), (2, 15)], fill=oro)
    d.line([(1, 1), (12, 9)], fill=oro_luz)
    d.line([(2, 14), (6, 12), (9, 19)], fill=oro_sombra)
    d.ellipse([10, 12, 17, 19], fill=c("#2a1d22"))
    d.ellipse([11, 13, 16, 18], fill=c("#8fd8e8"))
    d.point((12, 14), fill=c("#ffffff"))
    return contorno(im)


if __name__ == "__main__":
    h = hoja()
    h.save(RAIZ / "assets/visual/enemies/alimana.png", optimize=True)
    cursor().save(RAIZ / "assets/visual/cursor.png", optimize=True)
    print("alimana.png", h.size, "· cursor.png (32, 32)")
