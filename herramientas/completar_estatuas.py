#!/usr/bin/env python3
"""Completa las estatuas encadenadas (estatuaarquero1.png) de cada sala.

Al recortar los objetos de las composiciones originales, el poste oscuro que une
el capitel con el pedestal se perdía (se confundía con el suelo), y la estatua
parecía un capitel flotando sobre una figura. Este script pinta un fuste de
piedra entre el capitel y el pedestal, por detrás de la figura, tomando la
textura del fuste de la columna de esa misma sala (así conserva su tinte).

Solo toca los píxeles transparentes o del poste oscuro: la figura, las cadenas
y el pedestal quedan igual. Es idempotente: ejecutarlo dos veces no cambia nada.

Uso: python3 herramientas/completar_estatuas.py
"""
from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image

RAIZ = Path(__file__).resolve().parent.parent
OBJETOS = RAIZ / "assets" / "visual" / "objetos"
ANCHO_FUSTE = 8


def _filas(alpha: np.ndarray) -> np.ndarray:
    return (alpha > 0).sum(axis=1)


def completar(sala: Path) -> bool:
    ruta = sala / "estatuaarquero1.png"
    columna = sala / "columna1.png"
    if not ruta.exists() or not columna.exists():
        return False
    est = np.array(Image.open(ruta).convert("RGBA"))
    col = np.array(Image.open(columna).convert("RGBA"))
    h, w = est.shape[:2]
    cuenta = _filas(est[..., 3])
    # Capitel: primeras filas anchas. Pedestal: primera fila ancha de la mitad baja.
    fin_capitel = 0
    while fin_capitel < h and cuenta[fin_capitel] >= w * 0.4:
        fin_capitel += 1
    if fin_capitel == 0:
        while fin_capitel < h and cuenta[fin_capitel] == 0:
            fin_capitel += 1
        while fin_capitel < h and cuenta[fin_capitel] >= w * 0.4:
            fin_capitel += 1
    ini_pedestal = h // 2
    while ini_pedestal < h and cuenta[ini_pedestal] < w * 0.5:
        ini_pedestal += 1
    capitel = np.nonzero(est[:fin_capitel, :, 3].max(axis=0) > 0)[0]
    if capitel.size == 0 or ini_pedestal >= h:
        return False
    centro = int(round((capitel.min() + capitel.max()) / 2.0))
    x0 = centro - ANCHO_FUSTE // 2
    # Textura del fuste: el centro de la columna de la sala (filas de la mitad).
    ch, cw = col.shape[:2]
    cols_col = np.nonzero(col[ch // 2, :, 3] > 0)[0]
    c_centro = int(round((cols_col.min() + cols_col.max()) / 2.0))
    muestra = col[:, c_centro - ANCHO_FUSTE // 2:c_centro - ANCHO_FUSTE // 2 + ANCHO_FUSTE]
    fila_ini = ch // 3
    alto_muestra = max(1, ch // 3)
    cambiado = False
    for y in range(fin_capitel, ini_pedestal):
        fuente = muestra[fila_ini + (y - fin_capitel) % alto_muestra]
        for i in range(ANCHO_FUSTE):
            x = x0 + i
            if x < 0 or x >= w or fuente[i, 3] == 0:
                continue
            p = est[y, x]
            oscuro = int(p[0]) + int(p[1]) + int(p[2]) < 90 and abs(int(p[1]) - int(p[0])) < 14
            if p[3] == 0 or oscuro:
                if not np.array_equal(p, fuente[i]):
                    est[y, x] = fuente[i]
                    cambiado = True
    if cambiado:
        Image.fromarray(est).save(ruta)
    return cambiado


def main() -> None:
    for sala in sorted(OBJETOS.glob("sala_*")):
        print(sala.name, "completada" if completar(sala) else "sin cambios")


if __name__ == "__main__":
    main()
