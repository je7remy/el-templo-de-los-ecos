#!/usr/bin/env python3
"""Genera los cuerpos ORIGINALES de los antiguos dueños de las almas.

Cada alma del templo flota sobre el cadáver de quien la perdió: pixel art
cenital, con charco de sangre, salpicaduras y heridas. Arte propio del
proyecto, mismo estilo que los sprites (contorno oscuro de 1 px en el cuerpo;
la sangre no lleva contorno para que se funda con el suelo).

Salida: assets/visual/cuerpos/cuerpo_<n>.png (72 x 44 px). El punto donde
flota el alma es el centro de la imagen.

Uso:  python3 herramientas/generar_cuerpos.py [--vista-previa RUTA.png]
"""
from __future__ import annotations

import argparse
import math
import random
from pathlib import Path

from PIL import Image, ImageDraw

RAIZ = Path(__file__).resolve().parent.parent
SALIDA = RAIZ / "assets" / "visual" / "cuerpos"
W, H = 72, 44
CONTORNO = (19, 24, 30, 255)


def c(hexa: str, a: int = 255) -> tuple:
    hexa = hexa.lstrip("#")
    return (int(hexa[0:2], 16), int(hexa[2:4], 16), int(hexa[4:6], 16), a)


PIEL, PIEL_SOMBRA, PIEL_LUZ = c("#b8b0a2"), c("#857d71"), c("#d3ccbd")  # piel sin vida
PELO = c("#2b2522")
SANGRE_SECA = c("#3a0b0e", 235)
SANGRE = c("#5e1117", 240)
SANGRE_VIVA = c("#8a1620")
SANGRE_BRILLO = c("#c23a40")
HUESO = c("#e2dccb")


class Capa:
    def __init__(self) -> None:
        self.img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        self.d = ImageDraw.Draw(self.img)

    def e(self, x0, y0, x1, y1, col):
        self.d.ellipse([x0, y0, x1, y1], fill=col)

    def p(self, pts, col):
        self.d.polygon([(round(x), round(y)) for x, y in pts], fill=col)

    def r(self, x0, y0, x1, y1, col):
        self.d.rectangle([x0, y0, x1, y1], fill=col)

    def ln(self, pts, col, w=1):
        self.d.line([(round(x), round(y)) for x, y in pts], fill=col, width=w)

    def px(self, x, y, col):
        if 0 <= x < W and 0 <= y < H:
            self.img.putpixel((int(x), int(y)), col)


def contorno(img: Image.Image) -> Image.Image:
    a = img.load()
    out = img.copy()
    o = out.load()
    for y in range(H):
        for x in range(W):
            if a[x, y][3]:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                xx, yy = x + dx, y + dy
                if 0 <= xx < W and 0 <= yy < H and a[xx, yy][3] > 200:
                    o[x, y] = CONTORNO
                    break
    return out


def charco(capa: Capa, cx: float, cy: float, rx: float, ry: float, semilla: int) -> None:
    """Charco irregular: borde seco, cuerpo oscuro, centro aún húmedo."""
    rnd = random.Random(semilla)
    for col, k in ((SANGRE_SECA, 1.0), (SANGRE, 0.82), (SANGRE_VIVA, 0.5)):
        pts = []
        for i in range(18):
            a = i / 18 * math.tau
            f = k * (0.78 + 0.32 * rnd.random())
            pts.append((cx + math.cos(a) * rx * f, cy + math.sin(a) * ry * f))
        capa.p(pts, col)
    capa.e(cx - rx * 0.25, cy - ry * 0.3, cx - rx * 0.05, cy - ry * 0.15, SANGRE_BRILLO)  # reflejo húmedo


def salpicar(capa: Capa, cx: float, cy: float, n: int, radio: float, semilla: int) -> None:
    rnd = random.Random(semilla)
    for _ in range(n):
        a = rnd.random() * math.tau
        d = radio * (0.6 + rnd.random() * 0.7)
        x, y = cx + math.cos(a) * d, cy + math.sin(a) * d * 0.6
        s = rnd.choice((0, 0, 1, 1, 2))
        col = rnd.choice((SANGRE, SANGRE_VIVA, SANGRE_SECA))
        if s == 0:
            capa.px(x, y, col)
        elif s == 1:
            capa.r(x, y, x + 1, y, col)
            capa.px(x, y + 1, col)
        else:
            capa.e(x - s, y - s * 0.7, x + s, y + s * 0.7, col)


# ------------------------------------------------------------ VARIANTES
def boca_abajo() -> Image.Image:
    """Peregrino caído boca abajo, brazos abiertos, herida en la espalda."""
    sangre = Capa()
    charco(sangre, 38, 25, 26, 13, 1)
    salpicar(sangre, 38, 22, 16, 30, 2)
    # Rastro de arrastre hacia la izquierda.
    for i, x in enumerate(range(2, 16, 3)):
        sangre.r(x, 25 + (i % 2), x + 2, 26 + (i % 2), SANGRE_SECA)
    cuerpo = Capa()
    ropa, ropa_os = c("#4a5b52"), c("#33413a")
    # Piernas.
    cuerpo.r(46, 21, 60, 24, c("#2d2a2f"))
    cuerpo.r(46, 26, 59, 29, c("#262329"))
    cuerpo.r(60, 20, 63, 24, c("#1c1a1d"))
    cuerpo.r(59, 26, 62, 30, c("#1c1a1d"))
    # Torso con capa rasgada.
    cuerpo.e(24, 16, 49, 33, ropa)
    cuerpo.p([(28, 30), (48, 31), (46, 34), (40, 32), (34, 35), (30, 32)], ropa_os)
    cuerpo.e(26, 17, 47, 22, c("#5e7166"))  # hombros iluminados desde arriba
    # Brazos abiertos.
    cuerpo.p([(28, 18), (31, 17), (24, 6), (21, 7)], ropa)
    cuerpo.e(19, 3, 24, 8, PIEL)
    cuerpo.p([(28, 31), (31, 32), (20, 39), (18, 37)], ropa_os)
    cuerpo.e(15, 36, 20, 41, PIEL_SOMBRA)
    # Cabeza de lado, pelo.
    cuerpo.e(14, 19, 26, 30, PELO)
    cuerpo.e(15, 20, 21, 24, c("#433933"))
    cuerpo.e(13, 25, 18, 30, PIEL_SOMBRA)  # oreja/mejilla
    img = contorno(cuerpo.img)
    # Heridas sobre el cuerpo: tajo en la espalda y sangre que empapa la ropa.
    h = Capa()
    h.img = img
    h.d = ImageDraw.Draw(img)
    h.ln([(33, 21), (40, 27)], SANGRE_VIVA, 2)
    h.ln([(34, 21), (40, 26)], SANGRE_BRILLO)
    h.e(35, 24, 44, 31, SANGRE)
    h.px(36, 25, SANGRE_BRILLO)
    h.e(16, 27, 20, 30, SANGRE)
    return Image.alpha_composite(sangre.img, img)


def boca_arriba() -> Image.Image:
    """Archivista boca arriba; la garganta abierta y un gran charco bajo la cabeza."""
    sangre = Capa()
    charco(sangre, 20, 22, 18, 13, 3)
    charco(sangre, 36, 25, 10, 6, 4)
    salpicar(sangre, 20, 20, 22, 22, 5)
    # Huella de mano ensangrentada junto al cuerpo.
    for dx in (0, 2, 4, 6):
        sangre.r(52 + dx, 8, 52 + dx, 10, SANGRE)
    sangre.e(51, 10, 58, 14, SANGRE)
    cuerpo = Capa()
    tunica, tunica_os = c("#5a4a6a"), c("#3d3149")
    cuerpo.r(46, 19, 64, 23, c("#2f2a33"))
    cuerpo.r(46, 25, 62, 28, c("#29252c"))
    cuerpo.e(62, 18, 67, 23, c("#4a3b2c"))
    cuerpo.e(60, 25, 65, 29, c("#4a3b2c"))
    cuerpo.e(25, 15, 50, 32, tunica)
    cuerpo.e(27, 16, 48, 22, c("#6e5c80"))
    cuerpo.p([(30, 29), (48, 28), (47, 32), (31, 32)], tunica_os)
    # Brazo doblado sobre el pecho y otro extendido.
    cuerpo.p([(34, 18), (37, 17), (43, 22), (40, 24)], tunica_os)
    cuerpo.e(40, 21, 45, 26, PIEL)
    cuerpo.p([(30, 30), (33, 31), (40, 39), (37, 40)], tunica)
    cuerpo.e(38, 37, 43, 42, PIEL_SOMBRA)
    # Cabeza mirando arriba.
    cuerpo.e(12, 16, 26, 29, PIEL)
    cuerpo.e(12, 16, 19, 29, PELO)
    cuerpo.e(19, 18, 24, 22, PIEL_LUZ)
    img = contorno(cuerpo.img)
    h = ImageDraw.Draw(img)
    # Ojos hundidos y boca abierta.
    for y in (19, 25):
        h.rectangle([21, y, 22, y], fill=c("#2a2224"))
    h.rectangle([24, 21, 24, 23], fill=c("#3a2326"))
    # Garganta abierta.
    h.line([(25, 20), (27, 26)], fill=SANGRE_VIVA, width=2)
    h.point((26, 22), fill=SANGRE_BRILLO)
    h.ellipse([30, 22, 37, 28], fill=SANGRE)
    h.point((31, 23), fill=SANGRE_BRILLO)
    return Image.alpha_composite(sangre.img, img)


def encogido() -> Image.Image:
    """Cuerpo encogido de costado, túnica rota, costillas a la vista."""
    sangre = Capa()
    charco(sangre, 36, 26, 24, 12, 6)
    salpicar(sangre, 36, 24, 18, 28, 7)
    # Arañazos de uñas en la piedra (intentó arrastrarse).
    for k in range(3):
        sangre.ln([(8 + k * 3, 14), (14 + k * 3, 21)], SANGRE_SECA)
    cuerpo = Capa()
    ropa, ropa_os = c("#6b5a43"), c("#4a3d2d")
    # Piernas recogidas.
    cuerpo.p([(44, 24), (55, 18), (60, 22), (50, 30)], c("#2e2b2a"))
    cuerpo.e(56, 17, 62, 23, c("#3f3328"))
    cuerpo.p([(42, 28), (52, 30), (52, 34), (41, 33)], c("#262422"))
    # Torso curvado.
    cuerpo.e(22, 14, 47, 34, ropa)
    cuerpo.e(24, 15, 44, 21, c("#82704f"))
    cuerpo.p([(26, 31), (44, 30), (42, 35), (30, 35)], ropa_os)
    # Brazos hacia la cabeza.
    cuerpo.p([(26, 16), (29, 15), (18, 11), (17, 14)], ropa)
    cuerpo.e(13, 9, 19, 15, PIEL)
    # Cabeza escondida entre los brazos.
    cuerpo.e(12, 16, 25, 28, PELO)
    cuerpo.e(13, 22, 19, 28, PIEL_SOMBRA)
    img = contorno(cuerpo.img)
    h = ImageDraw.Draw(img)
    # Túnica desgarrada: costillas a la vista entre la sangre.
    h.ellipse([29, 20, 42, 31], fill=SANGRE)
    for k in range(4):
        y = 22 + k * 2
        h.line([(31, y), (39, y + 1)], fill=HUESO)
    h.ellipse([33, 25, 37, 28], fill=SANGRE_VIVA)
    h.point((34, 25), fill=SANGRE_BRILLO)
    h.line([(20, 13), (24, 17)], fill=SANGRE_VIVA)
    return Image.alpha_composite(sangre.img, img)


CUERPOS = [boca_abajo, boca_arriba, encogido]


def main() -> None:
    parser = argparse.ArgumentParser(description="Genera los cuerpos bajo las almas.")
    parser.add_argument("--vista-previa", type=Path, help="Lámina ampliada x4 para revisar.")
    args = parser.parse_args()
    SALIDA.mkdir(parents=True, exist_ok=True)
    imgs = []
    for i, fn in enumerate(CUERPOS, 1):
        im = fn()
        im.save(SALIDA / f"cuerpo_{i}.png", optimize=True)
        imgs.append(im)
    print(f"{len(imgs)} cuerpos en {SALIDA.relative_to(RAIZ)}")
    if args.vista_previa:
        lam = Image.new("RGBA", (len(imgs) * (W + 8), H + 8), (33, 52, 45, 255))
        for k, im in enumerate(imgs):
            lam.alpha_composite(im, (k * (W + 8) + 4, 4))
        lam.resize((lam.width * 5, lam.height * 5), Image.NEAREST).save(args.vista_previa)


if __name__ == "__main__":
    main()
