#!/usr/bin/env python3
"""Máscaras de transición originales (escala de grises, 320 x 180).

El primer juego del autor tapaba la pantalla con máscaras (nubes, estallido
radial, espiral y barrido) cuyo origen y licencia no constan. Estas son
recreaciones propias con el mismo efecto: el shader cubre primero los
píxeles más oscuros y por último los más claros.

Uso:  python3 herramientas/generar_transiciones.py
Salida: assets/visual/fx/transicion_{nubes,radial,espiral,barrido}.png
"""
from pathlib import Path
import numpy as np
from PIL import Image

RAIZ = Path(__file__).resolve().parents[1]
SALIDA = RAIZ / "assets" / "visual" / "fx"
W, H = 320, 180
rng = np.random.default_rng(1337)
yy, xx = np.mgrid[0:H, 0:W].astype(float)
cx, cy = W / 2, H / 2
dx, dy = (xx - cx) / (W / 2), (yy - cy) / (H / 2)
r = np.sqrt(dx * dx + dy * dy) / np.sqrt(2)
ang = np.arctan2(dy, dx)


def guardar(nombre: str, v: np.ndarray) -> None:
    v = (v - v.min()) / (v.max() - v.min())
    Image.fromarray((v * 255).astype(np.uint8), "L").save(SALIDA / f"transicion_{nombre}.png", optimize=True)
    print(f"transicion_{nombre}.png")


def nubes() -> np.ndarray:
    # Nubes de humo que se comen la pantalla desde los bordes hacia el centro.
    v = np.full((H, W), 1.0)
    for _ in range(900):
        x, y = rng.uniform(0, W), rng.uniform(0, H)
        rad = rng.uniform(8, 26)
        d = np.sqrt(((x - cx) / (W / 2)) ** 2 + ((y - cy) / (H / 2)) ** 2) / np.sqrt(2)
        val = np.clip(d + rng.normal(0, 0.06), 0, 1)
        mask = (xx - x) ** 2 + (yy - y) ** 2 < rad * rad
        v = np.where(mask & (val < v), val, v)
    return 1.0 - v  # bordes oscuros: se cubren primero


def radial() -> np.ndarray:
    # Estallido: rayos desde el centro hacia fuera.
    rayos = np.interp(ang, np.linspace(-np.pi, np.pi, 181), rng.uniform(0, 1, 181))
    return r * 0.8 + rayos * 0.2


def espiral() -> np.ndarray:
    # Remolino que se cierra hacia el centro.
    return 1.0 - ((ang / (2 * np.pi) + r * 1.6) % 1.0) * 0.35 - r * 0.65


def barrido() -> np.ndarray:
    # Barrido de arriba abajo con borde irregular.
    borde = np.interp(xx[0], np.linspace(0, W, 41), rng.uniform(-0.06, 0.06, 41))
    return yy / H + borde[None, :]


if __name__ == "__main__":
    SALIDA.mkdir(parents=True, exist_ok=True)
    guardar("nubes", nubes())
    guardar("radial", radial())
    guardar("espiral", espiral())
    guardar("barrido", barrido())
