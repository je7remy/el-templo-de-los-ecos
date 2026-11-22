#!/usr/bin/env python3
"""Más alimañas del templo (arte original, pixel art), mismo formato que la rata.

  assets/visual/enemies/murcielago.png  4 x 2 celdas de 24 x 16 (fila 0: aleteo;
                                        fila 1: caer y quedar en el suelo)
  assets/visual/enemies/arana.png       4 x 2 celdas de 24 x 16 (fila 0: andar;
                                        fila 1: encogerse al morir)

No toca alimana.png (la rata): cada bicho tiene su hoja.

Uso:  python3 herramientas/generar_bichos.py
"""
from pathlib import Path
from PIL import Image, ImageDraw

RAIZ = Path(__file__).resolve().parents[1]
CW, CH = 24, 16


def c(h: str) -> tuple:
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4)) + (255,)


CONTORNO = c("#100a0e")
OJO, SANGRE = c("#ff3b3b"), c("#8e1f2c")
# Murciélago: piel de membrana violácea, cuerpo pardo.
ALA, ALA_SOMBRA, ALA_LUZ = c("#4a3550"), c("#2c1f33"), c("#6d5177")
CUERPO, CUERPO_LUZ = c("#3e302c"), c("#62504a")
# Araña: quitina verde negruzca, dibujo de hueso en el lomo.
QUITINA, QUITINA_SOMBRA, QUITINA_LUZ = c("#2f3a2c"), c("#1b2219"), c("#4d5c45")
HUESO, PATA = c("#cfc3a8"), c("#56634c")


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


def murcielago(frame: int, muerto: int = -1) -> Image.Image:
    im = Image.new("RGBA", (CW, CH), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    if muerto >= 0:
        # Cae plegado y queda tendido con las alas abiertas en el suelo.
        y = 6 + muerto * 2
        if muerto < 2:
            d.polygon([(8, y), (12, y - 3), (16, y), (12, y + 3)], fill=ALA_SOMBRA)
            d.ellipse([10, y - 2, 14, y + 2], fill=CUERPO)
        else:
            d.polygon([(2, 13), (8, 10), (12, 12), (16, 10), (22, 13), (12, 14)], fill=ALA_SOMBRA)
            d.ellipse([10, 10, 14, 14], fill=CUERPO)
            d.line([(4, 13), (8, 11)], fill=ALA)
            d.line([(20, 13), (16, 11)], fill=ALA)
            if muerto == 3:
                d.ellipse([7, 14, 17, 15], fill=SANGRE)
        return contorno(im)
    # Aleteo: alas arriba, medio, abajo, medio.
    alto = [-4, 0, 4, 0][frame % 4]
    cy = 8 + (1 if alto > 0 else 0)
    for lado in (-1, 1):
        x0 = 12
        punta = (12 + lado * 11, cy + alto)
        codo = (12 + lado * 6, cy - 2 + alto // 2)
        d.polygon([(x0, cy - 1), codo, punta, (12 + lado * 8, cy + 2 + alto // 2), (12 + lado * 4, cy + 3)], fill=ALA)
        d.line([(x0, cy - 1), codo, punta], fill=ALA_LUZ)
        d.line([(12 + lado * 4, cy + 3), (12 + lado * 8, cy + 2 + alto // 2)], fill=ALA_SOMBRA)
    d.ellipse([9, cy - 3, 15, cy + 4], fill=CUERPO)
    d.line([(11, cy - 2), (13, cy - 2)], fill=CUERPO_LUZ)
    d.point((10, cy - 5), fill=CUERPO)  # orejas
    d.point((14, cy - 5), fill=CUERPO)
    d.point((13, cy - 1), fill=OJO)
    d.point((11, cy - 1), fill=OJO)
    return contorno(im)


def arana(frame: int, muerta: int = -1) -> Image.Image:
    im = Image.new("RGBA", (CW, CH), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    if muerta >= 0:
        # Patas que se recogen sobre el cuerpo, panza arriba.
        k = min(muerta, 3)
        d.ellipse([6, 7 + k // 2, 16, 13], fill=QUITINA_SOMBRA)
        for i, x in enumerate((7, 9, 12, 14)):
            alto = 4 - k
            d.line([(x, 8 + k // 2), (x + (1 if i % 2 else -1), 8 + k // 2 - alto)], fill=PATA)
        if k >= 2:
            d.ellipse([4, 13, 18, 15], fill=c("#3d6b2a"))  # sangre verdosa
        return contorno(im)
    paso = [0, 1, 0, -1][frame % 4]
    # Ocho patas largas y articuladas (cuatro por lado, alternando el paso).
    for i, x in enumerate((8, 10, 13, 15)):
        f = paso if i % 2 == 0 else -paso
        k = (-3, -1, 1, 3)[i]  # las de atrás hacia atrás, las de delante hacia delante
        d.line([(x, 8), (x + k // 2 + f, 4), (x + k + f, 2)], fill=PATA)
        d.line([(x, 11), (x + k // 2 - f, 13), (x + k - f, 15)], fill=PATA)
    # Abdomen con reloj de arena pálido y cefalotórax delante.
    d.ellipse([3, 6, 12, 13], fill=QUITINA)
    d.ellipse([3, 10, 12, 13], fill=QUITINA_SOMBRA)
    d.line([(5, 7), (9, 7)], fill=QUITINA_LUZ)
    d.polygon([(6, 8), (9, 8), (7, 10)], fill=HUESO)
    d.polygon([(7, 10), (6, 12), (9, 12)], fill=HUESO)
    d.ellipse([12, 7, 17, 12], fill=QUITINA)
    d.line([(13, 8), (15, 8)], fill=QUITINA_LUZ)
    d.point((16, 9), fill=OJO)
    d.point((15, 9), fill=OJO)
    d.point((18, 10), fill=SANGRE)  # quelíceros
    return contorno(im)


def hoja(fn) -> Image.Image:
    s = Image.new("RGBA", (CW * 4, CH * 2), (0, 0, 0, 0))
    for f in range(4):
        s.paste(fn(f), (f * CW, 0))
        s.paste(fn(0, f), (f * CW, CH))
    return s


if __name__ == "__main__":
    for nombre, fn in (("murcielago", murcielago), ("arana", arana)):
        h = hoja(fn)
        h.save(RAIZ / f"assets/visual/enemies/{nombre}.png", optimize=True)
        print(f"{nombre}.png", h.size)
