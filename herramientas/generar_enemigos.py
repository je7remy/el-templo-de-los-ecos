#!/usr/bin/env python3
"""Genera los sprites ORIGINALES y cenitales de las tres entidades del piso 1.

Arte propio del proyecto (sin recursos de terceros), en el estilo del
protagonista: pixel art plano, contorno oscuro, vista 3/4 frontal.

Salida: assets/visual/enemies/<entidad>.png
  * Celdas de 48 x 64 px. Pies (o punto de flotación) en y = 61.
  * Filas: 0 abajo/frente, 1 arriba/espalda, 2 derecha, 3 izquierda (espejo).
  * Columnas según la entidad (ver FRAMES).

Uso:  python3 herramientas/generar_enemigos.py [--vista-previa RUTA.png]
"""
from __future__ import annotations

import argparse
import math
from pathlib import Path

from PIL import Image, ImageDraw

RAIZ = Path(__file__).resolve().parent.parent
SALIDA = RAIZ / "assets" / "visual" / "enemies"
CW, CH = 48, 64
PIE = 61
CONTORNO = (19, 24, 30, 255)

# Columnas de cada hoja.
FRAMES = {
    # 0-3 flotando con el ojo ABIERTO, 4-7 flotando con el ojo CERRADO.
    "testigo": 8,
    # 0-1 reposo, 2-5 caminar.
    "ghoul": 6,
    # 0-1 reposo, 2-5 caminar, 6-7 conjurar.
    "hechicero": 8,
    # Humano del Piso II. 0-1 reposo, 2-5 caminar, 6 cuchillo alzado, 7 estocada.
    "peregrino": 8,
    # Segador de Hilos (Piso III). 0-1 reposo, 2-5 correr, 6 tensar, 7 enganchado.
    "segador": 8,
}


def c(hexa: str, a: int = 255) -> tuple:
    hexa = hexa.lstrip("#")
    return (int(hexa[0:2], 16), int(hexa[2:4], 16), int(hexa[4:6], 16), a)


class Lienzo:
    def __init__(self) -> None:
        self.img = Image.new("RGBA", (CW, CH), (0, 0, 0, 0))
        self.d = ImageDraw.Draw(self.img)

    def rect(self, x0, y0, x1, y1, col) -> None:
        self.d.rectangle([x0, y0, x1, y1], fill=col)

    def poly(self, pts, col) -> None:
        self.d.polygon([(round(x), round(y)) for x, y in pts], fill=col)

    def elipse(self, x0, y0, x1, y1, col) -> None:
        self.d.ellipse([x0, y0, x1, y1], fill=col)

    def px(self, x, y, col) -> None:
        if 0 <= x < CW and 0 <= y < CH:
            self.img.putpixel((int(x), int(y)), col)

    def linea(self, pts, col, ancho=1) -> None:
        self.d.line([(round(x), round(y)) for x, y in pts], fill=col, width=ancho)

    def luz_cenital(self) -> None:
        """Vista desde arriba: la luz cae del techo.

        Aclara los 2 primeros píxeles opacos de cada columna (coronilla,
        hombros, borde superior de alas y capuchas) y oscurece el último,
        que queda cerca del suelo.
        """
        a = self.img.load()
        for x in range(CW):
            ys = [y for y in range(CH) if a[x, y][3] > 0]
            if not ys:
                continue
            for k, y in enumerate(ys[:2]):
                r, g, b, al = a[x, y]
                f = 0.34 if k == 0 else 0.16
                a[x, y] = (int(r + (255 - r) * f), int(g + (255 - g) * f), int(b + (240 - b) * f), al)
            r, g, b, al = a[x, ys[-1]]
            a[x, ys[-1]] = (int(r * 0.7), int(g * 0.7), int(b * 0.75), al)

    def contorno(self) -> Image.Image:
        """Contorno exterior de 1 px, como el protagonista."""
        self.luz_cenital()
        src = self.img.copy()
        a = src.load()
        out = src.copy()
        o = out.load()
        for y in range(CH):
            for x in range(CW):
                if a[x, y][3] != 0:
                    continue
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    xx, yy = x + dx, y + dy
                    if 0 <= xx < CW and 0 <= yy < CH and a[xx, yy][3] > 0:
                        o[x, y] = CONTORNO
                        break
        return out


# --------------------------------------------------------------------------
# TESTIGO — creación del ángel: piedra pálida, un solo ojo, alas atrofiadas.
# --------------------------------------------------------------------------
PIEDRA = c("#a7b0a0")
PIEDRA_SOMBRA = c("#76806f")
PIEDRA_OSCURA = c("#4f5749")
PIEDRA_LUZ = c("#cfd6c4")
PLUMA = c("#e4e2d6")
PLUMA_SOMBRA = c("#a9a69a")
OJO_BLANCO = c("#efe6d8")
OJO_IRIS = c("#c2414f")
OJO_PUPILA = c("#2a0c12")
VACIO = c("#17141a")
MUSGO = c("#4d6a3c")
MUSGO_LUZ = c("#77964f")
CADENA = c("#5c5f63")
CADENA_LUZ = c("#9da2a3")
HALO = c("#f1d48a")
HALO_APAGADO = c("#8d876f")


def _alas(l: Lienzo, cx: float, y: float, aleteo: float, delante: bool) -> None:
    for lado in (-1, 1):
        base_x = cx + lado * 7
        punta_x = cx + lado * (17 + aleteo)
        pts = [(base_x, y), (punta_x, y - 9 - aleteo), (punta_x + lado * 1, y - 2), (cx + lado * 13, y + 9), (base_x, y + 7)]
        l.poly(pts, PLUMA if delante else PLUMA_SOMBRA)
        for i in range(3):
            fx = base_x + lado * (4 + i * 3)
            l.linea([(fx, y + 1 + i), (fx + lado * 2, y + 6 + i)], PLUMA_SOMBRA if delante else PIEDRA_SOMBRA)


def testigo(direccion: int, frame: int) -> Image.Image:
    l = Lienzo()
    abierto = frame < 4
    fase = frame % 4
    bob = [0, -1, -1, 0][fase]
    aleteo = [0, 1, 2, 1][fase]
    cx = 24
    top = 9 + bob
    # Alas detrás del cuerpo (de frente y de lado); de espalda van delante.
    if direccion != 1:
        _alas(l, cx, top + 17, aleteo, delante=False)
    # Túnica de piedra que se deshilacha en el borde: no tiene pies.
    hem = PIE - 6 + bob
    if direccion in (0, 1):
        l.poly([(cx - 8, top + 14), (cx + 8, top + 14), (cx + 12, hem), (cx - 12, hem)], PIEDRA)
        l.poly([(cx + 2, top + 14), (cx + 8, top + 14), (cx + 12, hem), (cx + 4, hem)], PIEDRA_SOMBRA)
        for i, x in enumerate(range(cx - 12, cx + 12, 4)):
            largo = 3 + (i + fase) % 3
            l.poly([(x, hem), (x + 4, hem), (x + 2, hem + largo)], PIEDRA_SOMBRA if x >= cx else PIEDRA)
        l.linea([(cx - 3, top + 18), (cx - 5, hem - 2)], PIEDRA_SOMBRA)
    else:
        l.poly([(cx - 6, top + 14), (cx + 6, top + 14), (cx + 9, hem), (cx - 9, hem)], PIEDRA)
        l.poly([(cx - 6, top + 14), (cx - 1, top + 14), (cx - 3, hem), (cx - 9, hem)], PIEDRA_SOMBRA)
        for i, x in enumerate(range(cx - 9, cx + 9, 4)):
            largo = 3 + (i + fase) % 3
            l.poly([(x, hem), (x + 4, hem), (x + 2, hem + largo)], PIEDRA_SOMBRA if x < cx else PIEDRA)
    # Manos de piedra unidas al frente (gesto de oración vigilante).
    if direccion == 0:
        l.rect(cx - 3, top + 24, cx + 2, top + 28, PIEDRA_LUZ)
        l.rect(cx - 1, top + 22, cx, top + 24, PIEDRA_LUZ)
    elif direccion == 2:
        l.rect(cx + 4, top + 23, cx + 7, top + 27, PIEDRA_LUZ)
    # Capucha.
    l.elipse(cx - 9, top, cx + 9, top + 18, PIEDRA)
    l.elipse(cx + 1, top + 2, cx + 9, top + 18, PIEDRA_SOMBRA)
    l.rect(cx - 9, top + 9, cx + 9, top + 16, PIEDRA)
    l.rect(cx + 2, top + 9, cx + 9, top + 16, PIEDRA_SOMBRA)
    l.rect(cx - 7, top + 1, cx - 4, top + 3, PIEDRA_LUZ)
    if direccion == 0:
        # Rostro: hueco oscuro con UN ojo vertical.
        l.elipse(cx - 6, top + 4, cx + 6, top + 17, VACIO)
        if abierto:
            l.elipse(cx - 3, top + 6, cx + 3, top + 15, OJO_BLANCO)
            l.elipse(cx - 2, top + 8, cx + 2, top + 13, OJO_IRIS)
            l.rect(cx - 1, top + 9, cx, top + 12, OJO_PUPILA)
            l.px(cx - 2, top + 8, c("#ffffff"))
        else:
            l.linea([(cx - 3, top + 11), (cx + 3, top + 11)], PIEDRA_SOMBRA)
            for x in (cx - 2, cx, cx + 2):
                l.px(x, top + 12, PIEDRA_OSCURA)
    elif direccion == 2:
        l.poly([(cx + 1, top + 5), (cx + 9, top + 6), (cx + 9, top + 16), (cx + 1, top + 16)], VACIO)
        if abierto:
            l.elipse(cx + 4, top + 7, cx + 8, top + 14, OJO_BLANCO)
            l.rect(cx + 6, top + 9, cx + 8, top + 12, OJO_IRIS)
            l.px(cx + 7, top + 10, OJO_PUPILA)
        else:
            l.linea([(cx + 4, top + 11), (cx + 8, top + 11)], PIEDRA_SOMBRA)
    else:
        # Espalda: costura de la capucha y alas por delante.
        l.linea([(cx, top + 2), (cx, top + 16)], PIEDRA_SOMBRA)
        _alas(l, cx, top + 17, aleteo, delante=True)
    # Detalles: grietas en la piedra, musgo en el borde y cadena de penitente.
    l.linea([(cx - 6, top + 30), (cx - 4, top + 34), (cx - 6, top + 37)], PIEDRA_OSCURA)
    l.linea([(cx + 5, top + 22), (cx + 7, top + 26)], PIEDRA_OSCURA)
    for x, y in ((cx - 9, hem - 2), (cx - 7, hem - 1), (cx + 6, hem - 2), (cx + 8, hem - 1), (cx - 1, hem - 1)):
        l.px(x, y, MUSGO)
        l.px(x + 1, y, MUSGO_LUZ)
    for i, x in enumerate(range(cx - 7, cx + 8, 2)):
        l.px(x, top + 20 + (1 if 2 <= i <= 5 else 0), CADENA if i % 2 else CADENA_LUZ)
    # Halo roto que flota sobre la capucha: se ve desde arriba como un arco.
    hy = top - 3 + (fase % 2)
    for x in range(cx - 6, cx + 7):
        if x in (cx + 1, cx + 2):
            continue  # el hueco de la rotura
        dy = 0 if abs(x - cx) < 4 else 1
        l.px(x, hy + dy, HALO if abierto else HALO_APAGADO)
    return l.contorno()


# --------------------------------------------------------------------------
# GHOUL DE BRASAS — humano modificado: cuerpo consumido, grietas de brasa.
# --------------------------------------------------------------------------
CARBON = c("#3a2724")
CARBON_SOMBRA = c("#251816")
CARBON_LUZ = c("#5a3b33")
BRASA = c("#f08a3a")
BRASA_VIVA = c("#ffd36b")
LLAMA_ROJA = c("#c2412f")
OJO_FUEGO = c("#fff0b0")


def _llama(l: Lienzo, cx: float, base: float, t: int, ancho: int = 6) -> None:
    alturas = [(9, 6, 11), (11, 7, 9), (8, 10, 7), (10, 8, 12)][t % 4]
    for i, (dx, h) in enumerate(zip((-ancho // 2, 0, ancho // 2), alturas)):
        x = cx + dx
        l.poly([(x - 3, base), (x + 3, base), (x + 1, base - h), (x, base - h - 2)], LLAMA_ROJA)
        l.poly([(x - 2, base), (x + 2, base), (x, base - h + 2)], BRASA)
        if i == 1:
            l.poly([(x - 1, base), (x + 1, base), (x, base - h + 5)], BRASA_VIVA)


def _ceniza(l: Lienzo, cx: float, cab: float, t: int) -> None:
    """Chispas que suben desde la cabeza en llamas."""
    for i, (dx, base) in enumerate(((-7, 4), (6, 1), (-2, 7))):
        y = cab - base - ((t * 3 + i * 5) % 9)
        if y > 0:
            l.px(cx + dx + (t + i) % 2, y, BRASA_VIVA if i % 2 else BRASA)


def ghoul(direccion: int, frame: int) -> Image.Image:
    l = Lienzo()
    caminar = frame >= 2
    paso = [0, 1, 0, -1][(frame - 2) % 4] if caminar else 0
    resp = 0 if caminar else frame % 2
    cx = 24
    hombro = 25 + resp
    cadera = 44
    if direccion in (0, 1):
        # Piernas delgadas.
        for lado, fase in ((-1, paso), (1, -paso)):
            x = cx + lado * 4
            fin = PIE - max(0, fase) * 2
            l.rect(x - 2, cadera, x + 1, fin, CARBON if lado < 0 else CARBON_SOMBRA)
            l.rect(x - 3, fin - 1, x + 2, fin, CARBON_SOMBRA)
        # Torso encorvado y costillas con brasa.
        l.poly([(cx - 8, hombro), (cx + 8, hombro), (cx + 6, cadera), (cx - 6, cadera)], CARBON)
        l.poly([(cx + 2, hombro), (cx + 8, hombro), (cx + 6, cadera), (cx + 2, cadera)], CARBON_SOMBRA)
        if direccion == 0:
            for i in range(3):
                y = hombro + 5 + i * 4
                l.linea([(cx - 5, y), (cx - 1, y + 1)], BRASA)
                l.linea([(cx + 1, y + 1), (cx + 4, y)], BRASA)
            l.rect(cx - 1, hombro + 3, cx, cadera - 3, BRASA_VIVA)
        else:
            l.linea([(cx, hombro + 2), (cx, cadera - 2)], BRASA)
            l.linea([(cx - 4, hombro + 8), (cx - 1, hombro + 12)], BRASA)
        # Brazos largos colgando hasta las rodillas, balanceándose.
        for lado, fase in ((-1, -paso), (1, paso)):
            x = cx + lado * 9
            l.poly([(x - 2, hombro), (x + 2, hombro), (x + 2 + fase, cadera + 6), (x - 1 + fase, cadera + 6)], CARBON_LUZ if lado < 0 else CARBON)
            l.rect(x - 2 + fase, cadera + 6, x + 2 + fase, cadera + 9, CARBON_SOMBRA)
            l.px(x + fase, cadera + 9, BRASA)
        # Cabeza: cráneo carbonizado envuelto en llamas.
        cab = hombro - 11
        l.elipse(cx - 6, cab, cx + 6, cab + 12, CARBON)
        l.elipse(cx, cab + 1, cx + 6, cab + 12, CARBON_SOMBRA)
        if direccion == 0:
            l.rect(cx - 4, cab + 5, cx - 2, cab + 7, OJO_FUEGO)
            l.rect(cx + 2, cab + 5, cx + 4, cab + 7, OJO_FUEGO)
            l.linea([(cx - 3, cab + 10), (cx + 3, cab + 10)], BRASA)
        _llama(l, cx, cab + 3, frame)
        # La llama de la cabeza ilumina los hombros desde arriba.
        for lado in (-1, 1):
            l.linea([(cx + lado * 4, hombro), (cx + lado * 9, hombro + 1)], BRASA)
            l.px(cx + lado * 10, hombro + 1, LLAMA_ROJA)
        # Grietas de brasa en muslos y vientre.
        l.px(cx - 4, cadera + 4, BRASA)
        l.px(cx + 4, cadera + 7, BRASA)
        if direccion == 0:
            l.linea([(cx - 3, cadera - 2), (cx + 3, cadera - 2)], LLAMA_ROJA)
        _ceniza(l, cx, cab, frame)
    else:
        # Perfil derecho: avanza encorvado con un brazo extendido.
        for fase, col in ((paso, CARBON_SOMBRA), (-paso, CARBON)):
            x = cx - 1 + fase * 3
            l.poly([(cx - 2, cadera), (cx + 1, cadera), (x + 2, PIE - 1), (x - 1, PIE - 1)], col)
            l.rect(x - 1, PIE - 1, x + 3, PIE, CARBON_SOMBRA)
        l.poly([(cx - 5, hombro), (cx + 5, hombro + 1), (cx + 3, cadera), (cx - 4, cadera)], CARBON)
        l.poly([(cx - 5, hombro), (cx - 1, hombro), (cx - 1, cadera), (cx - 4, cadera)], CARBON_SOMBRA)
        l.linea([(cx + 1, hombro + 4), (cx + 2, cadera - 3)], BRASA)
        brazo = 2 + abs(paso) * 2
        l.poly([(cx + 2, hombro + 2), (cx + 5, hombro + 2), (cx + 11 + brazo, hombro + 12), (cx + 9 + brazo, hombro + 14)], CARBON_LUZ)
        l.px(cx + 11 + brazo, hombro + 14, BRASA)
        cab = hombro - 11
        l.elipse(cx - 4, cab, cx + 7, cab + 12, CARBON)
        l.rect(cx + 3, cab + 5, cx + 5, cab + 7, OJO_FUEGO)
        _llama(l, cx + 1, cab + 3, frame, ancho=4)
        l.linea([(cx - 2, hombro), (cx + 4, hombro + 1)], BRASA)
        l.px(cx - 2, cadera - 6, BRASA)
        _ceniza(l, cx, cab, frame)
    return l.contorno()


# --------------------------------------------------------------------------
# HECHICERO DEL ARCHIVO — humano modificado: archivista sin rostro, libro.
# --------------------------------------------------------------------------
TUNICA = c("#5e3478")
TUNICA_SOMBRA = c("#3f2153")
TUNICA_LUZ = c("#7d4b9a")
ADORNO = c("#c9a35f")
MANO = c("#b8b3a8")
OJO_VIOLETA = c("#d7a6ff")
PAGINA = c("#e8dfc4")
GLIFO = c("#8fc7d7")
ORBE = c("#ffb057")


def hechicero(direccion: int, frame: int) -> Image.Image:
    l = Lienzo()
    conjurar = frame >= 6
    caminar = 2 <= frame <= 5
    vaiven = [0, 1, 0, -1][(frame - 2) % 4] if caminar else 0
    resp = frame % 2 if frame < 2 else 0
    cx = 24
    top = 14 + resp
    hem = PIE - 1
    if direccion in (0, 1):
        l.poly([(cx - 7, top + 13), (cx + 7, top + 13), (cx + 12 + vaiven, hem), (cx - 12 + vaiven, hem)], TUNICA)
        l.poly([(cx + 2, top + 13), (cx + 7, top + 13), (cx + 12 + vaiven, hem), (cx + 4 + vaiven, hem)], TUNICA_SOMBRA)
        l.rect(cx - 12 + vaiven, hem - 2, cx + 12 + vaiven, hem, TUNICA_SOMBRA)
        if direccion == 0:
            l.linea([(cx - 1, top + 14), (cx - 1 + vaiven, hem - 3)], ADORNO)
            l.linea([(cx - 8, top + 31), (cx + 8, top + 31)], ADORNO)
            l.px(cx + 5, top + 32, ADORNO)
            l.px(cx + 5, top + 33, ADORNO)
            # Pies asomando al caminar.
            if caminar:
                l.rect(cx - 6 + vaiven * 2, hem, cx - 3 + vaiven * 2, hem + 1, c("#2a1f2c"))
                l.rect(cx + 3 - vaiven * 2, hem, cx + 6 - vaiven * 2, hem + 1, c("#2a1f2c"))
        # Mangas y manos.
        if conjurar and direccion == 0:
            alto = 3 if frame == 6 else 6
            for lado in (-1, 1):
                l.poly([(cx + lado * 6, top + 15), (cx + lado * 10, top + 13), (cx + lado * 12, top + 5 - alto), (cx + lado * 8, top + 6 - alto)], TUNICA_LUZ)
                l.rect(cx + lado * 11 - 1, top + 2 - alto, cx + lado * 11 + 1, top + 5 - alto, MANO)
            l.elipse(cx - 4, top - 9 - alto, cx + 4, top - 1 - alto, ORBE)
            l.elipse(cx - 2, top - 7 - alto, cx + 2, top - 3 - alto, c("#fff0c8"))
        elif direccion == 0:
            l.poly([(cx - 10, top + 15), (cx - 5, top + 14), (cx - 3, top + 25), (cx - 9, top + 26)], TUNICA_LUZ)
            l.poly([(cx + 5, top + 14), (cx + 10, top + 15), (cx + 9, top + 26), (cx + 3, top + 25)], TUNICA)
            # Libro abierto que brilla.
            l.rect(cx - 6, top + 23, cx + 6, top + 29, PAGINA)
            l.linea([(cx, top + 23), (cx, top + 29)], c("#9c8f72"))
            for y in (top + 25, top + 27):
                l.linea([(cx - 4, y), (cx - 2, y)], GLIFO)
                l.linea([(cx + 2, y), (cx + 4, y)], GLIFO)
            l.rect(cx - 7, top + 26, cx - 5, top + 28, MANO)
            l.rect(cx + 5, top + 26, cx + 7, top + 28, MANO)
        else:
            for lado in (-1, 1):
                l.poly([(cx + lado * 5, top + 14), (cx + lado * 10, top + 15), (cx + lado * 9, top + 27), (cx + lado * 4, top + 26)], TUNICA_SOMBRA)
        # Capucha puntiaguda.
        l.poly([(cx - 9, top + 15), (cx - 7, top + 2), (cx + 1, top - 7), (cx + 8, top + 3), (cx + 9, top + 15)], TUNICA)
        l.poly([(cx + 1, top - 7), (cx + 8, top + 3), (cx + 9, top + 15), (cx + 2, top + 15)], TUNICA_SOMBRA)
        l.linea([(cx - 7, top + 15), (cx + 7, top + 15)], ADORNO)
        if direccion == 0:
            l.elipse(cx - 5, top + 3, cx + 5, top + 15, VACIO)
            l.px(cx - 2, top + 9, OJO_VIOLETA)
            l.px(cx + 2, top + 9, OJO_VIOLETA)
            # Ribete dorado del borde de la capucha.
            for x, y in ((cx - 6, top + 6), (cx - 6, top + 10), (cx + 6, top + 6), (cx + 6, top + 10)):
                l.px(x, y, ADORNO)
            # Runas bordadas en el bajo de la túnica.
            for i, x in enumerate(range(cx - 9, cx + 10, 5)):
                y = hem - 5
                l.px(x + vaiven, y, GLIFO if i % 2 else ADORNO)
                l.px(x + 1 + vaiven, y - 1, GLIFO if i % 2 else ADORNO)
        else:
            l.linea([(cx, top - 4), (cx, top + 14)], TUNICA_LUZ)
            # Cordón y página suelta colgando de la espalda.
            l.linea([(cx - 6, top + 22), (cx + 6, top + 22)], ADORNO)
            l.rect(cx + 2, top + 23, cx + 5, top + 28, PAGINA)
            l.px(cx + 3, top + 25, GLIFO)
        # Borla de la punta de la capucha.
        l.px(cx + 1, top - 8, ADORNO)
    else:
        l.poly([(cx - 6, top + 13), (cx + 5, top + 13), (cx + 9 + vaiven, hem), (cx - 9 + vaiven, hem)], TUNICA)
        l.poly([(cx - 6, top + 13), (cx - 1, top + 13), (cx - 3 + vaiven, hem), (cx - 9 + vaiven, hem)], TUNICA_SOMBRA)
        l.rect(cx - 9 + vaiven, hem - 2, cx + 9 + vaiven, hem, TUNICA_SOMBRA)
        if conjurar:
            alto = 2 if frame == 6 else 4
            l.poly([(cx + 2, top + 14), (cx + 5, top + 13), (cx + 14, top + 9 - alto), (cx + 12, top + 12 - alto)], TUNICA_LUZ)
            l.rect(cx + 13, top + 8 - alto, cx + 15, top + 10 - alto, MANO)
            l.elipse(cx + 15, top + 3 - alto, cx + 22, top + 10 - alto, ORBE)
        else:
            l.poly([(cx + 1, top + 14), (cx + 5, top + 14), (cx + 8, top + 24), (cx + 4, top + 25)], TUNICA_LUZ)
            l.rect(cx + 4, top + 22, cx + 10, top + 27, PAGINA)
            l.linea([(cx + 5, top + 24), (cx + 9, top + 24)], GLIFO)
            l.rect(cx + 7, top + 25, cx + 9, top + 27, MANO)
        l.poly([(cx - 8, top + 15), (cx - 6, top + 1), (cx + 2, top - 7), (cx + 8, top + 4), (cx + 8, top + 15)], TUNICA)
        l.poly([(cx - 8, top + 15), (cx - 6, top + 1), (cx - 2, top - 3), (cx - 3, top + 15)], TUNICA_SOMBRA)
        l.poly([(cx + 2, top + 4), (cx + 8, top + 5), (cx + 8, top + 14), (cx + 2, top + 14)], VACIO)
        l.px(cx + 6, top + 9, OJO_VIOLETA)
        l.linea([(cx - 7, top + 15), (cx + 7, top + 15)], ADORNO)
        l.px(cx + 2, top - 8, ADORNO)
        for i, x in enumerate(range(cx - 7, cx + 8, 5)):
            l.px(x + vaiven, hem - 5, GLIFO if i % 2 else ADORNO)
        l.linea([(cx - 5, top + 22), (cx + 3, top + 22)], ADORNO)
    return l.contorno()


# --------------------------------------------------------------------------
# PEREGRINO — otro atrapado: hábito gastado, capucha, morral y un cuchillo.
# --------------------------------------------------------------------------
HABITO = c("#6b5a43")
HABITO_SOMBRA = c("#4a3d2d")
HABITO_LUZ = c("#8a7656")
CUERDA = c("#c9b48a")
PIEL_P = c("#d2a789")
PIEL_P_SOMBRA = c("#a87e64")
BARBA = c("#4a3a2e")
MORRAL = c("#3e4a3a")
ACERO = c("#cfd6dc")
ACERO_SOMBRA = c("#7f8a93")
OJO_P = c("#1d1a1c")


def peregrino(direccion: int, frame: int) -> Image.Image:
    l = Lienzo()
    caminar = 2 <= frame <= 5
    cuchillo = frame >= 6
    paso = [0, 1, 0, -1][(frame - 2) % 4] if caminar else 0
    resp = frame % 2 if frame < 2 else 0
    cx = 24
    top = 15 + resp
    hem = PIE - 4
    estocada = 3 if frame == 7 else 0
    # Pies con sandalias.
    for lado, fase in ((-1, paso), (1, -paso)):
        x = cx + lado * 4
        l.rect(x - 2, hem + 1 - max(0, fase), x + 1, PIE - max(0, fase), c("#3a2d22"))
    if direccion in (0, 1):
        # Hábito acampanado.
        l.poly([(cx - 8, top + 13), (cx + 8, top + 13), (cx + 11 + paso, hem + 1), (cx - 11 + paso, hem + 1)], HABITO)
        l.poly([(cx + 2, top + 13), (cx + 8, top + 13), (cx + 11 + paso, hem + 1), (cx + 4 + paso, hem + 1)], HABITO_SOMBRA)
        for x in range(cx - 10, cx + 11, 3):  # bajo deshilachado
            l.px(x + paso, hem + 2, HABITO_SOMBRA)
        # Cuerda a la cintura con nudo colgante.
        l.linea([(cx - 8, top + 24), (cx + 8, top + 24)], CUERDA)
        l.linea([(cx + 2, top + 24), (cx + 3, top + 30)], CUERDA)
        # Morral cruzado.
        if direccion == 0:
            l.linea([(cx - 7, top + 14), (cx + 6, top + 26)], c("#2c3529"))
            l.rect(cx + 5, top + 25, cx + 10, top + 30, MORRAL)
        else:
            l.rect(cx - 6, top + 14, cx + 6, top + 26, MORRAL)  # morral a la espalda
            l.rect(cx - 6, top + 14, cx + 6, top + 15, c("#56634f"))
        # Brazos.
        if cuchillo and direccion == 0:
            alto = 6 if frame == 6 else 1
            l.poly([(cx + 6, top + 15), (cx + 10, top + 14), (cx + 13, top + 8 - alto + estocada * 3), (cx + 10, top + 9 - alto + estocada * 3)], HABITO_LUZ)
            hy = top + 6 - alto + estocada * 3
            l.rect(cx + 10, hy, cx + 13, hy + 3, PIEL_P)
            l.poly([(cx + 11, hy), (cx + 13, hy), (cx + 12, hy - 8)], ACERO)
            l.px(cx + 12, hy - 7, c("#ffffff"))
            l.poly([(cx - 10, top + 15), (cx - 6, top + 14), (cx - 5, top + 25), (cx - 9, top + 26)], HABITO_LUZ)
            l.rect(cx - 9, top + 25, cx - 6, top + 27, PIEL_P)
        elif direccion == 0:
            l.poly([(cx - 10, top + 15), (cx - 6, top + 14), (cx - 5, top + 25), (cx - 9, top + 26)], HABITO_LUZ)
            l.rect(cx - 9, top + 25, cx - 6, top + 27, PIEL_P)
            # La otra mano siempre queda escondida tras la cadera.
            l.poly([(cx + 6, top + 14), (cx + 10, top + 15), (cx + 8, top + 24), (cx + 5, top + 23)], HABITO)
        else:
            for lado in (-1, 1):
                l.poly([(cx + lado * 6, top + 14), (cx + lado * 10, top + 15), (cx + lado * 9, top + 26), (cx + lado * 5, top + 25)], HABITO_SOMBRA)
            if cuchillo:
                l.poly([(cx + 9, top + 26), (cx + 11, top + 26), (cx + 10, top + 33)], ACERO_SOMBRA)
        # Capucha y rostro.
        l.elipse(cx - 9, top - 2, cx + 9, top + 15, HABITO)
        l.elipse(cx + 1, top - 1, cx + 9, top + 15, HABITO_SOMBRA)
        l.elipse(cx - 7, top - 1, cx + 3, top + 4, HABITO_LUZ)
        if direccion == 0:
            l.elipse(cx - 6, top + 3, cx + 6, top + 15, PIEL_P)
            l.elipse(cx + 1, top + 4, cx + 6, top + 15, PIEL_P_SOMBRA)
            l.rect(cx - 6, top + 3, cx + 6, top + 5, HABITO_SOMBRA)  # sombra de la capucha
            l.rect(cx - 3, top + 8, cx - 2, top + 9, OJO_P)
            l.rect(cx + 2, top + 8, cx + 3, top + 9, OJO_P)
            l.poly([(cx - 5, top + 11), (cx + 5, top + 11), (cx + 3, top + 16), (cx - 3, top + 16)], BARBA)
            l.linea([(cx - 1, top + 12), (cx + 1, top + 12)], c("#2a1f1a"))
            if cuchillo:  # cejas fruncidas
                l.linea([(cx - 4, top + 6), (cx - 2, top + 7)], OJO_P)
                l.linea([(cx + 4, top + 6), (cx + 2, top + 7)], OJO_P)
        else:
            l.linea([(cx, top), (cx, top + 13)], HABITO_SOMBRA)
    else:
        l.poly([(cx - 6, top + 13), (cx + 6, top + 13), (cx + 8 + paso, hem + 1), (cx - 8 + paso, hem + 1)], HABITO)
        l.poly([(cx - 6, top + 13), (cx - 1, top + 13), (cx - 3 + paso, hem + 1), (cx - 8 + paso, hem + 1)], HABITO_SOMBRA)
        l.linea([(cx - 6, top + 24), (cx + 6, top + 24)], CUERDA)
        l.rect(cx - 9, top + 16, cx - 5, top + 24, MORRAL)
        if cuchillo:
            alto = 4 if frame == 6 else 0
            ex = estocada  # la punta no debe salir de la celda
            l.poly([(cx + 1, top + 15), (cx + 4, top + 14), (cx + 11 + ex, top + 17 - alto), (cx + 9 + ex, top + 20 - alto)], HABITO_LUZ)
            l.rect(cx + 10 + ex, top + 16 - alto, cx + 12 + ex, top + 19 - alto, PIEL_P)
            l.poly([(cx + 12 + ex, top + 16 - alto), (cx + 12 + ex, top + 18 - alto), (cx + 20 + ex, top + 17 - alto)], ACERO)
        else:
            l.poly([(cx + 1, top + 14), (cx + 4, top + 14), (cx + 3, top + 25), (cx, top + 25)], HABITO_LUZ)
            l.rect(cx, top + 25, cx + 3, top + 27, PIEL_P)
        l.elipse(cx - 7, top - 2, cx + 8, top + 15, HABITO)
        l.elipse(cx - 7, top - 1, cx - 1, top + 15, HABITO_SOMBRA)
        l.elipse(cx + 1, top + 4, cx + 8, top + 14, PIEL_P)
        l.rect(cx + 1, top + 4, cx + 8, top + 5, HABITO_SOMBRA)
        l.rect(cx + 5, top + 8, cx + 6, top + 9, OJO_P)
        l.poly([(cx + 2, top + 11), (cx + 8, top + 11), (cx + 6, top + 16), (cx + 2, top + 15)], BARBA)
    return l.contorno()


# --------------------------------------------------------------------------
# SEGADOR DE HILOS — Piso III: cazador delgado y veloz. Piel de tendón seco,
# sin ojos, una costura vertical por boca y haces de hilo rojo en los brazos.
# --------------------------------------------------------------------------
TENDON = c("#8d8173")
TENDON_SOMBRA = c("#5f554c")
TENDON_LUZ = c("#b4a796")
HILO = c("#b3262f")
HILO_VIVO = c("#ff4a4f")
CARNE = c("#3a2326")
COSTURA = c("#1c0f12")


def segador(direccion: int, frame: int) -> Image.Image:
    l = Lienzo()
    correr = 2 <= frame <= 5
    paso = [0, 1, 0, -1][(frame - 2) % 4] if correr else 0
    resp = 0 if correr or frame >= 6 else frame % 2
    tensa = frame == 6
    enganchado = frame == 7
    cx = 24
    incl = 2 if (correr or enganchado) else 0  # se inclina hacia delante al cazar
    hombro = 22 + resp + incl
    cadera = 42
    if direccion in (0, 1):
        # Piernas larguísimas, articuladas hacia atrás.
        for lado, fase in ((-1, paso), (1, -paso)):
            x = cx + lado * 4
            rodilla = cadera + 9
            fin = PIE - max(0, fase) * 2
            l.linea([(x, cadera), (x + lado * 2, rodilla), (x, fin)], TENDON if lado < 0 else TENDON_SOMBRA, 2)
            l.rect(x - 2, fin - 1, x + 2, fin, CARNE)
        # Torso estrecho de costillas marcadas.
        l.poly([(cx - 6, hombro), (cx + 6, hombro), (cx + 4, cadera), (cx - 4, cadera)], TENDON)
        l.poly([(cx + 1, hombro), (cx + 6, hombro), (cx + 4, cadera), (cx + 1, cadera)], TENDON_SOMBRA)
        if direccion == 0:
            for i in range(4):
                y = hombro + 4 + i * 4
                l.linea([(cx - 4, y), (cx - 1, y + 1)], TENDON_SOMBRA)
                l.linea([(cx + 1, y + 1), (cx + 3, y)], CARNE)
            l.linea([(cx, hombro + 2), (cx, cadera - 2)], HILO)
        else:
            # Espina dorsal saliente.
            for i in range(6):
                l.px(cx, hombro + 2 + i * 3, TENDON_LUZ)
        # Brazos: muy largos; tensan hacia atrás o se lanzan hacia delante.
        for lado in (-1, 1):
            x = cx + lado * 7
            if tensa:
                mano = (cx + lado * 16, hombro - 4)
            elif enganchado:
                mano = (cx + lado * 5, cadera + 12)
            else:
                mano = (cx + lado * 9 + paso * lado, cadera + 8)
            l.linea([(x, hombro + 1), mano], TENDON_LUZ if lado < 0 else TENDON, 2)
            l.linea([(x, hombro + 4), (mano[0], mano[1] + 1)], HILO)
            l.rect(mano[0] - 1, mano[1] - 1, mano[0] + 1, mano[1] + 1, CARNE)
            if not (tensa or enganchado):
                for k in (-1, 0, 1):  # garras
                    l.px(mano[0] + k, mano[1] + 2, COSTURA)
            if tensa or enganchado:
                # Hilos que salen de las muñecas.
                fin = (mano[0] + lado * 6, mano[1] - 8) if tensa else (mano[0], PIE)
                l.linea([mano, fin], HILO_VIVO)
        # Paño desgarrado en la cadera, con tiras colgando.
        l.rect(cx - 5, cadera - 3, cx + 5, cadera + 1, CARNE)
        for i, x in enumerate((cx - 4, cx - 1, cx + 2, cx + 4)):
            l.linea([(x, cadera + 1), (x + (i % 2), cadera + 4 + (i * 3) % 5)], CARNE)
        # Garfios de hueso en los hombros, con hilo enrollado.
        for lado in (-1, 1):
            base = cx + lado * 6
            l.poly([(base - lado, hombro), (base + lado * 2, hombro), (base + lado * 5, hombro - 7), (base + lado * 3, hombro - 6)], TENDON_LUZ)
            l.px(base + lado * 5, hombro - 8, HILO_VIVO if (tensa or enganchado) else HILO)
        # Cabeza alargada, sin ojos, con una costura por boca.
        cab = hombro - 13
        l.elipse(cx - 5, cab, cx + 5, cab + 14, TENDON)
        l.elipse(cx + 1, cab + 1, cx + 5, cab + 13, TENDON_SOMBRA)
        if direccion == 0:
            l.linea([(cx, cab + 4), (cx, cab + 12)], COSTURA)
            for y in (cab + 6, cab + 9):
                l.linea([(cx - 1, y), (cx + 1, y)], HILO)
            l.px(cx - 3, cab + 5, CARNE)
            l.px(cx + 3, cab + 5, CARNE)
            # Sangre seca que gotea de la costura hasta el pecho.
            l.linea([(cx - 1, cab + 13), (cx - 1, hombro + 6)], HILO)
            l.px(cx - 2, hombro + 7, HILO)
        else:
            l.linea([(cx - 3, cab + 3), (cx + 2, cab + 11)], HILO)
    else:
        # Perfil derecho: casi a cuatro patas cuando corre.
        for fase, col in ((paso, TENDON_SOMBRA), (-paso, TENDON)):
            x = cx - 2 + fase * 4
            l.linea([(cx - 1, cadera), (cx - 5 + fase, cadera + 9), (x, PIE)], col, 2)
            l.rect(x - 1, PIE - 1, x + 3, PIE, CARNE)
        l.poly([(cx - 4, hombro + 1), (cx + 5, hombro), (cx + 3, cadera), (cx - 3, cadera)], TENDON)
        l.poly([(cx - 4, hombro + 1), (cx - 1, hombro + 1), (cx - 1, cadera), (cx - 3, cadera)], TENDON_SOMBRA)
        for i in range(5):
            l.px(cx - 4, hombro + 3 + i * 3, TENDON_LUZ)
        l.rect(cx - 4, cadera - 3, cx + 4, cadera + 1, CARNE)
        l.linea([(cx - 3, cadera + 1), (cx - 4, cadera + 5)], CARNE)
        l.poly([(cx - 4, hombro + 1), (cx - 2, hombro), (cx - 6, hombro - 7), (cx - 7, hombro - 5)], TENDON_LUZ)
        l.px(cx - 7, hombro - 8, HILO_VIVO if (tensa or enganchado) else HILO)
        if tensa:
            mano = (cx - 10, hombro - 2)
        elif enganchado:
            mano = (cx + 18, hombro + 8)
        else:
            mano = (cx + 10 + paso * 2, cadera + 6)
        l.linea([(cx + 2, hombro + 2), mano], TENDON_LUZ, 2)
        l.linea([(cx + 2, hombro + 5), (mano[0], mano[1] + 1)], HILO)
        l.rect(mano[0] - 1, mano[1] - 1, mano[0] + 1, mano[1] + 1, CARNE)
        if tensa:
            l.linea([mano, (mano[0] - 6, mano[1] - 6)], HILO_VIVO)
        elif enganchado:
            l.linea([mano, (CW - 1, mano[1])], HILO_VIVO)
        cab = hombro - 12
        l.elipse(cx - 2, cab, cx + 9, cab + 11, TENDON)
        l.linea([(cx + 5, cab + 6), (cx + 9, cab + 7)], COSTURA)
        l.px(cx + 7, cab + 8, HILO)
        l.linea([(cx + 7, cab + 9), (cx + 6, hombro + 4)], HILO)
    return l.contorno()


DIBUJAR = {"testigo": testigo, "ghoul": ghoul, "hechicero": hechicero, "peregrino": peregrino, "segador": segador}


def hoja(nombre: str) -> Image.Image:
    columnas = FRAMES[nombre]
    sheet = Image.new("RGBA", (CW * columnas, CH * 4), (0, 0, 0, 0))
    for fila, direccion in enumerate((0, 1, 2, 2)):
        for col in range(columnas):
            celda = DIBUJAR[nombre](direccion, col)
            if fila == 3:
                celda = celda.transpose(Image.FLIP_LEFT_RIGHT)
            sheet.paste(celda, (col * CW, fila * CH))
    return sheet


def main() -> None:
    parser = argparse.ArgumentParser(description="Genera los sprites originales de las entidades.")
    parser.add_argument("--vista-previa", type=Path, help="Guarda una lámina ampliada x3 para revisar.")
    args = parser.parse_args()
    SALIDA.mkdir(parents=True, exist_ok=True)
    hojas = {}
    for nombre in FRAMES:
        hojas[nombre] = hoja(nombre)
        hojas[nombre].save(SALIDA / f"{nombre}.png", optimize=True)
        print(f"{nombre}.png: {hojas[nombre].width}x{hojas[nombre].height}")
    if args.vista_previa:
        ancho = max(h.width for h in hojas.values())
        alto = sum(h.height + 8 for h in hojas.values())
        lam = Image.new("RGBA", (ancho, alto), (38, 58, 48, 255))
        y = 0
        for h in hojas.values():
            lam.alpha_composite(h, (0, y))
            y += h.height + 8
        lam.resize((lam.width * 3, lam.height * 3), Image.NEAREST).save(args.vista_previa)


if __name__ == "__main__":
    main()
