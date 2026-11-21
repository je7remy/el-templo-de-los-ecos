#!/usr/bin/env python3
"""Coloca los objetos de las cinco salas de forma SIMÉTRICA (paso 1b).

Eje: x = 480, el centro entre los muros (sala de 68 a 895 px). Cada objeto
va en el eje o en pareja con su reflejo: el de la derecha usa la misma
textura volteada (flip), así que la pareja es un espejo exacto. Las
colisiones se reflejan con el objeto. También coloca en espejo las tres
almas (izquierda, centro, derecha) y los objetos de juego que van en el eje
(altar, libro, sello, ojo).

Modifica herramientas/salas.json. Después: construir_salas.gd (paso 2).
  python3 herramientas/simetrizar_salas.py
  godot --headless --path . --script res://herramientas/construir_salas.gd

construir_salas.py lo aplica automáticamente al terminar.
"""
from __future__ import annotations

import copy
import json
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
DATOS = RAIZ / "herramientas" / "salas.json"
EJE = 480.0

# Disposición por sala: (objeto plantilla, centro x del dibujo, base y, pareja)
# Con pareja=True se coloca en x y su espejo en 960 - x.
DISPOSICION = {
    0: [("Brasero1", 88, 226, True), ("EstatuaArquero1", 202, 279, True), ("EstatuaOrante1", EJE, 225, False),
        ("Columna1", 330, 382, True), ("EstatuaPedestal1", EJE, 425, False)],
    1: [("Brasero1", 88, 226, True), ("EstatuaOrante1", 204, 225, True), ("EstatuaArquero1", EJE, 279, False),
        ("Columna1", 340, 416, True)],
    2: [("Brasero1", 88, 226, True), ("EstatuaArquero1", 202, 279, True), ("EstatuaOrante1", EJE, 225, False),
        ("Columna1", 339, 381, True), ("EstatuaPedestal1", EJE, 470, False)],
    3: [("Brasero1", 88, 226, True), ("EstatuaOrante1", 204, 225, True), ("EstatuaArquero1", EJE, 279, False),
        ("Mesa1", EJE, 345, False), ("Columna1", 375, 427, True),
        # Grupo de cirios: los cuatro de la izquierda y su espejo.
        ("Cirios3", 960 - 641, 416, True), ("Cirios1", 960 - 661, 415, True),
        ("Cirios2", 960 - 680, 415, True), ("Cirios4", 960 - 700, 416, True)],
    4: [("Brasero1", 88, 226, True), ("EstatuaArquero1", 202, 279, True), ("EstatuaOrante1", EJE, 225, False),
        ("ColumnaRota1", 396, 302, True), ("Sarcofago1", EJE, 474, False), ("Columna1", 279, 493, True)],
}
# Colisiones sueltas (no pertenecen a un solo objeto): centro, tamaño, pareja.
SUELTAS = {
    1: [((EJE, 318), (50, 36), False)],          # altar
    3: [((290, 370), (70, 60), True)],           # grupos de cirios
}
# Marcadores: almas en espejo (izquierda, centro, derecha) y objetos en el eje.
MARCADORES = {
    0: {"Reliquia1": (290, 230), "Reliquia2": (EJE, 520), "Reliquia3": (670, 230), "Madera": (300, 470), "Fosforos": (660, 470)},
    1: {"Reliquia1": (290, 245), "Reliquia2": (EJE, 480), "Reliquia3": (670, 245), "Altar": (EJE, 318)},
    2: {"Reliquia1": (290, 245), "Reliquia2": (EJE, 525), "Reliquia3": (670, 245), "Sello": (EJE, 330), "Ojo": (EJE, 143)},
    3: {"Reliquia1": (290, 245), "Reliquia2": (EJE, 500), "Reliquia3": (670, 245), "Libro": (EJE, 310), "Lectura": (EJE, 362)},
    4: {"Reliquia1": (290, 245), "Reliquia2": (EJE, 380), "Reliquia3": (670, 245)},
}


def colocar(plantilla: dict, cx: float, base: float, nombre: str, espejo: bool) -> dict:
    o = copy.deepcopy(plantilla)
    x0, y0, w, h = plantilla["caja"]
    # Borde izquierdo en un píxel entero: el espejo (960 - x - w) también lo es.
    dx = round(cx - w / 2.0) - x0
    dy = base - plantilla["ancla"][1]
    o["nodo"] = nombre
    o["ancla"] = [plantilla["ancla"][0] + dx, plantilla["ancla"][1] + dy]
    o["caja"] = [x0 + dx, y0 + dy, w, h]
    if "colision" in o:
        cc = o["colision"]["centro"]
        o["colision"]["centro"] = [cc[0] + dx, cc[1] + dy]
    o["flip"] = False
    if espejo:
        # Reflejo exacto: x' = 960 - x. Con flip, el dibujo se invierte dentro
        # del mismo rectángulo, así que el offset pasa a -(offset + ancho).
        o["ancla"][0] = 2 * EJE - o["ancla"][0]
        o["offset"] = [-(o["offset"][0] + w), o["offset"][1]]
        o["caja"][0] = 2 * EJE - (o["caja"][0] + w)
        if "colision" in o:
            o["colision"]["centro"][0] = 2 * EJE - o["colision"]["centro"][0]
        o["flip"] = True
    for k in ("ancla", "caja"):
        o[k] = [round(v, 1) for v in o[k]]
    return o


def simetrizar(datos: dict) -> None:
    for i, sala in enumerate(datos["salas"]):
        plantillas = {o["nodo"]: o for o in sala["objetos"]}
        nuevos, cuenta = [], {}
        for nodo, cx, base, pareja in DISPOSICION[i]:
            if nodo not in plantillas:
                raise SystemExit(f"sala {i}: falta la plantilla {nodo}")
            tipo = nodo.rstrip("0123456789")
            for espejo in ((False, True) if pareja else (False,)):
                cuenta[tipo] = cuenta.get(tipo, 0) + 1
                nuevos.append(colocar(plantillas[nodo], cx, base, f"{tipo}{cuenta[tipo]}", espejo))
        sala["objetos"] = nuevos
        sueltas = []
        for (cx, cy), tam, pareja in SUELTAS.get(i, []):
            sueltas.append({"centro": [cx, cy], "tamano": list(tam)})
            if pareja:
                sueltas.append({"centro": [2 * EJE - cx, cy], "tamano": list(tam)})
        sala["colisiones"] = sueltas
        for k, v in MARCADORES.get(i, {}).items():
            sala["marcadores"][k] = list(v)
        # La runa del suelo, centrada en el eje (su dibujo ocupa x 11-132 del PNG).
        for decal in sala["decales"]:
            if decal["nodo"] == "RunaSuelo":
                decal["posicion"][0] = int(EJE - (11 + 132 + 1) / 2)


def aplicar() -> None:
    datos = json.loads(DATOS.read_text(encoding="utf-8"))
    if datos.get("simetrica"):
        # Las plantillas se buscan por nombre en los objetos extraídos; tras
        # simetrizar cambian de nombre, así que solo se aplica una vez.
        print(f"{DATOS.relative_to(RAIZ)} ya está en simetría: nada que hacer")
        return
    simetrizar(datos)
    datos["simetrica"] = True
    DATOS.write_text(json.dumps(datos, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"{DATOS.relative_to(RAIZ)}: objetos colocados en simetría (eje x = {EJE:g})")


if __name__ == "__main__":
    aplicar()
