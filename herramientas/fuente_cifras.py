#!/usr/bin/env python3
"""Cifras legibles: la tipografía del juego sin sus números, y una fuente
solo de números que la completa (Godot la usa como «fallback»).

  assets/fonts/PixelifySans-SinCifras.ttf  Pixelify Sans sin 0-9 (todo lo demás igual)
  assets/fonts/Silkscreen-Cifras.ttf       solo 0-9 de Silkscreen, muy claras en píxel

Así cada número del juego (vida, almas, precios, «SALA 3/4»…) sale con la
fuente clara, y las letras conservan su estilo, sin tocar cada texto.
Ambas fuentes son SIL OFL 1.1 (licencias en assets/fonts/OFL_*.txt); los
derivados llevan otro nombre de familia, como pide la licencia.

Uso:  python3 herramientas/fuente_cifras.py /ruta/Silkscreen-Regular.ttf
      (Silkscreen: github.com/google/fonts, ofl/silkscreen). Requiere fontTools.
"""
import sys
from pathlib import Path

from fontTools import subset
from fontTools.ttLib import TTFont

RAIZ = Path(__file__).resolve().parents[1]
CIFRAS = set(range(0x30, 0x3A))


def renombrar(fuente: TTFont, familia: str) -> None:
    for rec in fuente["name"].names:
        if rec.nameID in (1, 4, 16, 21):
            rec.string = familia
        elif rec.nameID == 6:
            rec.string = familia.replace(" ", "")


def proporcional(fuente: TTFont, aire: int = 125) -> None:
    """Silkscreen trae cifras de ancho fijo: «1» deja huecos («13 84»). Cada
    cifra pasa a medir lo que su dibujo, más un píxel de aire."""
    glyf, hmtx = fuente["glyf"], fuente["hmtx"]
    for nombre in fuente.getGlyphOrder():
        g = glyf[nombre]
        if g.numberOfContours <= 0:
            continue
        g.recalcBounds(glyf)
        x0, x1 = g.xMin, g.xMax
        g.coordinates.translate((-x0, 0))
        g.recalcBounds(glyf)
        hmtx[nombre] = (x1 - x0 + aire, g.xMin)


def recortar(origen: Path, destino: Path, quedarse, familia: str) -> None:
    fuente = TTFont(origen)
    todos = set(fuente.getBestCmap().keys())
    opciones = subset.Options()
    opciones.layout_features = ["*"]
    opciones.name_IDs = ["*"]
    opciones.notdef_outline = True
    sub = subset.Subsetter(opciones)
    sub.populate(unicodes=sorted(quedarse(todos)))
    sub.subset(fuente)
    renombrar(fuente, familia)
    if familia == "Cifras Templo":
        proporcional(fuente)
    fuente.save(destino)
    print(destino.relative_to(RAIZ), len(fuente.getBestCmap()), "caracteres")


if __name__ == "__main__":
    silk = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("Silkscreen-Regular.ttf")
    recortar(RAIZ / "assets/fonts/PixelifySans.ttf", RAIZ / "assets/fonts/PixelifySans-SinCifras.ttf",
             lambda t: t - CIFRAS, "Pixelify Templo")
    recortar(silk, RAIZ / "assets/fonts/Silkscreen-Cifras.ttf", lambda t: t & CIFRAS, "Cifras Templo")
