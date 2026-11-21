#!/usr/bin/env python3
"""Genera los iconos ORIGINALES (pixel art 32 x 32) del inventario, las
habilidades y los botones de la Vigilia.

Salida: assets/visual/iconos/<nombre>.png
Mismo estilo que los sprites: colores planos, luz desde arriba y contorno
oscuro de 1 px. Se dibujan a 2x (64 px) o 1,5x en el juego con filtro NEAREST.

Uso:  python3 herramientas/generar_iconos.py [--vista-previa RUTA.png]
"""
from __future__ import annotations

import argparse
import math
from pathlib import Path

from PIL import Image, ImageDraw

RAIZ = Path(__file__).resolve().parent.parent
SALIDA = RAIZ / "assets" / "visual" / "iconos"
T = 32
CONTORNO = (19, 24, 30, 255)


def c(hexa: str, a: int = 255) -> tuple:
    hexa = hexa.lstrip("#")
    return (int(hexa[0:2], 16), int(hexa[2:4], 16), int(hexa[4:6], 16), a)


MADERA, MADERA_OSC, MADERA_LUZ = c("#8a5a35"), c("#5c3a22"), c("#b98250")
TELA, TELA_OSC = c("#d9cfb0"), c("#a89c7c")
LLAMA_R, LLAMA, LLAMA_V = c("#c2412f"), c("#f08a3a"), c("#ffd36b")
ALMA, ALMA_OSC, ALMA_LUZ = c("#8fc7d7"), c("#4e8ea3"), c("#e8fbff")
PIEDRA, PIEDRA_OSC, PIEDRA_LUZ = c("#7d8577"), c("#4f5749"), c("#b4bba8")
ORO, ORO_OSC = c("#e3bd7b"), c("#a37a3d")
ROJO = c("#d1747b")
CAJA, CAJA_OSC = c("#9c3b35"), c("#6a2420")
LUNA = c("#e8e2c8")
VIOLETA = c("#b17ad6")


class Icono:
    def __init__(self) -> None:
        self.img = Image.new("RGBA", (T, T), (0, 0, 0, 0))
        self.d = ImageDraw.Draw(self.img)

    def r(self, x0, y0, x1, y1, col):
        self.d.rectangle([x0, y0, x1, y1], fill=col)

    def p(self, pts, col):
        self.d.polygon([(round(x), round(y)) for x, y in pts], fill=col)

    def e(self, x0, y0, x1, y1, col):
        self.d.ellipse([x0, y0, x1, y1], fill=col)

    def ln(self, pts, col, w=1):
        self.d.line([(round(x), round(y)) for x, y in pts], fill=col, width=w)

    def px(self, x, y, col):
        if 0 <= x < T and 0 <= y < T:
            self.img.putpixel((int(x), int(y)), col)

    def arco(self, cx, cy, rad, a0, a1, col, w=2):
        self.d.arc([cx - rad, cy - rad, cx + rad, cy + rad], a0, a1, fill=col, width=w)

    def fin(self) -> Image.Image:
        a = self.img.load()
        out = self.img.copy()
        o = out.load()
        for y in range(T):
            for x in range(T):
                if a[x, y][3]:
                    continue
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    xx, yy = x + dx, y + dy
                    if 0 <= xx < T and 0 <= yy < T and a[xx, yy][3]:
                        o[x, y] = CONTORNO
                        break
        return out


def _llama(i: Icono, cx: int, base: int, alto: int = 10) -> None:
    i.p([(cx - 5, base), (cx + 5, base), (cx + 3, base - alto * 0.6), (cx + 1, base - alto), (cx - 2, base - alto * 0.7), (cx - 4, base - alto * 0.4)], LLAMA_R)
    i.p([(cx - 3, base), (cx + 3, base), (cx + 1, base - alto * 0.7), (cx - 1, base - alto * 0.5)], LLAMA)
    i.p([(cx - 1, base), (cx + 2, base), (cx, base - alto * 0.4)], LLAMA_V)


# ------------------------------------------------------------- INVENTARIO
def madera() -> Image.Image:
    i = Icono()
    for k, (y, dx) in enumerate(((19, -2), (12, 2))):
        i.p([(4 + dx, y + 4), (8 + dx, y - 1), (28 + dx, y + 4 - 6), (24 + dx, y + 9 - 6)], MADERA)
        i.p([(4 + dx, y + 4), (8 + dx, y - 1), (27 + dx, y - 3), (26 + dx, y - 1)], MADERA_LUZ)
        i.e(2 + dx, y - 1, 9 + dx, y + 6, MADERA_LUZ)
        i.e(4 + dx, y + 1, 7 + dx, y + 4, MADERA_OSC)
        i.px(5 + dx, y + 2, MADERA)
        i.ln([(13 + dx, y + 3), (20 + dx, y)], MADERA_OSC)
    # Tira de tela para la antorcha.
    i.r(14, 14, 17, 25, TELA)
    i.r(16, 14, 17, 25, TELA_OSC)
    return i.fin()


def fosforos() -> Image.Image:
    i = Icono()
    i.p([(5, 14), (22, 10), (27, 19), (10, 24)], CAJA)
    i.p([(5, 14), (22, 10), (23, 12), (6, 16)], c("#c4554b"))
    i.p([(10, 24), (27, 19), (27, 22), (10, 27)], CAJA_OSC)
    i.p([(11, 18), (20, 16), (22, 19), (13, 21)], c("#e9d9b0"))  # etiqueta
    i.px(16, 18, LLAMA_R)
    i.px(17, 18, LLAMA)
    # Cerillas asomando con la cabeza roja.
    for k, x in enumerate((9, 13, 17)):
        i.ln([(x, 13 - k), (x + 3, 4 - k)], c("#e2c48a"), 2)
        i.r(x + 2, 2 - k, x + 4, 4 - k, LLAMA_R)
    return i.fin()


def _palo(i: Icono) -> None:
    i.p([(13, 29), (16, 29), (19, 13), (16, 13)], MADERA)
    i.ln([(15, 28), (18, 14)], MADERA_LUZ)
    i.r(14, 11, 21, 15, TELA)
    i.r(14, 13, 21, 15, TELA_OSC)


def antorcha() -> Image.Image:
    i = Icono()
    _palo(i)
    i.e(14, 8, 21, 12, c("#3a2f2a"))  # mecha quemada
    return i.fin()


def antorcha_encendida() -> Image.Image:
    i = Icono()
    _palo(i)
    _llama(i, 17, 12, 11)
    return i.fin()


def llama_interior() -> Image.Image:
    i = Icono()
    # Mano abierta con una llama de alma en la palma.
    i.p([(7, 28), (25, 28), (26, 21), (22, 18), (10, 18), (6, 21)], c("#d8b79a"))
    i.p([(7, 28), (25, 28), (25, 25), (7, 25)], c("#ad8a6d"))
    for x in (8, 12, 16, 20, 24):
        i.r(x - 1, 15 if x not in (8, 24) else 18, x + 1, 19, c("#d8b79a"))
    i.p([(10, 18), (22, 18), (20, 7), (16, 2), (12, 8)], ALMA_OSC)
    i.p([(12, 18), (20, 18), (18, 9), (16, 5), (14, 10)], ALMA)
    i.p([(14, 18), (18, 18), (16, 11)], ALMA_LUZ)
    return i.fin()


def alma() -> Image.Image:
    i = Icono()
    i.p([(16, 3), (24, 15), (16, 29), (8, 15)], ALMA_OSC)
    i.p([(16, 3), (16, 29), (8, 15)], ALMA)
    i.p([(16, 6), (16, 14), (11, 15)], ALMA_LUZ)
    return i.fin()


# ------------------------------------------------------------ HABILIDADES
def resonancia() -> Image.Image:
    i = Icono()
    for rad, col in ((14, ALMA_OSC), (10, ALMA), (6, ALMA_LUZ)):
        i.arco(16, 16, rad, 200, 340, col, 2)
        i.arco(16, 16, rad, 20, 160, col, 2)
    i.e(13, 13, 19, 19, ALMA_LUZ)
    return i.fin()


def golpe() -> Image.Image:
    i = Icono()
    # Antorcha inclinada con estela de fuego en arco.
    i.arco(15, 18, 12, 190, 320, LLAMA, 3)
    i.arco(15, 18, 9, 200, 300, LLAMA_V, 2)
    i.ln([(8, 29), (21, 12)], MADERA, 3)
    i.ln([(9, 28), (20, 13)], MADERA_LUZ)
    i.r(19, 9, 24, 13, TELA)
    _llama(i, 23, 10, 9)
    return i.fin()


# ---------------------------------------------------------------- VIGILIA
def descansar() -> Image.Image:
    i = Icono()
    i.e(6, 5, 24, 23, LUNA)
    i.e(11, 3, 29, 21, (0, 0, 0, 0))
    for x, y in ((22, 22), (26, 17), (25, 27)):
        i.r(x, y, x + 3, y, ALMA_LUZ)
        i.ln([(x + 3, y), (x, y + 3)], ALMA_LUZ)
        i.r(x, y + 3, x + 3, y + 3, ALMA_LUZ)
    return i.fin()


def levantar() -> Image.Image:
    i = Icono()
    for k in range(8):
        a = k / 8 * math.tau
        i.ln([(16 + math.cos(a) * 9, 16 + math.sin(a) * 9), (16 + math.cos(a) * 14, 16 + math.sin(a) * 14)], ORO, 2)
    i.e(9, 9, 23, 23, ORO)
    i.e(11, 10, 19, 17, c("#f6dca3"))
    return i.fin()


def lecho() -> Image.Image:
    i = Icono()
    i.r(3, 14, 28, 24, MADERA)
    i.r(3, 14, 28, 16, MADERA_LUZ)
    i.r(3, 8, 6, 28, MADERA_OSC)
    i.r(26, 12, 29, 28, MADERA_OSC)
    i.r(7, 10, 13, 14, TELA)
    i.r(12, 12, 25, 15, c("#4a6a80"))
    i.r(12, 12, 25, 12, c("#6f93a8"))
    return i.fin()


def puerta() -> Image.Image:
    i = Icono()
    i.r(5, 6, 26, 29, PIEDRA)
    i.e(5, 2, 26, 14, PIEDRA)
    i.r(9, 10, 22, 29, MADERA)
    i.e(9, 6, 22, 16, MADERA)
    i.ln([(15, 7), (15, 29)], MADERA_OSC)
    for y in (13, 22):
        i.r(9, y, 22, y + 1, PIEDRA_OSC)
    i.px(19, 19, ORO)
    i.r(5, 2, 26, 3, PIEDRA_LUZ)
    return i.fin()


def centinela() -> Image.Image:
    i = Icono()
    i.p([(10, 29), (22, 29), (20, 12), (12, 12)], PIEDRA)
    i.p([(16, 29), (22, 29), (20, 12), (16, 12)], PIEDRA_OSC)
    i.e(10, 3, 22, 15, PIEDRA)
    i.e(12, 6, 20, 13, c("#17141a"))
    i.e(14, 7, 18, 12, ALMA)
    i.px(15, 8, ALMA_LUZ)
    i.r(8, 27, 24, 29, PIEDRA_OSC)
    return i.fin()


def reparar() -> Image.Image:
    i = Icono()
    i.ln([(7, 27), (19, 14)], MADERA, 3)
    i.p([(14, 8), (22, 3), (28, 9), (23, 13), (20, 11), (17, 13)], PIEDRA)
    i.p([(14, 8), (22, 3), (24, 5), (16, 10)], PIEDRA_LUZ)
    for x, y in ((4, 9), (8, 5), (5, 14)):
        i.px(x, y, ORO)
        i.px(x + 1, y, ORO)
    return i.fin()


def generador() -> Image.Image:
    i = Icono()
    i.r(8, 18, 24, 29, PIEDRA)
    i.r(8, 18, 24, 19, PIEDRA_LUZ)
    i.p([(16, 2), (24, 12), (16, 22), (8, 12)], ALMA_OSC)
    i.p([(16, 2), (16, 22), (8, 12)], ALMA)
    i.px(14, 8, ALMA_LUZ)
    i.px(13, 9, ALMA_LUZ)
    return i.fin()


def potenciar() -> Image.Image:
    i = Icono()
    i.p([(18, 2), (8, 17), (15, 17), (12, 30), (24, 13), (17, 13), (21, 2)], ORO)
    i.p([(18, 2), (8, 17), (11, 17), (19, 4)], c("#f6dca3"))
    return i.fin()


def escudo() -> Image.Image:
    i = Icono()
    i.p([(16, 3), (27, 7), (25, 20), (16, 29), (7, 20), (5, 7)], ALMA_OSC)
    i.p([(16, 6), (24, 9), (22, 19), (16, 25), (10, 19), (8, 9)], ALMA)
    i.p([(16, 6), (16, 25), (10, 19), (8, 9)], ALMA_LUZ)
    return i.fin()


def pausa() -> Image.Image:
    i = Icono()
    i.r(9, 7, 13, 25, LUNA)
    i.r(19, 7, 23, 25, LUNA)
    return i.fin()


def reanudar() -> Image.Image:
    i = Icono()
    i.p([(10, 6), (25, 16), (10, 26)], LUNA)
    return i.fin()


def salir() -> Image.Image:
    i = Icono()
    i.r(5, 5, 17, 27, PIEDRA)
    i.r(8, 8, 17, 27, c("#17141a"))
    i.p([(14, 16), (22, 9), (22, 13), (29, 13), (29, 19), (22, 19), (22, 23)], ORO)
    return i.fin()


# ------------------------------------------------------------ HUD Y PERFIL
def corazon() -> Image.Image:
    i = Icono()
    i.e(4, 6, 17, 19, c("#b5303a"))
    i.e(15, 6, 28, 19, c("#b5303a"))
    i.p([(5, 15), (27, 15), (16, 28)], c("#b5303a"))
    i.p([(16, 17), (27, 15), (16, 28)], c("#7d1d27"))
    i.e(7, 8, 12, 13, c("#e06a6f"))
    return i.fin()


def vigor() -> Image.Image:
    i = Icono()
    # Rayo verde: el aliento para correr y esquivar.
    i.p([(19, 2), (8, 17), (15, 17), (11, 30), (25, 13), (18, 13), (23, 2)], c("#4f9e78"))
    i.p([(19, 2), (8, 17), (11, 17), (20, 4)], c("#9fe0b8"))
    return i.fin()


def miedo() -> Image.Image:
    i = Icono()
    # Ojo violeta inyectado en sangre: el horror cósmico mirándote.
    i.e(3, 8, 29, 24, c("#e9e1d0"))
    i.e(10, 9, 22, 23, c("#6a3d91"))
    i.e(13, 12, 19, 20, c("#16101c"))
    i.px(14, 13, c("#ffffff"))
    for x, y, dx in ((4, 15, 4), (5, 20, 4), (24, 12, 4), (23, 19, 5)):
        i.ln([(x, y), (x + dx, y - 1)], c("#c23a40"))
    i.arco(16, 16, 13, 200, 340, c("#2a2230"), 2)
    return i.fin()


def eco_respiracion() -> Image.Image:
    i = Icono()
    for k, y in enumerate((9, 16, 23)):
        i.ln([(4 + k * 2, y), (20 + k, y), (24 + k, y - 3), (21 + k, y - 6)], c("#8fc7d7") if k != 1 else c("#e8fbff"), 2)
    return i.fin()


def eco_nuca() -> Image.Image:
    i = Icono()
    for k in range(3):
        a = k * math.pi / 3
        i.ln([(16 + math.cos(a) * 12, 16 + math.sin(a) * 12), (16 - math.cos(a) * 12, 16 - math.sin(a) * 12)], c("#bfe6f5"), 2)
    i.e(12, 12, 20, 20, c("#e8fbff"))
    i.e(14, 14, 18, 18, c("#6aaed0"))
    return i.fin()


def eco_reflejos() -> Image.Image:
    """Piso III: un hilo rojo cortado y la silueta que lo esquiva con estela."""
    i = Icono()
    i.ln([(3, 26), (13, 17)], c("#c23a40"), 2)
    i.ln([(19, 12), (29, 4)], c("#c23a40"), 2)
    for k, col in enumerate((c("#2f474e"), c("#5f8a96"), c("#d8f2f7"))):
        x = 6 + k * 8
        i.e(x + 1, 7, x + 5, 11, col)
        i.p([(x, 13), (x + 6, 13), (x + 7, 20), (x + 4, 20), (x + 6, 25), (x + 3, 25), (x + 2, 21), (x - 1, 24), (x - 2, 22), (x + 1, 19)], col)
    i.ln([(5, 28), (27, 28)], c("#e3bd7b"), 1)
    return i.fin()


def eco_piel() -> Image.Image:
    """Piso IV: piel curtida como corteza, con una brasa que no la atraviesa."""
    i = Icono()
    i.p([(16, 3), (27, 8), (25, 22), (16, 29), (7, 22), (5, 8)], c("#6b5238"))
    i.p([(16, 3), (27, 8), (25, 22), (16, 29)], c("#4a3826"))
    for y in (10, 15, 20):
        i.ln([(9, y), (15, y + 2)], c("#8a6c4a"))
        i.ln([(17, y + 2), (23, y)], c("#3a2c1e"))
    i.e(19, 3, 25, 9, c("#ff9a3c"))
    i.e(21, 5, 23, 7, c("#fff0b0"))
    return i.fin()


def habilidades() -> Image.Image:
    """Grimorio abierto con una runa encendida: la pantalla de habilidades."""
    i = Icono()
    i.p([(3, 9), (15, 12), (15, 28), (3, 25)], c("#5e3478"))
    i.p([(29, 9), (17, 12), (17, 28), (29, 25)], c("#7d4b9a"))
    i.p([(5, 10), (15, 13), (15, 26), (5, 23)], c("#e8dfc4"))
    i.p([(27, 10), (17, 13), (17, 26), (27, 23)], c("#d8cdb0"))
    i.ln([(16, 12), (16, 28)], c("#3f2153"), 1)
    for y in (16, 19, 22):
        i.ln([(7, y), (13, y + 1)], c("#a69a7c"))
    i.e(19, 14, 25, 20, c("#8fc7d7"))
    i.ln([(22, 12), (22, 22)], c("#d8f2f7"))
    i.ln([(20, 17), (24, 17)], c("#d8f2f7"))
    i.px(22, 6, c("#c6aa6e"))
    i.ln([(22, 3), (22, 9)], c("#c6aa6e"))
    i.ln([(19, 6), (25, 6)], c("#c6aa6e"))
    return i.fin()


def pinchos() -> Image.Image:
    """Trampa de pinchos (inscripción en la pantalla de habilidades/ayuda)."""
    i = Icono()
    i.r(3, 22, 28, 27, c("#4f5749"))
    i.r(3, 22, 28, 22, c("#76806f"))
    for x in (5, 11, 17, 23):
        i.p([(x, 22), (x + 3, 8), (x + 6, 22)], c("#b4bba8"))
        i.ln([(x + 3, 9), (x + 3, 21)], c("#e4e2d6"))
    i.p([(14, 9), (17, 9), (16, 14)], c("#c23a40"))
    return i.fin()


def calavera() -> Image.Image:
    i = Icono()
    i.e(6, 3, 26, 22, c("#e2dccb"))
    i.r(10, 18, 22, 26, c("#e2dccb"))
    i.e(9, 10, 15, 16, c("#1b1418"))
    i.e(17, 10, 23, 16, c("#1b1418"))
    i.p([(16, 16), (14, 20), (18, 20)], c("#1b1418"))
    for x in (12, 15, 18, 21):
        i.ln([(x, 22), (x, 26)], c("#8a8273"))
    i.px(11, 12, c("#c23a40"))
    return i.fin()


def engranaje() -> Image.Image:
    i = Icono()
    for k in range(8):
        a = k / 8 * math.tau
        cx, cy = 16 + math.cos(a) * 11, 16 + math.sin(a) * 11
        i.p([(cx + math.cos(a + 1.57) * 3, cy + math.sin(a + 1.57) * 3), (cx - math.cos(a + 1.57) * 3, cy - math.sin(a + 1.57) * 3),
             (cx - math.cos(a + 1.57) * 3 + math.cos(a) * 4, cy - math.sin(a + 1.57) * 3 + math.sin(a) * 4),
             (cx + math.cos(a + 1.57) * 3 + math.cos(a) * 4, cy + math.sin(a + 1.57) * 3 + math.sin(a) * 4)], c("#9aa1a8"))
    i.e(5, 5, 27, 27, c("#9aa1a8"))
    i.e(6, 6, 22, 22, c("#c3c9ce"))
    i.e(11, 11, 21, 21, c("#2a2e38"))
    return i.fin()


ICONOS = {
    "madera": madera, "fosforos": fosforos, "antorcha": antorcha,
    "antorcha_encendida": antorcha_encendida, "llama_interior": llama_interior, "alma": alma,
    "resonancia": resonancia, "golpe": golpe,
    "descansar": descansar, "levantar": levantar, "lecho": lecho, "puerta": puerta,
    "centinela": centinela, "reparar": reparar, "generador": generador, "potenciar": potenciar,
    "escudo": escudo, "pausa": pausa, "reanudar": reanudar, "salir": salir,
    "corazon": corazon, "vigor": vigor, "miedo": miedo, "eco_respiracion": eco_respiracion,
    "eco_nuca": eco_nuca, "eco_reflejos": eco_reflejos, "eco_piel": eco_piel, "habilidades": habilidades, "pinchos": pinchos, "calavera": calavera, "engranaje": engranaje,
}


def main() -> None:
    parser = argparse.ArgumentParser(description="Genera los iconos originales.")
    parser.add_argument("--vista-previa", type=Path, help="Lámina ampliada x4 para revisar.")
    args = parser.parse_args()
    SALIDA.mkdir(parents=True, exist_ok=True)
    imgs = {}
    for nombre, fn in ICONOS.items():
        imgs[nombre] = fn()
        imgs[nombre].save(SALIDA / f"{nombre}.png", optimize=True)
    print(f"{len(imgs)} iconos en {SALIDA.relative_to(RAIZ)}")
    if args.vista_previa:
        cols = 10
        lam = Image.new("RGBA", (cols * (T + 4), ((len(imgs) + cols - 1) // cols) * (T + 4)), (38, 58, 48, 255))
        for k, im in enumerate(imgs.values()):
            lam.alpha_composite(im, ((k % cols) * (T + 4) + 2, (k // cols) * (T + 4) + 2))
        lam.resize((lam.width * 4, lam.height * 4), Image.NEAREST).save(args.vista_previa)


if __name__ == "__main__":
    main()
