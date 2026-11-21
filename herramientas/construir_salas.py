#!/usr/bin/env python3
"""Convierte las cinco composiciones fijas en datos para salas editables (paso 1/2).

Resultado de este paso:
  * assets/visual/tiles/templo.png        atlas de tiles 32x32 (arquitectura sin objetos)
  * assets/visual/objetos/sala_N/*.png    un PNG por objeto (columnas, estatuas, arcos...)
  * herramientas/salas.json               rejilla de tiles, objetos, marcadores, colisiones
                                          y parámetros de luz por sala

El paso 2 lo hace Godot:  godot --headless --path . --script res://herramientas/construir_salas.gd
y escribe rooms/templo_tileset.tres y rooms/sala_N.tscn.

Cómo se reconstruye la arquitectura: suelo y muros se repiten cada 128 px. Para
cada píxel se vota entre sus copias desplazadas 128·k px (en horizontal y, dentro
de la sala, también en vertical); los objetos y las guías de maquetación quedan
en minoría y desaparecen. Las cinco salas comparten arquitectura y solo cambian
de tinte, así que el atlas sale de la sala 0 y cada sala aplica su luz con
shaders/luz_sala.gdshader (ganancia y desplazamiento por canal, ajustados contra
assets/visual/rooms).

AVISO: volver a ejecutar ambos pasos REGENERA las escenas de las salas y
descarta los cambios hechos a mano en el editor.
"""
from __future__ import annotations

import json
from collections import Counter
from pathlib import Path

import numpy as np
from PIL import Image

from limpiar_fondos import FRAGMENTOS_BRASERO, componentes, dilatar

RAIZ = Path(__file__).resolve().parent.parent
ORIGINALES = RAIZ / "assets" / "knowledge" / "rooms"
VISUALES = RAIZ / "assets" / "visual" / "rooms"
ATLAS = RAIZ / "assets" / "visual" / "tiles" / "templo.png"
OBJETOS = RAIZ / "assets" / "visual" / "objetos"
DATOS = RAIZ / "herramientas" / "salas.json"

ALTO, ANCHO = 640, 960
TILE = 32
FASE = 8  # la rejilla de 32 px que menos tiles únicos produce empieza en (8, 8)
# Zonas estructurales en x: exterior, muro izquierdo (con su borde), sala,
# muro derecho, exterior. Solo se vota dentro de la misma zona.
ZONAS = [(0, 46), (46, 68), (68, 895), (895, 913), (913, 960)]
SUELO_Y = (168, 548)  # banda donde el suelo también se repite en vertical
ARCOS_X = [136, 350, 566, 782]  # nichos góticos del muro del fondo (46x46, y=145)

# Datos de juego que antes estaban fijos en scripts/main.gd.
MARCADORES = {
    "Jugador": (115, 359), "Salida": (867, 355),
    "Reliquia1": (280, 245), "Reliquia2": (500, 465), "Reliquia3": (725, 230),
}
MARCADORES_SALA = {
    0: {},
    1: {"Enemigo": (772, 472), "Altar": (488, 318)},
    2: {"Enemigo": (765, 358), "Sello": (704, 343), "Ojo": (690, 143)},
    3: {"Enemigo": (773, 354), "Libro": (497, 310), "Lectura": (497, 362)},
    4: {},
}
COLISIONES = {
    0: [(397, 295, 62, 60), (630, 378, 70, 55)],
    1: [(331, 305, 55, 86), (601, 305, 55, 86), (463, 300, 50, 36)],
    2: [(315, 285, 50, 70), (530, 400, 55, 70)],
    3: [(341, 340, 70, 60), (635, 340, 70, 60), (457, 296, 82, 44)],
    4: [(365, 245, 62, 62), (655, 412, 54, 54), (767, 424, 58, 46)],
}


def base_sala(original: np.ndarray) -> np.ndarray:
    base = np.zeros((ALTO, ANCHO, 4), np.uint8)
    falta = np.zeros((ALTO, ANCHO), bool)
    for x0, x1 in ZONAS:
        for x in range(x0, x1):
            xs = [x + 128 * k for k in range(-8, 9) if x0 <= x + 128 * k < x1]
            minimo = 2 if len(xs) > 1 else 1
            for y in range(ALTO):
                if (x0, x1) == (68, 895) and SUELO_Y[0] <= y < SUELO_Y[1]:
                    ys = [y + 128 * j for j in range(-4, 5) if SUELO_Y[0] <= y + 128 * j < SUELO_Y[1]]
                    candidatos = original[ys][:, xs].reshape(-1, 4)
                else:
                    candidatos = original[y, xs]
                votos = Counter(p.tobytes() for p in candidatos if p[3] == 255)
                if votos:
                    mejor, n = votos.most_common(1)[0]
                    if n >= max(minimo, int(0.3 * len(candidatos))):
                        base[y, x] = np.frombuffer(mejor, np.uint8)
                        continue
                falta[y, x] = True
    # Guías de maquetación sin ninguna copia limpia: duplicar el vecino.
    while falta.any():
        avance = False
        for y, x in zip(*np.nonzero(falta)):
            horizontal = (x > 0 and falta[y, x - 1]) or (x < ANCHO - 1 and falta[y, x + 1])
            orden = ((-1, 0), (1, 0), (0, -1), (0, 1)) if horizontal else ((0, -1), (0, 1), (-1, 0), (1, 0))
            for dy, dx in orden:
                yy, xx = y + dy, x + dx
                if 0 <= yy < ALTO and 0 <= xx < ANCHO and not falta[yy, xx]:
                    base[y, x] = base[yy, xx]
                    falta[y, x] = False
                    avance = True
                    break
        if not avance:
            break
    return base


def ajustar_luz(base0: np.ndarray, original: np.ndarray, base: np.ndarray, visual: np.ndarray) -> dict:
    """visual ≈ ganancia * base0 + desplazamiento, por canal, sobre la arquitectura."""
    zona = np.zeros((ALTO, ANCHO), bool)
    zona[118:580, 40:930] = True
    limpio = zona & (original[..., 3] == 255) & (np.abs(original[..., :3].astype(int) - base[..., :3]).sum(2) == 0)
    ganancia, desplazamiento = [], []
    for canal in range(3):
        x = base0[limpio][:, canal].astype(float)
        y = visual[limpio][:, canal].astype(float)
        a, b = np.linalg.lstsq(np.vstack([x, np.ones(len(x))]).T, y, rcond=None)[0]
        ganancia.append(round(float(a), 4))
        desplazamiento.append(round(float(b) / 255.0, 4))
    return {"ganancia": ganancia, "desplazamiento": desplazamiento}


def construir_atlas(base0: np.ndarray) -> tuple[list[list[int]], int]:
    """Corta la base en tiles de 32 px con la fase óptima. Devuelve rejilla de índices."""
    lienzo = np.zeros((ALTO + 2 * TILE, ANCHO + 2 * TILE, 4), np.uint8)
    lienzo[TILE:TILE + ALTO, TILE:TILE + ANCHO] = base0
    # Fuera de la imagen: color del vacío exterior.
    lienzo[lienzo[..., 3] == 0] = base0[5, 5]
    origen = TILE - (TILE - FASE)  # la celda (0,0) empieza en x = y = -24
    filas = (ALTO + (TILE - FASE)) // TILE + 1
    columnas = (ANCHO + (TILE - FASE)) // TILE + 1
    unicos: dict[bytes, int] = {}
    tiles: list[np.ndarray] = []
    rejilla = []
    for fy in range(filas):
        fila = []
        for fx in range(columnas):
            y, x = origen + fy * TILE, origen + fx * TILE
            t = lienzo[y:y + TILE, x:x + TILE]
            clave = t.tobytes()
            if clave not in unicos:
                unicos[clave] = len(tiles)
                tiles.append(t.copy())
            fila.append(unicos[clave])
        rejilla.append(fila)
    por_fila = 8
    atlas = np.zeros((((len(tiles) + por_fila - 1) // por_fila) * TILE, por_fila * TILE, 4), np.uint8)
    for i, t in enumerate(tiles):
        atlas[(i // por_fila) * TILE:(i // por_fila + 1) * TILE, (i % por_fila) * TILE:(i % por_fila + 1) * TILE] = t
    ATLAS.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(atlas).save(ATLAS, optimize=True)
    return rejilla, por_fila


def nombre_objeto(sala: int, x: int, y: int, w: int, h: int) -> str:
    """Nombre legible para el árbol de escena, deducido del tamaño medido."""
    if y < 160 and h <= 50:
        return "Arco"
    if w <= 20:
        return "Cirios"
    if y < 240 and h <= 44:
        return "Brasero"
    if y < 240 and w <= 42 and h <= 56:
        return "EstatuaOrante"
    if y < 200 and 70 <= h <= 90:
        return "EstatuaOrante"
    if y < 200 and h >= 100:
        return "EstatuaArquero"
    if w >= 85 and h <= 62:
        return "Mesa"
    if sala == 4 and y >= 400 and h <= 70:
        return "Sarcofago"
    if sala == 4 and h <= 80:
        return "ColumnaRota"
    if h >= 105:
        return "Columna"
    return "EstatuaPedestal"


def extraer_objetos(sala: int, original: np.ndarray, base: np.ndarray, visual: np.ndarray, arco: np.ndarray | None):
    distinto = (np.abs(original[..., :3].astype(int) - base[..., :3]).sum(2) > 0) & (original[..., 3] == 255)
    distinto[:100] = False
    # Trozo del fotograma vecino pegado a cada brasero: no es un objeto.
    for fx0, fx1, fy0, fy1 in FRAGMENTOS_BRASERO:
        distinto[fy0:fy1 + 1, fx0:fx1 + 1] = False
    # Separar los arcos (idénticos entre sí) de la estatua que a veces los toca.
    es_arco = np.zeros_like(distinto)
    if arco is not None:
        ah, aw = arco.shape[:2]
        for ax in ARCOS_X:
            ventana = original[145:145 + ah, ax:ax + aw]
            igual = (np.abs(ventana[..., :3].astype(int) - arco[..., :3]).sum(2) == 0) & (arco[..., 3] > 0)
            es_arco[145:145 + ah, ax:ax + aw] |= igual & distinto[145:145 + ah, ax:ax + aw]
    objetos = []
    for mascara in (es_arco, distinto & ~es_arco):
        etiquetas = componentes(dilatar(mascara, 2))
        for g in etiquetas:
            ys, xs = g[:, 0], g[:, 1]
            x0, y0, x1, y1 = xs.min(), ys.min(), xs.max() + 1, ys.max() + 1
            dentro = np.zeros_like(mascara)
            dentro[ys, xs] = True
            pix = dentro & mascara
            if pix.sum() < 60:
                continue
            ys2, xs2 = np.nonzero(pix)
            x0, y0, x1, y1 = xs2.min(), ys2.min(), xs2.max() + 1, ys2.max() + 1
            recorte = np.zeros((y1 - y0, x1 - x0, 4), np.uint8)
            sub = pix[y0:y1, x0:x1]
            recorte[sub] = visual[y0:y1, x0:x1][sub]
            recorte[sub, 3] = 255
            objetos.append((int(x0), int(y0), recorte))
    objetos.sort(key=lambda o: (o[1] + o[2].shape[0], o[0]))
    carpeta = OBJETOS / f"sala_{sala}"
    carpeta.mkdir(parents=True, exist_ok=True)
    for viejo in carpeta.glob("*.png"):
        viejo.unlink()
    datos = []
    usados: Counter = Counter()
    for x0, y0, recorte in objetos:
        h, w = recorte.shape[:2]
        nombre = nombre_objeto(sala, x0, y0, w, h)
        usados[nombre] += 1
        nodo = f"{nombre}{usados[nombre]}"
        archivo = f"{nodo.lower()}.png"
        Image.fromarray(recorte).save(carpeta / archivo, optimize=True)
        # Ancla en el centro de la base: es la coordenada que ordena la profundidad.
        # Los arcos pertenecen al muro: se anclan en su línea (y=158) para que
        # nadie quede «detrás» de ellos.
        ancla_y = 158 if nombre == "Arco" else y0 + h
        datos.append({
            "nodo": nodo, "textura": f"res://assets/visual/objetos/sala_{sala}/{archivo}",
            "ancla": [x0 + w // 2, ancla_y], "offset": [x0 - (x0 + w // 2), y0 - ancla_y],
            "sombra": nombre not in ("Arco",), "luz": nombre == "Brasero",
            "caja": [int(x0), int(y0), int(w), int(h)],
        })
    return datos


RUNA = (400, 425, 146, 106)  # x, y, w, h del círculo rúnico bajo la aparición


def extraer_runa(original: np.ndarray, lit_base: np.ndarray, visual_previa: np.ndarray) -> dict:
    """Círculo rúnico del suelo (añadido por la versión visual) como decal colocable.

    lit_base es la arquitectura con la luz de la sala aplicada; lo que la versión
    visual tiene de más dentro del recuadro es la runa. Las guías que la cruzan
    se excluyen y se cierran con el píxel vecino.
    """
    x, y, w, h = RUNA
    dif = np.abs(visual_previa[y:y + h, x:x + w, :3].astype(int) - lit_base[y:y + h, x:x + w, :3]).sum(2)
    guias = dilatar(original[y:y + h, x:x + w, 3] < 255, 2)
    yy_, xx_ = np.mgrid[0:h, 0:w]
    ovalo = ((xx_ - w / 2 + 0.5) / (w / 2)) ** 2 + ((yy_ - h / 2 + 0.5) / (h / 2)) ** 2 <= 1.0
    runa = (dif >= 12) & ~guias & ovalo
    # Filas casi completas = restos del marco de la versión visual, no de la runa.
    for fila in range(h):
        if runa[fila].sum() > 0.45 * w:
            runa[fila] = False
    color = visual_previa[y:y + h, x:x + w].copy()
    for yy, xx in zip(*np.nonzero(guias)):
        for (ay, ax), (by, bx) in (((yy - 3, xx), (yy + 3, xx)), ((yy, xx - 3), (yy, xx + 3))):
            if 0 <= ay < h and 0 <= by < h and 0 <= ax < w and 0 <= bx < w and runa[ay, ax] and runa[by, bx]:
                runa[yy, xx] = True
                color[yy, xx] = color[ay, ax]
                break
    decal = np.zeros((h, w, 4), np.uint8)
    decal[runa] = color[runa]
    decal[runa, 3] = 255
    ruta = OBJETOS / "runa_suelo.png"
    Image.fromarray(decal).save(ruta, optimize=True)
    return {"nodo": "RunaSuelo", "textura": "res://assets/visual/objetos/runa_suelo.png", "posicion": [x, y]}


def asignar_colisiones(objetos: list[dict], colisiones: list[tuple]) -> list[dict]:
    """Cuelga cada colisión del objeto que la contiene (se mueven juntos en el editor)."""
    sueltas = []
    for x, y, w, h in colisiones:
        cx, cy = x + w / 2, y + h / 2
        duenos = [o for o in objetos if o["caja"][0] <= cx <= o["caja"][0] + o["caja"][2] and o["caja"][1] <= cy <= o["caja"][1] + o["caja"][3]]
        rect = {"centro": [cx, cy], "tamano": [w, h]}
        if len(duenos) == 1:
            duenos[0]["colision"] = rect
        else:
            sueltas.append(rect)
    return sueltas


def main() -> None:
    originales = [np.array(Image.open(ORIGINALES / f"room_{i}.png").convert("RGBA")) for i in range(5)]
    visuales = [np.array(Image.open(VISUALES / f"room_{i}.png").convert("RGBA")) for i in range(5)]
    bases = []
    for i, o in enumerate(originales):
        bases.append(base_sala(o))
        print(f"sala {i}: arquitectura reconstruida")
    rejilla, por_fila = construir_atlas(bases[0])
    print(f"atlas: {max(max(f) for f in rejilla) + 1} tiles de {TILE}x{TILE}")
    # Plantilla del arco: el primero de la sala 0 sobre fondo transparente.
    o0 = originales[0].astype(int)
    d0 = (np.abs(o0[..., :3] - bases[0][..., :3]).sum(2) > 0) & (originales[0][..., 3] == 255)
    arco = np.zeros((46, 46, 4), np.uint8)
    sub = d0[145:191, 136:182]
    arco[sub] = originales[0][145:191, 136:182][sub]
    # Runa: diferencia entre la versión visual previa (sin limpiar) y la base iluminada.
    previa = RAIZ / "herramientas" / "_visual_previa_room_0.png"
    decales = []
    if previa.exists():
        luz0 = ajustar_luz(bases[0], originales[0], bases[0], visuales[0])
        lit = np.clip(bases[0][..., :3] * np.array(luz0["ganancia"]) + np.array(luz0["desplazamiento"]) * 255.0, 0, 255)
        decales.append(extraer_runa(originales[0], lit, np.array(Image.open(previa).convert("RGBA"))))
        print("runa del suelo extraída")
    elif (OBJETOS / "runa_suelo.png").exists():
        # La fuente (room_0.png de assets/visual antes de la limpieza, commit
        # 3f4d942) ya no está en el árbol: se reutiliza el decal guardado.
        decales.append({"nodo": "RunaSuelo", "textura": "res://assets/visual/objetos/runa_suelo.png", "posicion": [RUNA[0], RUNA[1]]})
    salas = []
    for i in range(5):
        objetos = extraer_objetos(i, originales[i], bases[i], visuales[i], arco)
        sueltas = asignar_colisiones(objetos, COLISIONES[i])
        marcadores = dict(MARCADORES)
        marcadores.update(MARCADORES_SALA[i])
        salas.append({
            "luz": ajustar_luz(bases[0], originales[i], bases[i], visuales[i]),
            "objetos": objetos, "colisiones": sueltas, "decales": decales,
            "marcadores": {k: list(v) for k, v in marcadores.items()},
        })
        print(f"sala {i}: {len(objetos)} objetos, {len(sueltas)} colisiones sueltas")
    DATOS.write_text(json.dumps({
        "tile": TILE, "origen": [FASE - TILE, FASE - TILE], "atlas_columnas": por_fila,
        "rejilla": rejilla, "salas": salas,
    }, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"{DATOS.relative_to(RAIZ)} escrito")


if __name__ == "__main__":
    main()
