@tool
extends Control
## Panel con el estilo del templo (fondo, filete y esquinas ornamentadas).
## Opcionalmente, una segunda línea interior. No recibe ratón.

const Estilo := preload("res://scripts/ui/estilo.gd")

@export var relleno: Color = Color(0.035, 0.03, 0.045, 0.84):
    set(v):
        relleno = v
        queue_redraw()
@export var borde: Color = Color("#2f2a35"):
    set(v):
        borde = v
        queue_redraw()
## Línea interior a 8 px del borde (transparente = sin línea).
@export var linea_interior: Color = Color(0, 0, 0, 0):
    set(v):
        linea_interior = v
        queue_redraw()


func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
    var r := Rect2(Vector2.ZERO, size)
    Estilo.panel(self, r, relleno, borde)
    if linea_interior.a > 0.0:
        draw_rect(r.grow(-8.0), linea_interior, false, 1.0)
