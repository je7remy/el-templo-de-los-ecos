#!/usr/bin/env python3
"""Genera la hoja ORIGINAL del protagonista en vista cenital 3/4.

Misma disposición que usa scripts/main.gd (no cambia el código de animación):
  assets/visual/protagonist_sheet.png  360 x 224, celdas de 40 x 56, pies en y = 50
  Filas: 0 frente, 1 espalda, 2 derecha, 3 izquierda (espejo).
  Columnas: 0-1 reposo (respira), 2-5 caminar, 6 interactuar, 7 daño, 8 muerte.

Claves de la vista desde arriba: la coronilla y los hombros ocupan más que la
cara y las piernas (escorzo), las superficies superiores reciben más luz y
el personaje proyecta su sombra (la dibuja el juego).
Paleta: docs/diseno_personaje.md.

Uso:  python3 herramientas/generar_protagonista.py [--vista-previa RUTA.png]
"""
from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageDraw

RAIZ = Path(__file__).resolve().parent.parent
SALIDA = RAIZ / "assets" / "visual" / "protagonist_sheet.png"
CW, CH = 40, 56
PIE = 50


def c(h: str) -> tuple:
    h = h.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), 255)


CONTORNO = c("#13181E")
PELO, PELO_LUZ, PELO_BRILLO = c("#1F1F24"), c("#2E3340"), c("#454B5C")
ABRIGO, ABRIGO_LUZ, ABRIGO_SOMBRA, ABRIGO_COSTURA = c("#395359"), c("#58706F"), c("#253941"), c("#2C434A")
GRANATE, GRANATE_LUZ, GRANATE_SOMBRA = c("#843844"), c("#BA575B"), c("#5E2630")
PIEL, PIEL_SOMBRA, PIEL_LUZ = c("#C59C81"), c("#906A57"), c("#E1B592")
PANTALON, PANTALON_LUZ = c("#29303D"), c("#36404F")
CALZADO = c("#1B1D23")
LATON, LATON_LUZ = c("#B5A986"), c("#DCD2AE")
CUERO, CUERO_LUZ = c("#433A3B"), c("#5E5051")
OJO, OJO_BRILLO = c("#1A1418"), c("#F4EBDD")


class L:
    def __init__(self) -> None:
        self.img = Image.new("RGBA", (CW, CH), (0, 0, 0, 0))
        self.d = ImageDraw.Draw(self.img)

    def r(self, x0, y0, x1, y1, col):
        self.d.rectangle([x0, y0, x1, y1], fill=col)

    def e(self, x0, y0, x1, y1, col):
        self.d.ellipse([x0, y0, x1, y1], fill=col)

    def p(self, pts, col):
        self.d.polygon([(round(x), round(y)) for x, y in pts], fill=col)

    def px(self, x, y, col):
        if 0 <= x < CW and 0 <= y < CH:
            self.img.putpixel((int(x), int(y)), col)

    def ln(self, pts, col):
        self.d.line([(round(x), round(y)) for x, y in pts], fill=col, width=1)

    def contorno(self) -> Image.Image:
        a = self.img.load()
        out = self.img.copy()
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


def piernas(l: L, cx: int, paso: int, lateral: bool) -> None:
    """Piernas cortas (escorzo). paso: -1/0/1 alterna."""
    if lateral:
        for fase, col in ((paso, PANTALON), (-paso, PANTALON_LUZ)):
            x = cx - 2 + fase * 3
            l.r(x, 40, x + 4, 47, col)
            l.r(x - 1 + max(fase, 0), 47, x + 5, 49, CALZADO)
        return
    for lado, fase in ((-1, paso), (1, -paso)):
        x = cx + (-6 if lado < 0 else 1)
        alto = 47 - max(fase, 0) * 2
        l.r(x, 40, x + 4, alto, PANTALON if lado < 0 else PANTALON_LUZ)
        l.r(x - 1, alto, x + 5, alto + 2, CALZADO)


def cuerpo_frente(l: L, cx: int, resp: int, brazo_izq: int, brazo_der: int, espalda: bool) -> None:
    top = 23 + resp
    # Abrigo: trapecio, hombros anchos iluminados desde arriba.
    l.p([(cx - 10, top + 2), (cx + 10, top + 2), (cx + 9, 42), (cx - 9, 42)], ABRIGO)
    l.p([(cx + 3, top + 2), (cx + 10, top + 2), (cx + 9, 42), (cx + 4, 42)], ABRIGO_SOMBRA)
    l.r(cx - 10, top + 1, cx + 10, top + 4, ABRIGO_LUZ)  # hombros vistos desde arriba
    l.ln([(cx, top + 5), (cx, 41)], ABRIGO_COSTURA)
    l.r(cx - 9, 40, cx + 9, 42, ABRIGO_SOMBRA)  # bajo del abrigo
    if not espalda:
        for y in (top + 8, top + 12):
            l.px(cx - 1, y, LATON)  # botones
        # Tirante de latón en diagonal hacia la bolsa.
        l.ln([(cx + 7, top + 3), (cx - 5, top + 15)], LATON)
    else:
        l.ln([(cx - 7, top + 3), (cx + 5, top + 15)], CUERO_LUZ)
    # Bolsa de cuero en la cadera izquierda.
    bx = cx - 11 if not espalda else cx + 6
    l.r(bx, top + 13, bx + 5, top + 18, CUERO)
    l.r(bx, top + 13, bx + 5, top + 14, CUERO_LUZ)
    l.px(bx + 2 + (0 if not espalda else 1), top + 16, LATON_LUZ)
    # Brazos con mano.
    for lado, swing in ((-1, brazo_izq), (1, brazo_der)):
        x = cx - 13 if lado < 0 else cx + 10
        y1 = top + 14 + swing
        l.r(x, top + 3, x + 3, y1, ABRIGO_LUZ if lado < 0 else ABRIGO)
        l.r(x, y1, x + 3, y1 + 2, PIEL if not espalda else PIEL_SOMBRA)


def pañuelo(l: L, cx: int, resp: int, cola: int, espalda: bool) -> None:
    top = 20 + resp
    l.r(cx - 7, top, cx + 7, top + 4, GRANATE)
    l.r(cx - 7, top, cx + 7, top, GRANATE_LUZ)
    l.r(cx + 3, top + 2, cx + 7, top + 4, GRANATE_SOMBRA)
    if espalda:
        # Nudo y dos colas que ondean.
        l.r(cx - 2, top + 2, cx + 1, top + 5, GRANATE_LUZ)
        l.p([(cx - 2, top + 5), (cx + 1, top + 5), (cx + 2 + cola, top + 12), (cx - 1 + cola, top + 12)], GRANATE)
    else:
        l.p([(cx - 6, top + 4), (cx - 3, top + 4), (cx - 4 + cola, top + 11), (cx - 7 + cola, top + 11)], GRANATE)
        l.px(cx - 5 + cola, top + 10, GRANATE_LUZ)


def cabeza_frente(l: L, cx: int, resp: int, ojos: str) -> None:
    top = 3 + resp
    # Cráneo visto desde arriba: mucha coronilla.
    l.e(cx - 9, top, cx + 9, top + 18, PELO)
    l.r(cx - 7, top + 10, cx + 7, top + 18, PIEL)              # cara (mitad inferior)
    l.e(cx - 7, top + 13, cx + 7, top + 21, PIEL)              # barbilla
    l.r(cx + 3, top + 11, cx + 7, top + 19, PIEL_SOMBRA)
    l.r(cx - 9, top + 9, cx - 7, top + 13, PELO)               # patillas
    l.r(cx + 7, top + 9, cx + 9, top + 13, PELO)
    # Flequillo y brillo de la coronilla.
    l.p([(cx - 8, top + 8), (cx + 8, top + 8), (cx + 6, top + 12), (cx + 1, top + 10), (cx - 3, top + 12), (cx - 8, top + 11)], PELO)
    l.e(cx - 5, top + 2, cx + 3, top + 6, PELO_LUZ)
    l.r(cx - 3, top + 3, cx, top + 3, PELO_BRILLO)
    # Mechones: raya, puntas irregulares del flequillo y textura.
    l.ln([(cx + 2, top + 1), (cx + 1, top + 7)], CONTORNO)
    for x, y in ((cx - 6, top + 6), (cx - 2, top + 7), (cx + 4, top + 6)):
        l.ln([(x, y), (x + 1, y + 3)], PELO_LUZ)
    for x in (cx - 6, cx - 2, cx + 3):
        l.px(x, top + 12, PELO)
        l.px(x + 1, top + 13, PELO)
    # Orejas.
    l.r(cx - 9, top + 13, cx - 8, top + 15, PIEL_SOMBRA)
    l.r(cx + 8, top + 13, cx + 9, top + 15, PIEL_SOMBRA)
    # Ojos.
    if ojos == "abiertos":
        for x in (cx - 4, cx + 2):
            l.r(x, top + 14, x + 1, top + 15, OJO)
            l.px(x, top + 14, OJO_BRILLO)
    else:
        for x in (cx - 4, cx + 2):
            l.r(x, top + 15, x + 1, top + 15, OJO)
    l.px(cx - 1, top + 17, PIEL_SOMBRA)  # nariz
    l.r(cx - 2, top + 19, cx, top + 19, PIEL_SOMBRA)  # boca


def cabeza_espalda(l: L, cx: int, resp: int) -> None:
    top = 3 + resp
    l.e(cx - 9, top, cx + 9, top + 19, PELO)
    l.e(cx - 6, top + 2, cx + 4, top + 8, PELO_LUZ)
    l.r(cx - 3, top + 3, cx + 1, top + 3, PELO_BRILLO)
    l.ln([(cx - 4, top + 12), (cx - 2, top + 17)], PELO_LUZ)
    l.ln([(cx + 3, top + 12), (cx + 2, top + 17)], PELO_LUZ)
    l.ln([(cx, top + 1), (cx - 1, top + 9)], CONTORNO)  # raya
    for x in (cx - 5, cx - 1, cx + 4):
        l.ln([(x, top + 8), (x + 1, top + 12)], PELO_LUZ)
    # Nuca con puntas desiguales.
    for x in (cx - 6, cx - 3, cx + 1, cx + 5):
        l.r(x, top + 18, x + 1, top + 19, PELO)
    l.r(cx - 9, top + 13, cx - 8, top + 15, PIEL_SOMBRA)
    l.r(cx + 8, top + 13, cx + 9, top + 15, PIEL_SOMBRA)


def lateral(l: L, f: int, cx: int, resp: int, paso: int, brazo: int, ojos: str, cola: int, interactua: bool) -> None:
    piernas(l, cx, paso, True)
    top = 23 + resp
    # Bolsa a la espalda (izquierda en perfil derecho).
    l.r(cx - 9, top + 9, cx - 5, top + 15, CUERO)
    l.r(cx - 9, top + 9, cx - 5, top + 10, CUERO_LUZ)
    l.p([(cx - 6, top + 2), (cx + 6, top + 2), (cx + 6, 42), (cx - 6, 42)], ABRIGO)
    l.p([(cx - 6, top + 2), (cx - 1, top + 2), (cx - 1, 42), (cx - 6, 42)], ABRIGO_SOMBRA)
    l.r(cx - 6, top + 1, cx + 6, top + 4, ABRIGO_LUZ)
    l.ln([(cx + 4, top + 3), (cx - 4, top + 12)], LATON)
    l.r(cx - 6, 40, cx + 6, 42, ABRIGO_SOMBRA)
    # Pañuelo y cola hacia atrás.
    t = 20 + resp
    l.r(cx - 5, t, cx + 5, t + 4, GRANATE)
    l.r(cx - 5, t, cx + 5, t, GRANATE_LUZ)
    l.p([(cx - 5, t + 1), (cx - 3, t + 3), (cx - 10 - cola, t + 7), (cx - 10 - cola, t + 4)], GRANATE)
    # Brazo delantero.
    if interactua:
        l.r(cx - 1, top + 4, cx + 11, top + 7, ABRIGO_LUZ)
        l.r(cx + 11, top + 4, cx + 13, top + 7, PIEL)
    else:
        l.p([(cx - 2, top + 3), (cx + 2, top + 3), (cx + 2 + brazo, top + 15), (cx - 2 + brazo, top + 15)], ABRIGO_LUZ)
        l.r(cx - 2 + brazo, top + 15, cx + 2 + brazo, top + 17, PIEL)
    # Cabeza de perfil, mirando a la derecha.
    hy = 3 + resp
    l.e(cx - 8, hy, cx + 8, hy + 18, PELO)
    l.p([(cx - 1, hy + 9), (cx + 8, hy + 9), (cx + 8, hy + 18), (cx + 2, hy + 21), (cx - 1, hy + 18)], PIEL)
    l.px(cx + 9, hy + 15, PIEL)  # nariz
    l.px(cx + 9, hy + 14, PIEL)
    l.r(cx - 1, hy + 13, cx, hy + 16, PIEL_SOMBRA)  # oreja
    l.p([(cx - 6, hy + 8), (cx + 8, hy + 8), (cx + 7, hy + 11), (cx + 3, hy + 10), (cx - 1, hy + 13), (cx - 6, hy + 14)], PELO)
    l.e(cx - 5, hy + 2, cx + 3, hy + 6, PELO_LUZ)
    l.r(cx - 2, hy + 3, cx + 1, hy + 3, PELO_BRILLO)
    for x, y in ((cx - 5, hy + 7), (cx - 1, hy + 6), (cx + 3, hy + 6)):
        l.ln([(x, y), (x - 1, y + 3)], PELO_LUZ)
    l.r(cx - 8, hy + 14, cx - 7, hy + 17, PELO)  # nuca
    if ojos == "abiertos":
        l.r(cx + 5, hy + 13, cx + 6, hy + 14, OJO)
        l.px(cx + 5, hy + 13, OJO_BRILLO)
    else:
        l.r(cx + 5, hy + 14, cx + 6, hy + 14, OJO)
    l.r(cx + 4, hy + 18, cx + 6, hy + 18, PIEL_SOMBRA)


def fotograma(direccion: int, col: int) -> Image.Image:
    l = L()
    cx = 20
    resp = 1 if col == 1 else 0
    paso = [0, 0, 1, 0, -1, 0, 0, 0, 0][col]
    caminar = 2 <= col <= 5
    cola = [0, 1, 1, 2, 1, 0, 0, 2, 0][col]
    ojos = "cerrados" if col == 7 else "abiertos"
    interactua = col == 6
    if direccion == 2:
        brazo = [0, 0, 2, 0, -2, 0, 0, -1, 0][col]
        lateral(l, col, cx, resp, paso, brazo, ojos, cola, interactua)
    else:
        espalda = direccion == 1
        swing = [0, 0, 2, 0, -2, 0, 0, 0, 0][col]
        piernas(l, cx, paso, False)
        bi, bd = swing, -swing
        if interactua:
            bd = -7
        if col == 7:
            bi, bd = -3, -3
        cuerpo_frente(l, cx, resp, bi, bd, espalda)
        pañuelo(l, cx, resp, cola if caminar else 0, espalda)
        if espalda:
            cabeza_espalda(l, cx, resp)
        else:
            cabeza_frente(l, cx, resp, ojos)
    img = l.contorno()
    if col == 7:
        # Daño: retroceso de un píxel y tinte rojizo.
        img = img.transform(img.size, Image.AFFINE, (1, 0, 1, 0, 1, 0))
        r, g, b, a = img.split()
        r = r.point(lambda v: min(255, int(v * 1.25 + 18)))
        img = Image.merge("RGBA", (r, g, b, a))
    return img


def muerte(direccion: int) -> Image.Image:
    base = fotograma(0 if direccion != 1 else 1, 7)
    # Tumbado: girar y apoyar sobre el suelo, con el pañuelo extendido.
    caido = base.rotate(90 if direccion != 3 else -90, expand=True)
    lienzo = Image.new("RGBA", (CW, CH), (0, 0, 0, 0))
    w, h = caido.size
    caido = caido.crop((max(0, (w - CW) // 2), 0, max(0, (w - CW) // 2) + min(CW, w), h))
    lienzo.alpha_composite(caido, (0, PIE - caido.size[1] + 2) if caido.size[1] <= CH else (0, 0))
    return lienzo


def hoja() -> Image.Image:
    sheet = Image.new("RGBA", (CW * 9, CH * 4), (0, 0, 0, 0))
    for fila, direccion in enumerate((0, 1, 2, 2)):
        for col in range(9):
            celda = muerte(fila) if col == 8 else fotograma(direccion, col)
            if fila == 3:
                celda = celda.transpose(Image.FLIP_LEFT_RIGHT)
            sheet.paste(celda, (col * CW, fila * CH))
    return sheet


def main() -> None:
    parser = argparse.ArgumentParser(description="Genera la hoja del protagonista.")
    parser.add_argument("--vista-previa", type=Path)
    args = parser.parse_args()
    s = hoja()
    s.save(SALIDA, optimize=True)
    print(f"{SALIDA.relative_to(RAIZ)}: {s.width}x{s.height}")
    if args.vista_previa:
        fondo = Image.new("RGBA", s.size, (38, 58, 48, 255))
        fondo.alpha_composite(s)
        fondo.resize((s.width * 3, s.height * 3), Image.NEAREST).save(args.vista_previa)


if __name__ == "__main__":
    main()
