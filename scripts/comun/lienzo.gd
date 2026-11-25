extends RefCounted
## Ayudas de dibujo del mundo, compartidas por la campaña y las escenas de
## las entidades. Las escenas dibujan su parte sobre el lienzo del mundo (el
## nodo de la campaña) mientras este se dibuja, para respetar el orden por
## profundidad (lo de abajo tapa a lo de arriba); «c» es ese lienzo.
##
## El lienzo tiene una transformación base del mundo (draw_base_xf: cámara y
## sacudida); xf() compone encima.

## Celda de las hojas de 48 × 64 de las entidades y altura de sus pies.
const CELDA := Vector2(48.0, 64.0)
const PIES := 61.0


static func xf(c: CanvasItem, pos: Vector2, rot: float, scl: Vector2) -> void:
    c.draw_set_transform_matrix((c.get("draw_base_xf") as Transform2D) * Transform2D(rot, scl, 0.0, pos))


static func elipse(c: CanvasItem, centro: Vector2, rx: float, ry: float, color: Color) -> void:
    xf(c, centro, 0.0, Vector2(1.0, ry / rx))
    c.draw_circle(Vector2.ZERO, rx, color)
    xf(c, Vector2.ZERO, 0.0, Vector2.ONE)


## Sombra suave bajo los pies.
static func sombra(c: CanvasItem, en: Vector2, rx: float, fuerza: float = 1.0) -> void:
    for i in range(3):
        var k: float = 1.0 - float(i) * 0.28
        elipse(c, en, rx * k, rx * k * 0.32, Color(0.0, 0.0, 0.0, 0.13 * fuerza))


## Sprite con contorno oscuro de un píxel (de la escala del dibujo).
static func contorno(c: CanvasItem, tex: Texture2D, dest: Rect2, region: Rect2, tinte: Color) -> void:
    var px: float = maxf(1.0, roundf(dest.size.x / maxf(1.0, region.size.x)))
    var oc := Color(0.03, 0.02, 0.05, 0.9 * tinte.a)
    for o in [Vector2(px, 0), Vector2(-px, 0), Vector2(0, px), Vector2(0, -px)]:
        c.draw_texture_rect_region(tex, Rect2(dest.position + o, dest.size), region, oc)
    c.draw_texture_rect_region(tex, dest, region, tinte)
