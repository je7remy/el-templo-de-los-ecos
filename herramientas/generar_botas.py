"""Capa de botas para las hojas del héroe.

Las botas se dibujaban con rectángulos fijos en los pies, así que al caminar
no seguían las piernas. Este script crea, para cada hoja del héroe, una hoja
del mismo tamaño (40 × 56 por celda, misma rejilla) con solo las botas: los
zapatos de cada cuadro pintados de cuero y una caña que sube por la pierna.
El juego la dibuja encima con la misma región de la hoja, así que las botas
siguen la animación en las cuatro direcciones.

Uso: python3 herramientas/generar_botas.py
Lee  assets/visual/protagonist_sheet.png y protagonist_sheet_f.png
Escribe assets/visual/protagonist_botas.png y protagonist_botas_f.png
"""
import os
from PIL import Image

RAIZ = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
CW, CH = 40, 56
CUERO = (110, 70, 48, 255)        # GEAR_LEATHER del juego
CUERO_CLARO = (150, 98, 64, 255)  # brillo de la puntera y del borde de la caña
CUERO_OSCURO = (69, 41, 27, 255)  # GEAR_LEATHER_DARK
CONTORNO = (34, 20, 14, 255)
CANA = 3                          # filas de caña por encima del zapato


def luz(p):
    return (p[0] + p[1] + p[2]) // 3


def celda(src, dst, cx, cy):
    ox, oy = cx * CW, cy * CH
    opaco = lambda x, y: 0 <= x < CW and 0 <= y < CH and src.getpixel((ox + x, oy + y))[3] >= 128
    filas = [y for y in range(CH) if any(opaco(x, y) for x in range(CW))]
    if not filas:
        return
    abajo = max(filas)
    # El zapato: las filas oscuras seguidas que acaban en la última fila opaca.
    arriba = abajo
    while arriba - 1 > abajo - 6:
        y = arriba - 1
        xs = [x for x in range(CW) if opaco(x, y)]
        if not xs or sum(1 for x in xs if luz(src.getpixel((ox + x, oy + y))) < 40) < len(xs) * 0.8:
            break
        arriba = y
    if abajo - arriba < 2:  # celda sin pies a la vista (p. ej., tumbado)
        return
    cols = {x for x in range(CW) if any(opaco(x, y) for y in range(arriba, abajo + 1))}
    pinta = lambda x, y, c: dst.putpixel((ox + x, oy + y), c)
    for y in range(arriba, abajo + 1):
        for x in range(CW):
            if not opaco(x, y):
                continue
            borde = not (opaco(x - 1, y) and opaco(x + 1, y) and opaco(x, y + 1))
            if borde:
                pinta(x, y, CONTORNO)
            elif y == arriba:
                pinta(x, y, CUERO_CLARO)
            elif y == abajo - 1:
                pinta(x, y, CUERO_OSCURO)
            else:
                pinta(x, y, CUERO)
    # La caña: sube por la pierna, solo sobre las columnas del zapato.
    for y in range(arriba - CANA, arriba):
        for x in cols:
            if not opaco(x, y):
                continue
            p = src.getpixel((ox + x, oy + y))
            if luz(p) < 40:
                pinta(x, y, CONTORNO)  # contorno de la pierna
            elif y == arriba - CANA:
                pinta(x, y, CUERO_CLARO)  # borde superior de la caña
            else:
                pinta(x, y, CUERO_OSCURO if y == arriba - 1 else CUERO)


def generar(nombre, salida):
    src = Image.open(os.path.join(RAIZ, "assets/visual", nombre)).convert("RGBA")
    dst = Image.new("RGBA", src.size, (0, 0, 0, 0))
    for cy in range(src.height // CH):
        for cx in range(src.width // CW):
            if cx == 8:  # cuadro de muerte: sin equipo
                continue
            celda(src, dst, cx, cy)
    dst.save(os.path.join(RAIZ, "assets/visual", salida))
    print(salida, dst.size)


if __name__ == "__main__":
    generar("protagonist_sheet.png", "protagonist_botas.png")
    generar("protagonist_sheet_f.png", "protagonist_botas_f.png")
