#!/usr/bin/env python3
"""Genera los decorados ORIGINALES de las salas (pixel art, sin colisión).

Detalle de mazmorra al estilo de los roguelike de acción: restos de quienes
no salieron, sangre y objetos rotos. No reducen la oscuridad ni la sangre:
el templo es horror cósmico.

Salida: assets/visual/decorados/<nombre>.png
  suelo:  craneo, huesos, costillar, vasija_rota, velas, charco_grande,
          charco_pequeno, reguero
  muro:   estandarte, cadena, telarana, manos, goteo

main.gd los reparte por cada sala de forma SIMÉTRICA (respetando el eje
x = 480) y determinista (siempre igual en la misma sala).

Uso:  python3 herramientas/generar_decorados.py [--vista-previa RUTA.png]
"""
from __future__ import annotations

import argparse
import math
import random
from pathlib import Path

from PIL import Image, ImageDraw

RAIZ = Path(__file__).resolve().parent.parent
SALIDA = RAIZ / "assets" / "visual" / "decorados"
CONTORNO = (19, 24, 30, 255)


def c(h: str, a: int = 255) -> tuple:
    h = h.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), a)


HUESO, HUESO_SOMBRA, HUESO_LUZ = c("#d6cfbd"), c("#8f8878"), c("#f1ebdb")
VACIO = c("#1b1418")
SANGRE_SECA, SANGRE, SANGRE_VIVA, SANGRE_BRILLO = c("#3a0b0e", 230), c("#5e1117", 235), c("#8a1620"), c("#c23a40")
BARRO, BARRO_LUZ, BARRO_SOMBRA = c("#8a5a3c"), c("#b07a52"), c("#5c3a26")
CERA, CERA_SOMBRA = c("#e6dcc0"), c("#a99d80")
LLAMA, LLAMA_V = c("#f08a3a"), c("#ffd36b")
HIERRO, HIERRO_LUZ = c("#4a4f55"), c("#8d949b")
TELA, TELA_SOMBRA, TELA_LUZ = c("#6b1f2a"), c("#45121b"), c("#8e3340")
ORO = c("#b39257")
SEDA = c("#c9c9c9", 150)


class D:
    def __init__(self, w: int, h: int) -> None:
        self.w, self.h = w, h
        self.img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        self.d = ImageDraw.Draw(self.img)

    def e(self, x0, y0, x1, y1, col):
        self.d.ellipse([x0, y0, x1, y1], fill=col)

    def r(self, x0, y0, x1, y1, col):
        self.d.rectangle([x0, y0, x1, y1], fill=col)

    def p(self, pts, col):
        self.d.polygon([(round(x), round(y)) for x, y in pts], fill=col)

    def ln(self, pts, col, w=1):
        self.d.line([(round(x), round(y)) for x, y in pts], fill=col, width=w)

    def px(self, x, y, col):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.img.putpixel((int(x), int(y)), col)

    def fin(self, borde: bool = True) -> Image.Image:
        if not borde:
            return self.img
        a = self.img.load()
        out = self.img.copy()
        o = out.load()
        for y in range(self.h):
            for x in range(self.w):
                if a[x, y][3]:
                    continue
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    xx, yy = x + dx, y + dy
                    if 0 <= xx < self.w and 0 <= yy < self.h and a[xx, yy][3] > 200:
                        o[x, y] = CONTORNO
                        break
        return out


def mancha(d: D, cx, cy, rx, ry, semilla, capas=((SANGRE_SECA, 1.0), (SANGRE, 0.8), (SANGRE_VIVA, 0.45))):
    rnd = random.Random(semilla)
    for col, k in capas:
        pts = []
        for i in range(16):
            a = i / 16 * math.tau
            f = k * (0.75 + 0.35 * rnd.random())
            pts.append((cx + math.cos(a) * rx * f, cy + math.sin(a) * ry * f))
        d.p(pts, col)


# ------------------------------------------------------------------ SUELO
def craneo() -> Image.Image:
    d = D(18, 14)
    mancha(d, 9, 10, 8, 3, 1, ((SANGRE_SECA, 1.0),))
    d.e(3, 1, 14, 11, HUESO)
    d.r(5, 8, 12, 12, HUESO)
    d.e(4, 2, 9, 6, HUESO_LUZ)
    d.e(5, 5, 8, 8, VACIO)
    d.e(9, 5, 12, 8, VACIO)
    d.px(8, 9, VACIO)
    for x in (6, 8, 10):
        d.px(x, 11, HUESO_SOMBRA)
    d.px(12, 3, SANGRE_VIVA)
    return d.fin()


def huesos() -> Image.Image:
    d = D(24, 12)
    for (x0, y0, x1, y1) in ((2, 9, 21, 3), (4, 2, 20, 10)):
        d.ln([(x0, y0), (x1, y1)], HUESO, 2)
        for x, y in ((x0, y0), (x1, y1)):
            d.e(x - 2, y - 2, x + 1, y + 1, HUESO_LUZ)
    d.ln([(8, 7), (14, 5)], HUESO_SOMBRA)
    return d.fin()


def costillar() -> Image.Image:
    d = D(28, 18)
    mancha(d, 14, 11, 13, 6, 2)
    d.ln([(3, 9), (25, 9)], HUESO, 2)  # columna
    for x in range(6, 24, 4):
        d.ln([(x, 9), (x - 2, 3), (x + 1, 2)], HUESO)
        d.ln([(x, 9), (x - 2, 15), (x + 1, 16)], HUESO_SOMBRA)
    d.px(25, 9, SANGRE_VIVA)
    return d.fin()


def vasija_rota() -> Image.Image:
    d = D(22, 18)
    d.e(2, 4, 15, 16, BARRO)
    d.e(3, 5, 9, 10, BARRO_LUZ)
    d.p([(9, 4), (15, 6), (12, 9), (10, 7)], (0, 0, 0, 0))  # boca rota
    d.e(5, 4, 12, 7, BARRO_SOMBRA)
    for x, y, s in ((16, 12, 3), (18, 7, 2), (13, 15, 2)):
        d.p([(x, y), (x + s, y - 1), (x + s + 1, y + s), (x + 1, y + s)], BARRO)
    return d.fin()


def velas() -> Image.Image:
    d = D(22, 22)
    d.e(1, 15, 21, 21, c("#cfc3a4", 200))  # cera derramada
    for x, h in ((4, 8), (9, 12), (14, 6), (17, 9)):
        d.r(x, 18 - h, x + 2, 18, CERA)
        d.px(x + 2, 18 - h + 1, CERA_SOMBRA)
        d.px(x + 1, 16 - h, LLAMA)
        d.px(x + 1, 15 - h, LLAMA_V)
    return d.fin()


def charco_grande() -> Image.Image:
    d = D(48, 26)
    mancha(d, 24, 13, 22, 11, 7)
    d.e(14, 8, 19, 11, SANGRE_BRILLO)
    rnd = random.Random(8)
    for _ in range(10):
        x, y = rnd.randint(0, 47), rnd.randint(0, 25)
        d.px(x, y, SANGRE)
    return d.fin(borde=False)


def charco_pequeno() -> Image.Image:
    d = D(24, 14)
    mancha(d, 12, 7, 10, 5, 9)
    d.px(8, 5, SANGRE_BRILLO)
    return d.fin(borde=False)


def reguero() -> Image.Image:
    """Rastro de algo arrastrado: tramos de sangre con huellas de dedos."""
    d = D(56, 16)
    for i, x in enumerate(range(2, 50, 6)):
        y = 7 + int(math.sin(i * 0.9) * 2)
        d.r(x, y, x + 4, y + 2, SANGRE if i % 2 else SANGRE_SECA)
    for k in range(4):
        d.ln([(48, 3 + k * 3), (54, 2 + k * 3)], SANGRE_VIVA)
    return d.fin(borde=False)


# ------------------------------------------------------------------- MURO
def estandarte() -> Image.Image:
    """Estandarte rasgado con el ojo del templo bordado."""
    d = D(24, 38)
    d.r(0, 0, 23, 2, HIERRO)
    d.r(0, 0, 23, 0, HIERRO_LUZ)
    d.p([(2, 3), (21, 3), (21, 30), (17, 36), (14, 29), (10, 37), (6, 30), (2, 35)], TELA)
    d.p([(2, 3), (7, 3), (6, 30), (2, 35)], TELA_LUZ)
    d.p([(16, 3), (21, 3), (21, 30), (17, 36)], TELA_SOMBRA)
    d.e(7, 12, 16, 19, ORO)
    d.e(10, 13, 13, 18, VACIO)
    d.px(11, 14, c("#c23a40"))
    d.ln([(4, 23), (19, 23)], ORO)
    d.ln([(13, 20), (12, 33)], SANGRE)  # sangre que lo empapa
    return d.fin()


def cadena() -> Image.Image:
    d = D(10, 34)
    for i, y in enumerate(range(0, 30, 4)):
        if i % 2:
            d.r(4, y, 5, y + 4, HIERRO_LUZ)
        else:
            d.e(2, y, 7, y + 4, HIERRO)
            d.e(3, y + 1, 6, y + 3, (0, 0, 0, 0))
    d.p([(2, 29), (7, 29), (5, 33)], HIERRO_LUZ)  # gancho
    return d.fin()


def telarana() -> Image.Image:
    d = D(26, 26)
    for k in range(5):
        a = k / 4 * math.pi / 2
        d.ln([(0, 0), (math.cos(a) * 25, math.sin(a) * 25)], SEDA)
    for rr in (7, 13, 19, 24):
        pts = [(math.cos(k / 8 * math.pi / 2) * rr, math.sin(k / 8 * math.pi / 2) * rr) for k in range(9)]
        d.ln(pts, SEDA)
    return d.fin(borde=False)


def manos() -> Image.Image:
    """Huellas de manos ensangrentadas, como quien intentó trepar."""
    d = D(30, 22)
    for ox, oy in ((2, 6), (16, 1)):
        d.e(ox + 1, oy + 7, ox + 9, oy + 15, SANGRE_VIVA)
        for k, fx in enumerate((ox, ox + 3, ox + 6, ox + 9)):
            d.r(fx, oy + 1 + (k % 2), fx + 1, oy + 7, SANGRE_VIVA)
        d.ln([(ox + 9, oy + 10), (ox + 12, oy + 8)], SANGRE_VIVA)
        d.ln([(ox + 4, oy + 15), (ox + 4, oy + 20)], SANGRE)
    return d.fin(borde=False)


def goteo() -> Image.Image:
    d = D(16, 30)
    d.e(1, 0, 15, 7, SANGRE)
    for x, h in ((3, 18), (7, 26), (11, 14), (13, 21)):
        d.r(x, 4, x + 1, h, SANGRE)
        d.px(x, h + 1, SANGRE_VIVA)
    return d.fin(borde=False)


DECORADOS = {
    "craneo": craneo, "huesos": huesos, "costillar": costillar, "vasija_rota": vasija_rota,
    "velas": velas, "charco_grande": charco_grande, "charco_pequeno": charco_pequeno, "reguero": reguero,
    "estandarte": estandarte, "cadena": cadena, "telarana": telarana, "manos": manos, "goteo": goteo,
}


def main() -> None:
    parser = argparse.ArgumentParser(description="Genera los decorados de las salas.")
    parser.add_argument("--vista-previa", type=Path)
    args = parser.parse_args()
    SALIDA.mkdir(parents=True, exist_ok=True)
    imgs = {}
    for nombre, fn in DECORADOS.items():
        imgs[nombre] = fn()
        imgs[nombre].save(SALIDA / f"{nombre}.png", optimize=True)
    print(f"{len(imgs)} decorados en {SALIDA.relative_to(RAIZ)}")
    if args.vista_previa:
        ancho = sum(im.width + 6 for im in imgs.values()) + 6
        lam = Image.new("RGBA", (ancho, 46), (40, 58, 50, 255))
        x = 6
        for im in imgs.values():
            lam.alpha_composite(im, (x, 4))
            x += im.width + 6
        lam.resize((lam.width * 4, lam.height * 4), Image.NEAREST).save(args.vista_previa)


if __name__ == "__main__":
    main()
