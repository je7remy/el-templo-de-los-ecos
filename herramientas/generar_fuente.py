#!/usr/bin/env python3
"""Tipografía de texto del juego: Jersey 15, algo más grande.

  assets/fonts/Jersey15-Templo.ttf

Jersey 15 (The Soft Type Project Authors, SIL OFL 1.1) es una pixel art de
trazo grueso, con mayúsculas, minúsculas, tildes y cifras muy claras. Se
reescala dentro del propio archivo (unidades por eme), así que cada texto del
juego sale un 10 % más alto que con la tipografía anterior sin cambiar los
tamaños en el código. El derivado lleva otro nombre de familia, como pide la
licencia (assets/fonts/OFL_Jersey15.txt).

Uso:  python3 herramientas/generar_fuente.py /ruta/Jersey15-Regular.ttf
      (github.com/google/fonts, ofl/jersey15). Requiere fontTools.
"""
import sys
from pathlib import Path

from fontTools.ttLib import TTFont

RAIZ = Path(__file__).resolve().parents[1]
# Altura de mayúscula buscada, en emes: la anterior (0,70) + 10 %.
MAYUSCULA = 0.77
# Interlineado: lo justo para tildes arriba y descendentes abajo.
ASCENSO, DESCENSO = 1000, -280


def main(origen: Path) -> None:
    f = TTFont(origen)
    cap = f["OS/2"].sCapHeight
    upm = round(cap / MAYUSCULA)
    f["head"].unitsPerEm = upm
    f["hhea"].ascent, f["hhea"].descent, f["hhea"].lineGap = ASCENSO, DESCENSO, 0
    os2 = f["OS/2"]
    os2.sTypoAscender, os2.sTypoDescender, os2.sTypoLineGap = ASCENSO, DESCENSO, 0
    os2.usWinAscent, os2.usWinDescent = ASCENSO, -DESCENSO
    for rec in f["name"].names:
        if rec.nameID in (1, 4, 16, 21):
            rec.string = "Jersey Templo"
        elif rec.nameID == 6:
            rec.string = "JerseyTemplo"
    destino = RAIZ / "assets/fonts/Jersey15-Templo.ttf"
    f.save(destino)
    print(destino.relative_to(RAIZ), "unidades por eme:", upm)


if __name__ == "__main__":
    main(Path(sys.argv[1]) if len(sys.argv) > 1 else Path("Jersey15-Regular.ttf"))
