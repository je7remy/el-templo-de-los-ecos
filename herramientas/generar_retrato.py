#!/usr/bin/env python3
"""Genera el retrato ORIGINAL de Mark para el HUD y el perfil (64 x 64 px).

Busto de tres cuartos con la misma paleta que su sprite
(herramientas/generar_protagonista.py): pelo oscuro, abrigo verde azulado,
bufanda granate y correa de latón. Dos variantes:

  assets/visual/retratos/mark.png         normal
  assets/visual/retratos/mark_herido.png  con sangre y la mirada perdida
                                          (se muestra con poca vida)

Uso:  python3 herramientas/generar_retrato.py [--vista-previa RUTA.png]
"""
from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageDraw

RAIZ = Path(__file__).resolve().parent.parent
SALIDA = RAIZ / "assets" / "visual" / "retratos"
T = 64


def c(h: str, a: int = 255) -> tuple:
    h = h.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), a)


CONTORNO = c("#13181E")
PELO, PELO_LUZ, PELO_BRILLO = c("#1F1F24"), c("#2E3340"), c("#454B5C")
ABRIGO, ABRIGO_LUZ, ABRIGO_SOMBRA = c("#395359"), c("#58706F"), c("#253941")
GRANATE, GRANATE_LUZ, GRANATE_SOMBRA = c("#843844"), c("#BA575B"), c("#5E2630")
PIEL, PIEL_SOMBRA, PIEL_LUZ = c("#C59C81"), c("#906A57"), c("#E1B592")
LATON, LATON_LUZ = c("#B5A986"), c("#DCD2AE")
OJO, OJO_BRILLO = c("#1A1418"), c("#F4EBDD")
OJERA = c("#7a5a50")
SANGRE, SANGRE_VIVA, SANGRE_SECA = c("#8a1620"), c("#c23a40"), c("#5e1117")


def contorno(img: Image.Image) -> Image.Image:
    a = img.load()
    out = img.copy()
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


def retrato(herido: bool) -> Image.Image:
    img = Image.new("RGBA", (T, T), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Hombros y abrigo (cortados por el borde inferior).
    d.polygon([(6, 63), (12, 46), (24, 41), (40, 41), (52, 46), (58, 63)], fill=ABRIGO)
    d.polygon([(6, 63), (12, 46), (20, 43), (18, 63)], fill=ABRIGO_LUZ)
    d.polygon([(44, 63), (46, 44), (52, 46), (58, 63)], fill=ABRIGO_SOMBRA)
    d.line([(32, 50), (32, 63)], fill=ABRIGO_SOMBRA)
    # Correa de latón cruzada.
    d.line([(14, 48), (44, 63)], fill=LATON, width=3)
    d.line([(14, 47), (44, 62)], fill=LATON_LUZ)
    # Bufanda granate con su cola al viento.
    d.polygon([(20, 40), (44, 40), (46, 48), (18, 48)], fill=GRANATE)
    d.polygon([(20, 40), (44, 40), (44, 42), (20, 42)], fill=GRANATE_LUZ)
    d.polygon([(38, 46), (46, 46), (50, 58), (43, 57)], fill=GRANATE_SOMBRA)
    d.line([(24, 44), (40, 44)], fill=GRANATE_SOMBRA)
    # Cuello y cara (tres cuartos, mirando a la izquierda del encuadre).
    d.rectangle([27, 33, 37, 40], fill=PIEL_SOMBRA)
    d.ellipse([19, 11, 45, 40], fill=PIEL)
    d.ellipse([33, 13, 45, 39], fill=PIEL_SOMBRA)
    d.ellipse([21, 14, 30, 22], fill=PIEL_LUZ)  # frente iluminada desde arriba
    # Oreja.
    d.ellipse([41, 22, 47, 30], fill=PIEL_SOMBRA)
    d.point((44, 26), fill=c("#6e4f42"))
    # Pelo: mechones irregulares y flequillo que cae.
    d.ellipse([17, 5, 47, 25], fill=PELO)
    d.polygon([(17, 16), (22, 9), (30, 6), (40, 7), (47, 14), (47, 26), (43, 20), (38, 18), (34, 21), (31, 17), (26, 22), (22, 18), (18, 24)], fill=PELO)
    d.polygon([(22, 9), (30, 6), (38, 8), (30, 11)], fill=PELO_LUZ)
    d.line([(26, 8), (33, 7)], fill=PELO_BRILLO)
    for x, y in ((21, 18), (27, 19), (33, 19)):
        d.line([(x, y), (x + 1, y + 4)], fill=PELO_LUZ)
    # Ojos cansados (con ojeras).
    for ox in (24, 33):
        d.rectangle([ox, 26, ox + 3, 26], fill=OJERA)
        d.rectangle([ox, 24, ox + 3, 25], fill=OJO)
        d.point((ox + 1, 24), fill=OJO_BRILLO if not herido else c("#c9a8a0"))
    # Cejas.
    d.line([(23, 21), (27, 21)], fill=PELO)
    d.line([(32, 21), (37, 22)], fill=PELO)
    # Nariz y boca.
    d.line([(30, 25), (29, 30)], fill=PIEL_SOMBRA)
    d.point((30, 31), fill=PIEL_SOMBRA)
    d.line([(27, 34), (32, 34)], fill=c("#7a4c44"))
    img = contorno(img)
    if herido:
        d = ImageDraw.Draw(img)
        # Brecha en la frente y sangre que cae por la cara.
        d.line([(24, 13), (28, 17)], fill=SANGRE_VIVA, width=2)
        d.line([(27, 17), (26, 24)], fill=SANGRE)
        d.line([(26, 25), (25, 33)], fill=SANGRE)
        d.point((25, 34), fill=SANGRE_VIVA)
        d.line([(34, 30), (37, 33)], fill=SANGRE_SECA)  # moratón
        d.ellipse([20, 37, 26, 42], fill=SANGRE)  # salpicadura en el cuello
        d.point((22, 38), fill=SANGRE_VIVA)
        d.line([(27, 34), (32, 35)], fill=SANGRE_SECA)  # labio partido
        for x, y in ((12, 50), (16, 55), (48, 52), (40, 58)):
            d.point((x, y), fill=SANGRE)
            d.point((x + 1, y), fill=SANGRE_SECA)
    return img


def main() -> None:
    parser = argparse.ArgumentParser(description="Genera el retrato de Mark.")
    parser.add_argument("--vista-previa", type=Path)
    args = parser.parse_args()
    SALIDA.mkdir(parents=True, exist_ok=True)
    a, b = retrato(False), retrato(True)
    a.save(SALIDA / "mark.png", optimize=True)
    b.save(SALIDA / "mark_herido.png", optimize=True)
    print(f"retratos en {SALIDA.relative_to(RAIZ)}")
    if args.vista_previa:
        lam = Image.new("RGBA", (T * 2 + 12, T + 8), (25, 30, 38, 255))
        lam.alpha_composite(a, (4, 4))
        lam.alpha_composite(b, (T + 8, 4))
        lam.resize((lam.width * 5, lam.height * 5), Image.NEAREST).save(args.vista_previa)


if __name__ == "__main__":
    main()
