#!/usr/bin/env python3
"""Repara los fondos de sala de assets/visual/rooms/ a partir de los originales.

Problemas que corrige (presentes en las composiciones de assets/knowledge/rooms/):
  * Guías de maquetación semitransparentes: líneas de cuadrícula (alfa 24-28) y
    elipses de sombra (alfa ~70). Al aplanar los fondos se volvieron líneas verdes
    brillantes y manchas negras opacas separadas de los objetos.
  * Braseros de las esquinas con un trozo del fotograma vecino pegado al lado
    (el recurso torch_*.png se cortó en celdas más anchas que el brasero).

Cómo lo hace:
  * El suelo de Knowledge Temple se repite exactamente cada 128 px. Un píxel que
    coincide con su copia desplazada 128·k px es suelo; el resto son objetos.
  * Huecos sobre suelo -> se reconstruyen con suelo auténtico desplazado.
    Huecos sobre objetos -> se rellenan con los vecinos perpendiculares.
  * Cada objeto recibe una sombra de contacto suave, pegada a su base y
    proyectada solo sobre suelo, con la misma luz para toda la sala.

Los archivos de assets/knowledge/ nunca se modifican. El script es idempotente:
siempre parte de --fuente-visual y del original.

Uso:  python3 herramientas/limpiar_fondos.py --fuente-visual CARPETA_CON_FONDOS_PREVIOS
"""
from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
from PIL import Image

RAIZ = Path(__file__).resolve().parent.parent
ORIGINALES = RAIZ / "assets" / "knowledge" / "rooms"
VISUALES = RAIZ / "assets" / "visual" / "rooms"
PERIODO = 128
# Desplazamientos candidatos, del más cercano al más lejano (menos diferencia de luz).
DESPLAZAMIENTOS = sorted(
    [(dy * PERIODO, dx * PERIODO) for dy in range(-3, 4) for dx in range(-6, 7) if (dy, dx) != (0, 0)],
    key=lambda d: abs(d[0]) + abs(d[1]),
)
# Zona jugable del fondo (dentro de los muros).
ARENA_Y = (165, 555)
ARENA_X = (68, 895)
# Fragmentos del fotograma vecino junto a cada brasero: (x0, x1, y0, y1) inclusive.
FRAGMENTOS_BRASERO = [(107, 118, 186, 227), (871, 882, 186, 227)]


def _erosionar(mascara: np.ndarray) -> np.ndarray:
    resultado = mascara.copy()
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            resultado &= np.roll(np.roll(mascara, dy, axis=0), dx, axis=1)
    return resultado


def mascara_suelo(original: np.ndarray) -> np.ndarray:
    """Píxeles idénticos a su copia desplazada 128·k px en un vecindario 3x3.

    Exigir el vecindario evita falsos positivos: algunos sprites comparten
    colores exactos con el suelo y coincidirían píxel a píxel por azar.
    """
    color = original[..., :3].astype(int)
    opaco = original[..., 3] == 255
    alto, ancho = opaco.shape
    suelo = np.zeros((alto, ancho), dtype=bool)
    comodin = ~opaco  # las guías no deben impedir reconocer el suelo vecino
    for dy, dx in DESPLAZAMIENTOS[:24]:
        y0, y1 = max(0, -dy), min(alto, alto - dy)
        x0, x1 = max(0, -dx), min(ancho, ancho - dx)
        if y0 >= y1 or x0 >= x1:
            continue
        igual = np.zeros((alto, ancho), dtype=bool)
        igual[y0:y1, x0:x1] = (
            (np.abs(color[y0:y1, x0:x1] - color[y0 + dy:y1 + dy, x0 + dx:x1 + dx]).sum(2) == 0)
            & opaco[y0:y1, x0:x1] & opaco[y0 + dy:y1 + dy, x0 + dx:x1 + dx]
        )
        suelo |= dilatar(_erosionar(igual | comodin), 1) & igual
    return suelo


def componentes(mascara: np.ndarray) -> list[np.ndarray]:
    """Etiquetado 8-conexo sencillo (sin dependencias externas)."""
    alto, ancho = mascara.shape
    etiqueta = np.zeros((alto, ancho), dtype=np.int32)
    grupos: list[np.ndarray] = []
    for y0, x0 in zip(*np.nonzero(mascara)):
        if etiqueta[y0, x0]:
            continue
        n = len(grupos) + 1
        pila = [(y0, x0)]
        etiqueta[y0, x0] = n
        puntos = []
        while pila:
            y, x = pila.pop()
            puntos.append((y, x))
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    yy, xx = y + dy, x + dx
                    if 0 <= yy < alto and 0 <= xx < ancho and mascara[yy, xx] and not etiqueta[yy, xx]:
                        etiqueta[yy, xx] = n
                        pila.append((yy, xx))
        grupos.append(np.array(puntos))
    return grupos


def dilatar(mascara: np.ndarray, radio: int) -> np.ndarray:
    resultado = mascara.copy()
    for dy in range(-radio, radio + 1):
        for dx in range(-radio, radio + 1):
            resultado |= np.roll(np.roll(mascara, dy, axis=0), dx, axis=1)
    return resultado


def suelo_en(img: np.ndarray, suelo: np.ndarray, y: int, x: int, radio: int = 4):
    """Suelo auténtico para (y, x), con la luz local del destino (halos, viñeta)."""
    alto, ancho = suelo.shape
    for dy, dx in DESPLAZAMIENTOS:
        yy, xx = y + dy, x + dx
        if not (0 <= yy < alto and 0 <= xx < ancho and suelo[yy, xx]):
            continue
        y0, y1 = max(0, y - radio, -dy), min(alto, y + radio + 1, alto - dy)
        x0, x1 = max(0, x - radio, -dx), min(ancho, x + radio + 1, ancho - dx)
        comun = suelo[y0:y1, x0:x1] & suelo[y0 + dy:y1 + dy, x0 + dx:x1 + dx]
        valor = img[yy, xx].copy()
        if comun.sum() >= 6:
            destino = img[y0:y1, x0:x1, :3][comun].mean(axis=0)
            origen = img[y0 + dy:y1 + dy, x0 + dx:x1 + dx, :3][comun].mean(axis=0)
            valor[:3] += destino - origen
        return valor
    return None


def rellenar_por_vecinos(img: np.ndarray, pendientes: np.ndarray) -> None:
    """Rellena de fuera hacia dentro lo que no tuvo fuente periódica."""
    alto, ancho = pendientes.shape
    pendientes = pendientes.copy()
    while pendientes.any():
        avance = False
        for y, x in zip(*np.nonzero(pendientes)):
            vecinos = [img[yy, xx] for yy, xx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1))
                       if 0 <= yy < alto and 0 <= xx < ancho and not pendientes[yy, xx]]
            if vecinos:
                img[y, x] = np.mean(vecinos, axis=0)
                pendientes[y, x] = False
                avance = True
        if not avance:
            break


def reparar_huecos(img: np.ndarray, huecos: np.ndarray, suelo: np.ndarray) -> None:
    alto, ancho = huecos.shape
    fuente = img.copy()
    sin_fuente = np.zeros_like(huecos)
    for y, x in zip(*np.nonzero(huecos)):
        horizontal = (x > 0 and huecos[y, x - 1]) or (x < ancho - 1 and huecos[y, x + 1])
        vecinos = [(y - 1, x), (y + 1, x)] if horizontal else [(y, x - 1), (y, x + 1)]
        vecinos = [(yy, xx) for yy, xx in vecinos if 0 <= yy < alto and 0 <= xx < ancho and not huecos[yy, xx]]
        sobre_suelo = not vecinos or all(suelo[yy, xx] for yy, xx in vecinos)
        valor = suelo_en(fuente, suelo, y, x) if sobre_suelo else None
        if valor is None and vecinos:
            # Sobre un objeto: copiar un vecino en lugar de promediar. En pixel
            # art un color intermedio se lee como una costura; un píxel
            # duplicado no se nota.
            valor = fuente[vecinos[0]].copy()
        if valor is None:
            sin_fuente[y, x] = True
        else:
            img[y, x] = valor
    rellenar_por_vecinos(img, sin_fuente)


def suavizar_restos(img: np.ndarray, huecos: np.ndarray, suelo: np.ndarray, umbral: float = 45.0) -> int:
    """Corrige píxeles reparados que destacan, solo si a su alrededor no hay objetos."""
    alto, ancho = huecos.shape
    objetos = ~suelo & ~huecos
    cerca_de_objeto = dilatar(objetos, 1)
    luz = img[..., :3].sum(2)
    corregidos = 0
    for y, x in zip(*np.nonzero(huecos & ~cerca_de_objeto)):
        y0, y1, x0, x1 = max(0, y - 3), min(alto, y + 4), max(0, x - 3), min(ancho, x + 4)
        ventana = suelo[y0:y1, x0:x1]
        if ventana.sum() < 8:
            continue
        mediana = np.median(img[y0:y1, x0:x1, :3][ventana], axis=0)
        if abs(luz[y, x] - mediana.sum()) > umbral:
            img[y, x, :3] = mediana
            corregidos += 1
    return corregidos


def borrar_rectangulo(img: np.ndarray, suelo: np.ndarray, x0: int, x1: int, y0: int, y1: int) -> np.ndarray:
    borrado = np.zeros_like(suelo)
    sin_fuente = np.zeros_like(suelo)
    fuente = img.copy()
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            if suelo[y, x]:
                continue
            valor = suelo_en(fuente, suelo, y, x)
            if valor is None:
                sin_fuente[y, x] = True
            else:
                img[y, x] = valor
            borrado[y, x] = True
    rellenar_por_vecinos(img, sin_fuente)
    return borrado


def objetos_de_sala(objetos: np.ndarray) -> list[np.ndarray]:
    """Objetos sueltos (columnas, estatuas, mesas...). Excluye arcos del muro y motas."""
    grupos = []
    for grupo in componentes(dilatar(objetos, 2)):
        if len(grupo) >= 400 and grupo[:, 0].max() >= 200:
            grupos.append(grupo)
    return grupos


def sombras_de_contacto(img: np.ndarray, suelo_visible: np.ndarray, grupos: list[np.ndarray]) -> int:
    alto, ancho = suelo_visible.shape
    yy, xx = np.mgrid[0:alto, 0:ancho]
    oscuridad = np.zeros((alto, ancho))
    cantidad = 0
    for grupo in grupos:
        ys, xs = grupo[:, 0], grupo[:, 1]
        base = ys.max()
        pie = xs[ys >= base - 4]
        cx = (pie.min() + pie.max()) / 2.0
        rx = max((pie.max() - pie.min()) * 0.62, 10.0)
        ry = max(rx * 0.30, 5.0)
        cy = base - ry * 0.35
        d = ((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2
        oscuridad = np.maximum(oscuridad, 0.46 * np.clip(1.0 - d, 0.0, 1.0) ** 0.8)
        cantidad += 1
    oscuridad *= suelo_visible
    img[..., :3] *= (1.0 - oscuridad)[..., None]
    return cantidad


def limpiar(indice: int, fuente_visual: Path) -> str:
    original = np.array(Image.open(ORIGINALES / f"room_{indice}.png").convert("RGBA"))
    img = np.array(Image.open(fuente_visual / f"room_{indice}.png").convert("RGBA")).astype(float)
    zona = np.zeros(original.shape[:2], dtype=bool)
    zona[ARENA_Y[0]:ARENA_Y[1], ARENA_X[0]:ARENA_X[1]] = True
    # Solo cuenta como suelo lo que está dentro de los muros: el fondo liso
    # exterior también se repite y daría colores equivocados.
    suelo = mascara_suelo(original) & zona
    huecos = (original[..., 3] < 255) & zona
    # La versión aplanada dibujó las guías 1 px más gruesas: cubrir ese borde sobre suelo.
    huecos |= dilatar(huecos, 1) & suelo
    limpio = suelo & ~huecos  # suelo que sirve como fuente fiable
    reparar_huecos(img, huecos, limpio)
    suavizar_restos(img, huecos, limpio)
    borrado = np.zeros_like(suelo)
    for rect in FRAGMENTOS_BRASERO:
        borrado |= borrar_rectangulo(img, limpio, *rect)
    suelo_visible = suelo | (huecos & ~dilatar(~suelo & ~huecos, 1)) | borrado
    objetos = ~suelo_visible & ~huecos
    objetos[: ARENA_Y[0]] = False
    objetos[ARENA_Y[1]:] = False
    objetos[:, : ARENA_X[0]] = False
    objetos[:, ARENA_X[1]:] = False
    grupos = objetos_de_sala(objetos)
    n = sombras_de_contacto(img, suelo_visible & zona, grupos)
    img[..., 3] = 255
    Image.fromarray(np.clip(img, 0, 255).astype(np.uint8)).save(VISUALES / f"room_{indice}.png", optimize=True)
    texto = f"room_{indice}: {int(huecos[ARENA_Y[0]:ARENA_Y[1]].sum())} px de guías reparados, {int(borrado.sum())} px de fragmentos borrados, {n} sombras de contacto"
    return texto


# Vigilia del Claustro: la sala II sin los objetos que ocupan la cámara
# defendida (columna, estatua central y estatua del arquero).
VIGILIA_BORRAR = [(326, 274, 64, 152), (588, 280, 82, 112), (456, 168, 64, 120)]


def generar_vigilia(fuente_visual: Path) -> None:
    original = np.array(Image.open(ORIGINALES / "room_1.png").convert("RGBA"))
    img = np.array(Image.open(VISUALES / "room_1.png").convert("RGBA")).astype(float)
    zona = np.zeros(original.shape[:2], dtype=bool)
    zona[ARENA_Y[0]:ARENA_Y[1], ARENA_X[0]:ARENA_X[1]] = True
    suelo = mascara_suelo(original) & zona & (original[..., 3] == 255)
    borrar = np.zeros_like(suelo)
    for x, y, w, h in VIGILIA_BORRAR:
        borrar[y:y + h, x:x + w] = True
    fuente = suelo & ~borrar
    copia = img.copy()
    pendientes = np.zeros_like(suelo)
    for y, x in zip(*np.nonzero(borrar)):
        for dy, dx in DESPLAZAMIENTOS:
            yy, xx = y + dy, x + dx
            if 0 <= yy < fuente.shape[0] and 0 <= xx < fuente.shape[1] and fuente[yy, xx]:
                img[y, x] = copia[yy, xx]
                break
        else:
            pendientes[y, x] = True
    rellenar_por_vecinos(img, pendientes)
    # Restos tenues de guías en las filas copiadas: mediana local solo dentro
    # de las zonas borradas.
    luz = img[..., :3].sum(2)
    for y, x in zip(*np.nonzero(borrar)):
        ventana = img[max(0, y - 3):y + 4, x - 1:x + 2, :3].reshape(-1, 3)
        mediana = np.median(ventana, axis=0)
        if abs(luz[y, x] - mediana.sum()) > 18:
            img[y, x, :3] = mediana
    img[..., 3] = 255
    Image.fromarray(np.clip(img, 0, 255).astype(np.uint8)).save(VISUALES / "vigilia.png", optimize=True)


def main() -> None:
    parser = argparse.ArgumentParser(description="Repara los fondos visuales de las salas.")
    parser.add_argument("--fuente-visual", type=Path, required=True,
                        help="Carpeta con los fondos visuales previos a la reparación (p. ej. extraídos de git).")
    args = parser.parse_args()
    for i in range(5):
        print(limpiar(i, args.fuente_visual))
    generar_vigilia(args.fuente_visual)
    print("vigilia.png generado")


if __name__ == "__main__":
    main()
