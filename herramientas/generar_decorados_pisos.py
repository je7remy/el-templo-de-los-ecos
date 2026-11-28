#!/usr/bin/env python3
"""Genera el decorado PROPIO de cada piso (pixel art original, sin colisión).

Cada piso cuenta su historia con lo que hay tirado por el suelo y colgado del
muro del fondo: los peregrinos dejan bastones y cuencos, la cacería deja
flechas y cepos, el claustro tiene raíces y hongos, etc. Se suman a los restos
comunes de herramientas/generar_decorados.py (mismos colores y contorno).

Salida: assets/visual/decorados/pisos/<nombre>.png
scripts/mundo/decorado.gd (TEMAS) dice qué va en cada piso.

Uso:  python3 herramientas/generar_decorados_pisos.py [--vista-previa RUTA.png]
"""
from __future__ import annotations

import argparse
import math
import random
import sys
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_decorados import (  # noqa: E402
    D, RAIZ, c, mancha, HUESO, HUESO_SOMBRA, HUESO_LUZ, VACIO, SANGRE_SECA, SANGRE, SANGRE_VIVA,
    BARRO, BARRO_LUZ, BARRO_SOMBRA, CERA, LLAMA, LLAMA_V, HIERRO, HIERRO_LUZ, TELA, TELA_SOMBRA,
    TELA_LUZ, ORO,
)

SALIDA = RAIZ / "assets" / "visual" / "decorados" / "pisos"

MADERA, MADERA_LUZ, MADERA_SOMBRA = c("#7a4f2c"), c("#a0703f"), c("#4e311b")
LANA, LANA_LUZ, LANA_SOMBRA = c("#5a4636"), c("#7a6249"), c("#3a2c22")
RAIZ_C, RAIZ_LUZ, RAIZ_SOMBRA = c("#5b3d2a"), c("#7d5a3d"), c("#3a261a")
HOJA, HOJA_SECA = c("#5c5a2e"), c("#8a6a34")
HONGO, HONGO_LUZ, HONGO_PIE = c("#8e7fb0"), c("#c4b8e6"), c("#d8cfb8")
BIOLUZ = c("#7fe3ff")
PIEDRA, PIEDRA_LUZ, PIEDRA_SOMBRA = c("#6a6e66"), c("#8e938a"), c("#45483f")
TIZA = c("#d9d6c8", 200)
TRIGO, TRIGO_LUZ, TRIGO_SOMBRA = c("#b8913f"), c("#dcb865"), c("#7f6228")
FLOR, FLOR_SECA = c("#8a2c3a"), c("#6a4a5a")
CRISTAL, CRISTAL_LUZ = c("#9cc4d6", 200), c("#e6f6ff", 230)
PLUMA = c("#2b2a30")


# ============================================================ II · PEREGRINOS
def baculo() -> Image.Image:
    """Bastón de peregrino caído, con su calabaza de agua."""
    d = D(40, 14)
    d.ln([(2, 11), (37, 3)], MADERA, 2)
    d.ln([(3, 10), (36, 2)], MADERA_LUZ)
    d.e(33, 0, 38, 5, MADERA_SOMBRA)  # nudo
    d.ln([(22, 6), (22, 9)], LANA_SOMBRA)
    d.e(18, 8, 26, 13, BARRO)
    d.e(19, 8, 22, 10, BARRO_LUZ)
    return d.fin()


def manto() -> Image.Image:
    """Manto de lana abandonado, todavía con la forma de quien lo llevaba."""
    d = D(34, 20)
    d.p([(2, 16), (6, 4), (15, 1), (26, 3), (32, 15), (24, 19), (12, 19)], LANA)
    d.p([(6, 4), (15, 1), (16, 9), (8, 13)], LANA_LUZ)
    d.p([(24, 19), (32, 15), (26, 9), (22, 14)], LANA_SOMBRA)
    d.e(12, 3, 19, 8, LANA_SOMBRA)  # capucha vacía
    d.ln([(10, 15), (20, 16)], LANA_SOMBRA)
    d.px(27, 14, SANGRE_VIVA)
    return d.fin()


def cuenco() -> Image.Image:
    """Cuenco de limosna con tres almas apagadas (piedrecitas grises)."""
    d = D(20, 12)
    d.e(1, 2, 18, 11, BARRO_SOMBRA)
    d.e(2, 2, 17, 7, BARRO)
    d.e(4, 3, 15, 6, VACIO)
    for x in (6, 9, 12):
        d.px(x, 4, c("#8d949b"))
    d.e(3, 7, 7, 10, BARRO_LUZ)
    return d.fin()


def sandalia() -> Image.Image:
    d = D(16, 10)
    d.e(1, 2, 14, 8, MADERA_SOMBRA)
    d.e(2, 2, 13, 7, MADERA)
    d.ln([(5, 3), (9, 7)], LANA)
    d.ln([(9, 3), (5, 7)], LANA)
    return d.fin()


def marcas_peregrino() -> Image.Image:
    """Muro: rayas de tiza que cuentan días, de muchos peregrinos."""
    d = D(30, 22)
    rnd = random.Random(21)
    for g in range(3):
        ox = 2 + g * 10
        oy = 3 + rnd.randint(0, 6)
        for k in range(4):
            d.ln([(ox + k * 2, oy), (ox + k * 2, oy + 7)], TIZA)
        d.ln([(ox - 1, oy + 6), (ox + 7, oy + 1)], TIZA)
    return d.fin(borde=False)


# ============================================================ III · CACERÍA
def flechas() -> Image.Image:
    """Flechas clavadas en el suelo, con plumas negras."""
    d = D(22, 20)
    for x, h, inc in ((3, 15, 2), (10, 18, -1), (16, 13, 1)):
        d.ln([(x, 19), (x + inc, 19 - h)], MADERA_LUZ)
        d.ln([(x + inc - 1, 19 - h), (x + inc - 1, 23 - h)], PLUMA)
        d.ln([(x + inc + 1, 19 - h), (x + inc + 1, 23 - h)], PLUMA)
    d.e(0, 17, 21, 19, c("#3a2a24", 160))
    return d.fin()


def cepo() -> Image.Image:
    """Cepo de hierro abierto: dientes y cadena."""
    d = D(26, 18)
    d.e(2, 3, 23, 15, HIERRO)
    d.e(5, 6, 20, 12, VACIO)
    for k in range(6):
        x = 6 + k * 3
        d.p([(x, 6), (x + 2, 6), (x + 1, 9)], HIERRO_LUZ)
        d.p([(x, 12), (x + 2, 12), (x + 1, 9)], HIERRO_LUZ)
    d.r(11, 8, 14, 10, HIERRO_LUZ)
    d.ln([(23, 9), (25, 14), (21, 17)], HIERRO)
    return d.fin()


def hilos() -> Image.Image:
    """Hilos del Segador cortados: carretes rotos y hebras tensas."""
    d = D(34, 16)
    d.ln([(0, 3), (33, 12)], c("#d8e4ec", 200))
    d.ln([(3, 14), (20, 1)], c("#d8e4ec", 160))
    d.e(22, 6, 31, 15, MADERA)
    d.e(25, 9, 28, 12, MADERA_SOMBRA)
    d.px(12, 6, SANGRE_VIVA)
    d.px(13, 6, SANGRE)
    return d.fin()


def zarpazos() -> Image.Image:
    """Muro: cuatro zarpazos profundos con sangre seca."""
    d = D(24, 30)
    for k in range(4):
        x = 3 + k * 5
        d.ln([(x, 2 + k), (x + 4, 27 - k)], VACIO, 2)
        d.ln([(x + 1, 2 + k), (x + 5, 27 - k)], PIEDRA_LUZ)
    d.ln([(10, 18), (11, 28)], SANGRE_SECA)
    return d.fin(borde=False)


# ======================================================= IV · CLAUSTRO ENRAIZADO
def raices() -> Image.Image:
    """Raíces que rompen las losas."""
    d = D(46, 20)
    rnd = random.Random(4)
    for k in range(4):
        x, y = 4 + k * 3, 10 + rnd.randint(-4, 4)
        pts = [(x, y)]
        for i in range(6):
            x += rnd.randint(4, 8)
            y += rnd.randint(-3, 3)
            pts.append((x, max(1, min(18, y))))
        d.ln(pts, RAIZ_SOMBRA, 3)
        d.ln(pts, RAIZ_C, 2)
        d.ln([(px, py - 1) for px, py in pts], RAIZ_LUZ)
    d.r(18, 6, 21, 9, PIEDRA_SOMBRA)  # losa levantada
    return d.fin()


def hongos() -> Image.Image:
    """Hongos pálidos que brillan un poco en la penumbra."""
    d = D(22, 16)
    for x, y, r in ((3, 7, 4), (11, 4, 5), (17, 9, 3)):
        d.r(x + r - 1, y + r - 1, x + r, 15, HONGO_PIE)
        d.e(x, y, x + 2 * r, y + r + 1, HONGO)
        d.e(x + 1, y, x + r, y + 2, HONGO_LUZ)
        d.px(x + r, y + 1, BIOLUZ)
    return d.fin()


def hojas() -> Image.Image:
    d = D(30, 14)
    rnd = random.Random(44)
    for _ in range(9):
        x, y = rnd.randint(2, 25), rnd.randint(2, 10)
        col = HOJA if rnd.random() < 0.5 else HOJA_SECA
        d.p([(x, y), (x + 3, y - 2), (x + 5, y), (x + 2, y + 2)], col)
    return d.fin()


def raiz_muro() -> Image.Image:
    """Muro: raíces que cuelgan de una grieta del techo."""
    d = D(30, 40)
    rnd = random.Random(40)
    d.r(4, 0, 25, 3, VACIO)
    for k in range(5):
        x = 6 + k * 4
        pts = [(x, 2)]
        y = 2
        while y < 34 - rnd.randint(0, 12):
            y += 4
            x += rnd.randint(-2, 2)
            pts.append((x, y))
        d.ln(pts, RAIZ_C, 2)
        d.ln([(px - 1, py) for px, py in pts], RAIZ_LUZ)
    d.px(14, 30, BIOLUZ)
    return d.fin()


# ===================================================== V · LABERINTO DE MASTINES
def collar() -> Image.Image:
    """Collar de púas roto con su cadena."""
    d = D(30, 16)
    d.e(2, 2, 15, 14, HIERRO)
    d.e(4, 4, 13, 12, (0, 0, 0, 0))
    for a in range(0, 360, 60):
        x = 8.5 + math.cos(math.radians(a)) * 7.5
        y = 8 + math.sin(math.radians(a)) * 7.5
        d.px(x, y, HIERRO_LUZ)
    for i, x in enumerate(range(16, 29, 3)):
        d.e(x, 7 + (i % 2), x + 3, 10 + (i % 2), HIERRO)
    return d.fin()


def hueso_roido() -> Image.Image:
    d = D(22, 10)
    d.ln([(4, 5), (17, 5)], HUESO, 3)
    d.e(0, 1, 5, 5, HUESO_LUZ)
    d.e(0, 5, 5, 9, HUESO)
    d.e(16, 1, 21, 5, HUESO_LUZ)
    d.e(16, 5, 21, 9, HUESO)
    for x in (8, 11, 13):  # mordiscos
        d.px(x, 4, HUESO_SOMBRA)
        d.px(x, 6, VACIO)
    return d.fin()


def huellas() -> Image.Image:
    """Huellas de mastín con sangre, en fila."""
    d = D(50, 18)
    for i, x in enumerate(range(3, 46, 11)):
        y = 4 if i % 2 else 11
        d.e(x, y, x + 4, y + 4, SANGRE)
        for k in range(3):
            d.px(x - 1 + k * 3, y - 2, SANGRE_VIVA)
    return d.fin(borde=False)


def jaula() -> Image.Image:
    """Muro: argolla con una jaula colgada, la puerta abierta."""
    d = D(22, 38)
    d.ln([(11, 0), (11, 8)], HIERRO)
    d.e(2, 8, 20, 14, HIERRO)
    d.e(4, 10, 18, 13, (0, 0, 0, 0))
    for x in (3, 7, 11, 15, 19):
        d.ln([(x, 11), (x, 34)], HIERRO_LUZ if x == 11 else HIERRO)
    d.r(2, 34, 20, 36, HIERRO)
    d.ln([(19, 20), (24, 28)], HIERRO_LUZ)  # puerta abierta
    return d.fin()


# ============================================================ VI · LA OFRENDA
def ofrenda() -> Image.Image:
    """Bandeja de ofrendas: pan, fruta seca y una vela."""
    d = D(28, 18)
    d.e(1, 9, 26, 17, ORO)
    d.e(3, 10, 24, 15, c("#7a6234"))
    d.e(5, 7, 13, 12, c("#c98a43"))
    d.e(6, 7, 10, 9, c("#f0c27a"))
    for x, y in ((15, 9), (18, 10), (16, 11)):
        d.e(x, y, x + 3, y + 3, FLOR)
    d.r(21, 3, 22, 11, CERA)
    d.px(21, 2, LLAMA)
    d.px(21, 1, LLAMA_V)
    return d.fin()


def monedas() -> Image.Image:
    d = D(20, 12)
    rnd = random.Random(6)
    for _ in range(7):
        x, y = rnd.randint(1, 14), rnd.randint(2, 7)
        d.e(x, y, x + 4, y + 3, ORO)
        d.px(x + 1, y + 1, c("#f1d48a"))
    return d.fin()


def flores_secas() -> Image.Image:
    d = D(26, 14)
    d.ln([(2, 10), (22, 7)], HOJA, 1)
    d.ln([(4, 12), (21, 4)], HOJA_SECA, 1)
    for x, y in ((20, 4), (22, 7), (17, 3), (23, 5)):
        d.e(x - 1, y - 1, x + 2, y + 2, FLOR if (x + y) % 2 else FLOR_SECA)
    d.r(9, 7, 11, 10, c("#8a6a34"))  # lazo
    return d.fin()


def guirnalda() -> Image.Image:
    """Muro: guirnalda de flores marchitas entre dos clavos."""
    d = D(36, 18)
    pts = [(1 + i * 2, 2 + math.sin(i / 17 * math.pi) * 10) for i in range(18)]
    d.ln(pts, HOJA, 2)
    for i, (x, y) in enumerate(pts[1::3]):
        d.e(x - 2, y - 1, x + 2, y + 3, FLOR if i % 2 else FLOR_SECA)
    d.px(1, 1, HIERRO_LUZ)
    d.px(34, 1, HIERRO_LUZ)
    return d.fin()


# ================================================= VII · LA QUE NO APARTA LA VISTA
def venda() -> Image.Image:
    """Venda manchada: alguien quiso no mirar."""
    d = D(32, 12)
    d.ln([(1, 8), (8, 4), (16, 6), (24, 3), (30, 7)], c("#cfc6b0"), 3)
    d.ln([(1, 7), (8, 3), (16, 5), (24, 2), (30, 6)], c("#ece4d0"))
    d.e(12, 4, 17, 8, SANGRE)
    d.e(18, 3, 22, 7, SANGRE_SECA)
    return d.fin()


def espejo_roto() -> Image.Image:
    """Marco de espejo caído y sus esquirlas."""
    d = D(30, 20)
    d.e(2, 2, 19, 18, ORO)
    d.e(4, 4, 17, 16, CRISTAL)
    d.ln([(10, 4), (8, 11), (15, 15)], VACIO)
    d.ln([(8, 11), (4, 10)], VACIO)
    d.px(7, 6, CRISTAL_LUZ)
    for x, y in ((22, 6), (25, 12), (21, 15)):
        d.p([(x, y), (x + 3, y + 1), (x + 1, y + 3)], CRISTAL_LUZ)
    return d.fin()


def ojo_pintado() -> Image.Image:
    """Muro: un ojo enorme pintado con sangre; mira hacia la sala."""
    d = D(34, 24)
    d.p([(1, 12), (9, 3), (17, 1), (25, 3), (33, 12), (25, 20), (17, 22), (9, 20)], SANGRE)
    d.p([(4, 12), (11, 5), (17, 4), (23, 5), (30, 12), (23, 18), (17, 19), (11, 18)], c("#d8cfb8", 200))
    d.e(11, 6, 23, 18, SANGRE_VIVA)
    d.e(14, 9, 20, 15, VACIO)
    d.px(15, 10, c("#f1ebdb"))
    for x in (8, 17, 26):
        d.ln([(x, 21), (x, 23)], SANGRE)
    return d.fin(borde=False)


# =============================================== VIII · LAS SALAS QUE CAMBIAN
def tiza() -> Image.Image:
    """Flechas de tiza que se contradicen, como un mapa que ya no sirve."""
    d = D(40, 22)
    d.ln([(3, 6), (18, 6)], TIZA)
    d.ln([(14, 3), (18, 6), (14, 9)], TIZA)
    d.ln([(36, 15), (21, 15)], TIZA)
    d.ln([(25, 12), (21, 15), (25, 18)], TIZA)
    d.ln([(28, 2), (34, 8)], TIZA)
    d.ln([(34, 2), (28, 8)], TIZA)
    return d.fin(borde=False)


def mosaico() -> Image.Image:
    """Teselas del suelo desplazadas: el suelo se movió."""
    d = D(30, 18)
    rnd = random.Random(8)
    for i in range(7):
        x, y = 2 + (i % 4) * 7 + rnd.randint(-1, 1), 2 + (i // 4) * 8 + rnd.randint(-1, 2)
        col = [PIEDRA, PIEDRA_LUZ, c("#5d6e6a"), c("#7a6a5a")][i % 4]
        d.r(x, y, x + 5, y + 5, col)
        d.r(x, y + 5, x + 5, y + 6, PIEDRA_SOMBRA)
    return d.fin()


def runa_muro() -> Image.Image:
    """Muro: runa del templo que brilla débil y está escrita al revés."""
    d = D(22, 26)
    d.e(1, 1, 21, 25, c("#2a3a40", 140))
    d.ln([(11, 3), (11, 22)], BIOLUZ)
    d.ln([(5, 8), (11, 12), (17, 8)], BIOLUZ)
    d.ln([(6, 18), (16, 18)], BIOLUZ)
    d.px(11, 2, c("#e6f6ff"))
    return d.fin(borde=False)


# =============================================== IX · EL COLOSO DEL PÓRTICO
def cascotes() -> Image.Image:
    """Bloques caídos del pórtico."""
    d = D(40, 22)
    for x, y, w, h in ((2, 8, 14, 11), (15, 3, 12, 10), (24, 11, 13, 9), (12, 15, 7, 5)):
        d.r(x, y, x + w, y + h, PIEDRA)
        d.r(x, y, x + w, y + 2, PIEDRA_LUZ)
        d.r(x + w - 2, y + 2, x + w, y + h, PIEDRA_SOMBRA)
    d.ln([(18, 5), (21, 11)], PIEDRA_SOMBRA)
    return d.fin()


def capitel() -> Image.Image:
    """Capitel de columna partido, con volutas."""
    d = D(36, 20)
    d.r(3, 5, 32, 10, PIEDRA_LUZ)
    d.r(6, 10, 29, 18, PIEDRA)
    d.r(27, 10, 29, 18, PIEDRA_SOMBRA)
    for x in (3, 26):
        d.e(x, 3, x + 7, 10, PIEDRA)
        d.e(x + 2, 5, x + 5, 8, PIEDRA_SOMBRA)
    d.p([(20, 10), (25, 18), (29, 18), (29, 12)], (0, 0, 0, 0))  # rotura
    return d.fin()


def mano_piedra() -> Image.Image:
    """Mano de una estatua rota, del tamaño de una persona."""
    d = D(30, 20)
    d.r(2, 8, 13, 17, PIEDRA)
    for k in range(4):
        y = 6 + k * 3
        d.r(13, y, 26 - k * 2, y + 2, PIEDRA_LUZ if k == 0 else PIEDRA)
    d.r(8, 3, 15, 7, PIEDRA)
    d.r(2, 14, 13, 17, PIEDRA_SOMBRA)
    return d.fin()


def grieta_grande() -> Image.Image:
    """Muro: grieta que baja del techo por el golpe del Coloso."""
    d = D(20, 40)
    pts = [(10, 0), (8, 8), (12, 15), (7, 24), (11, 31), (9, 39)]
    d.ln(pts, VACIO, 3)
    d.ln([(x + 1, y) for x, y in pts], PIEDRA_LUZ)
    d.ln([(12, 15), (17, 19)], VACIO)
    d.ln([(7, 24), (2, 27)], VACIO)
    return d.fin(borde=False)


# =================================================== X · LA COSECHA
def hoz() -> Image.Image:
    d = D(30, 20)
    d.ln([(3, 18), (12, 9)], MADERA, 2)
    pts = [(12, 9) ]
    for k in range(9):
        a = math.radians(200 + k * 18)
        pts.append((19 + math.cos(a) * 9, 9 + math.sin(a) * 8))
    d.ln(pts, HIERRO, 2)
    d.ln([(x, y - 1) for x, y in pts[2:]], HIERRO_LUZ)
    d.px(27, 9, SANGRE_VIVA)
    return d.fin()


def gavilla() -> Image.Image:
    """Gavilla de trigo seco atada con una cinta roja."""
    d = D(28, 22)
    for k in range(9):
        x = 4 + k * 2.5
        xb = 10 + k
        d.ln([(xb, 20), (14, 14), (x, 3)], TRIGO if k % 2 else TRIGO_LUZ)
        d.e(x - 1, 1, x + 1, 5, TRIGO_SOMBRA if k % 3 else TRIGO_LUZ)
    d.r(11, 13, 17, 15, TELA)
    d.px(18, 15, TELA_LUZ)
    return d.fin()


def huesos_atados() -> Image.Image:
    """Huesos atados en haz, como si fueran cosecha."""
    d = D(30, 14)
    for k in range(4):
        d.ln([(2, 4 + k * 2), (27, 3 + k * 2)], HUESO if k % 2 else HUESO_LUZ, 2)
    d.r(12, 2, 15, 12, TRIGO_SOMBRA)
    d.ln([(12, 2), (15, 12)], TRIGO)
    return d.fin()


def marcas_alas() -> Image.Image:
    """Muro: marcas de alas grabadas, en filas; demasiadas para contarlas."""
    d = D(40, 26)
    hueso = c("#c9b98f", 190)
    for fila in range(3):
        for col in range(5):
            x, y = 2 + col * 8 + (fila % 2) * 2, 3 + fila * 8
            d.ln([(x + 3, y + 3), (x, y), (x, y + 4)], hueso)
            d.ln([(x + 3, y + 3), (x + 6, y), (x + 6, y + 4)], hueso)
    return d.fin(borde=False)


DECORADOS = {
    # II
    "baculo": baculo, "manto": manto, "cuenco": cuenco, "sandalia": sandalia, "marcas_peregrino": marcas_peregrino,
    # III
    "flechas": flechas, "cepo": cepo, "hilos": hilos, "zarpazos": zarpazos,
    # IV
    "raices": raices, "hongos": hongos, "hojas": hojas, "raiz_muro": raiz_muro,
    # V
    "collar": collar, "hueso_roido": hueso_roido, "huellas": huellas, "jaula": jaula,
    # VI
    "ofrenda": ofrenda, "monedas": monedas, "flores_secas": flores_secas, "guirnalda": guirnalda,
    # VII
    "venda": venda, "espejo_roto": espejo_roto, "ojo_pintado": ojo_pintado,
    # VIII
    "tiza": tiza, "mosaico": mosaico, "runa_muro": runa_muro,
    # IX
    "cascotes": cascotes, "capitel": capitel, "mano_piedra": mano_piedra, "grieta_grande": grieta_grande,
    # X
    "hoz": hoz, "gavilla": gavilla, "huesos_atados": huesos_atados, "marcas_alas": marcas_alas,
}


def main() -> None:
    parser = argparse.ArgumentParser(description="Genera el decorado propio de cada piso.")
    parser.add_argument("--vista-previa", type=Path)
    args = parser.parse_args()
    SALIDA.mkdir(parents=True, exist_ok=True)
    imgs = {}
    for nombre, fn in DECORADOS.items():
        imgs[nombre] = fn()
        imgs[nombre].save(SALIDA / f"{nombre}.png", optimize=True)
    print(f"{len(imgs)} decorados de piso en {SALIDA.relative_to(RAIZ)}")
    if args.vista_previa:
        por_fila = 9
        filas = (len(imgs) + por_fila - 1) // por_fila
        lam = Image.new("RGBA", (por_fila * 52 + 6, filas * 50 + 6), (40, 58, 50, 255))
        for i, im in enumerate(imgs.values()):
            lam.alpha_composite(im, (6 + (i % por_fila) * 52, 6 + (i // por_fila) * 50))
        lam.resize((lam.width * 3, lam.height * 3), Image.NEAREST).save(args.vista_previa)


if __name__ == "__main__":
    main()
