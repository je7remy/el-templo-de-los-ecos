#!/usr/bin/env python3
"""Genera assets/visual/fx/niebla.png: niebla tileable (ruido suave) para la atmósfera.

Uso:  python3 herramientas/generar_niebla.py assets/visual/fx/niebla.png
"""
# Textura de niebla tileable (ruido de valor suavizado por octavas), blanca con alfa.
import numpy as np
from PIL import Image
rng = np.random.default_rng(7)
W, H = 256, 128
def octave(cells_x, cells_y):
    g = rng.random((cells_y, cells_x))
    ys = np.linspace(0, cells_y, H, endpoint=False); xs = np.linspace(0, cells_x, W, endpoint=False)
    x0 = np.floor(xs).astype(int); y0 = np.floor(ys).astype(int)
    fx = xs - x0; fy = ys - y0
    fx = fx*fx*(3-2*fx); fy = fy*fy*(3-2*fy)
    x1 = (x0+1) % cells_x; y1 = (y0+1) % cells_y
    a = g[np.ix_(y0, x0)]; b = g[np.ix_(y0, x1)]; c = g[np.ix_(y1, x0)]; d = g[np.ix_(y1, x1)]
    top = a + (b-a)*fx[None, :]; bot = c + (d-c)*fx[None, :]
    return top + (bot-top)*fy[:, None]
n = sum(octave(4*2**i, 2*2**i) * 0.5**i for i in range(4))
n = (n - n.min()) / (n.max() - n.min())
alpha = np.clip((n - 0.35) / 0.65, 0, 1) ** 1.6
# Bordes superior e inferior difuminados: la banda de niebla no deja línea.
yy = np.linspace(0, 1, H)[:, None]
def smooth(e0, e1, x):
    t = np.clip((x - e0) / (e1 - e0), 0, 1)
    return t * t * (3 - 2 * t)
alpha = alpha * smooth(0.0, 0.5, yy) * smooth(1.0, 0.8, yy)
img = np.zeros((H, W, 4), np.uint8)
img[..., :3] = 255
img[..., 3] = (alpha * 255).astype(np.uint8)
import sys
Image.fromarray(img, "RGBA").save(sys.argv[1], optimize=True)
print("niebla", W, H)
