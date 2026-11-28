"""Cuadros de caminar de frente y de espaldas para las hojas del héroe.

En la hoja original, los cuadros 2–5 de frente (fila 0) y de espaldas (fila 1)
apenas mueven los pies, así que al andar hacia arriba o hacia abajo el
personaje parece deslizarse. Este script añade cuatro columnas (9–12) a cada
hoja, sin tocar las que ya hay:

  9  pie izquierdo levantado, cuerpo 1 px abajo (apoyo)
  10 los dos pies en el suelo, cuerpo 1 px arriba (paso)
  11 pie derecho levantado, cuerpo 1 px abajo
  12 como el 10

Para las filas de lado (2 y 3) copia sus cuadros 2–5 tal cual, para que la
rejilla siga completa. Después hay que volver a generar la capa de botas
(herramientas/generar_botas.py), que ya recorre las columnas nuevas.

Uso: python3 herramientas/generar_pasos.py   (idempotente: si la hoja ya tiene
13 columnas, rehace solo las nuevas a partir del cuadro 0).
"""
import os
from PIL import Image

RAIZ = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
CW, CH = 40, 56
COLS_BASE = 9
ZAPATO = (47, 50)   # filas del zapato (igual en las dos hojas)
CENTRO = 20         # columna que separa el pie izquierdo del derecho


def cuadro(hoja, col, fila):
    return hoja.crop((col * CW, fila * CH, col * CW + CW, fila * CH + CH))


def opaco(img, x, y):
    return 0 <= x < CW and 0 <= y < CH and img.getpixel((x, y))[3] >= 128


def inicio_piernas(base):
    """Primera fila por debajo del abrigo: donde el contorno se estrecha a las piernas."""
    for y in range(38, ZAPATO[0]):
        xs = [x for x in range(CW) if opaco(base, x, y)]
        if xs and max(xs) - min(xs) <= 14:
            return y
    return ZAPATO[0]


def cuerpo_abajo(img, hasta):
    """Baja 1 px todo lo que está por encima de «hasta» (el peso cae en el apoyo)."""
    out = img.copy()
    arriba = img.crop((0, 0, CW, hasta))
    out.paste(Image.new("RGBA", (CW, hasta), (0, 0, 0, 0)), (0, 0))
    out.paste(arriba, (0, 1), arriba)
    # La franja de arriba de las piernas queda tapada por el abrigo bajado.
    return out


def cuerpo_arriba(img, hasta):
    out = img.copy()
    arriba = img.crop((0, 1, CW, hasta))
    limpio = Image.new("RGBA", (CW, hasta), (0, 0, 0, 0))
    out.paste(limpio, (0, 0))
    out.paste(arriba, (0, 0), arriba)
    # La fila que queda libre encima de las piernas: se estiran las piernas.
    for x in range(CW):
        p = img.getpixel((x, hasta))
        if p[3] >= 128 and out.getpixel((x, hasta - 1))[3] < 128:
            out.putpixel((x, hasta - 1), p)
    return out


def levantar_pie(img, izquierdo, piernas):
    """El pie de un lado sube 2 px: la pierna se acorta y el zapato asoma más arriba."""
    out = img.copy()
    xs = range(0, CENTRO) if izquierdo else range(CENTRO, CW)
    zapato = {}
    for y in range(ZAPATO[0], ZAPATO[1] + 1):
        for x in xs:
            if opaco(img, x, y):
                zapato[(x, y)] = img.getpixel((x, y))
    # Borra la pierna y el zapato de ese lado (por debajo del abrigo).
    for y in range(piernas, ZAPATO[1] + 1):
        for x in xs:
            out.putpixel((x, y), (0, 0, 0, 0))
    # Pierna: las filas de pierna que caben por encima del zapato subido.
    for y in range(piernas, ZAPATO[0] - 2):
        for x in xs:
            if opaco(img, x, y):
                out.putpixel((x, y), img.getpixel((x, y)))
    for (x, y), p in zapato.items():
        out.putpixel((x, y - 2), p)
    return out


def ampliar(nombre):
    ruta = os.path.join(RAIZ, "assets/visual", nombre)
    hoja = Image.open(ruta).convert("RGBA")
    filas = hoja.height // CH
    nueva = Image.new("RGBA", ((COLS_BASE + 4) * CW, hoja.height), (0, 0, 0, 0))
    nueva.paste(hoja.crop((0, 0, COLS_BASE * CW, hoja.height)), (0, 0))
    for fila in range(filas):
        if fila in (0, 1):
            base = cuadro(hoja, 0, fila)
            piernas = inicio_piernas(base)
            apoyo_i = cuerpo_abajo(levantar_pie(base, True, piernas), piernas)
            paso = cuerpo_arriba(base, piernas)
            apoyo_d = cuerpo_abajo(levantar_pie(base, False, piernas), piernas)
            cuadros = [apoyo_i, paso, apoyo_d, paso]
        else:
            cuadros = [cuadro(hoja, c, fila) for c in range(2, 6)]
        for i, img in enumerate(cuadros):
            nueva.paste(img, ((COLS_BASE + i) * CW, fila * CH))
    nueva.save(ruta)
    print(nombre, hoja.size, "→", nueva.size)


if __name__ == "__main__":
    ampliar("protagonist_sheet.png")
    ampliar("protagonist_sheet_f.png")
