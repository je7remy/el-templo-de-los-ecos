@tool
extends Control
## Párrafo con saltos de línea automáticos al ancho del nodo.

const Estilo := preload("res://scripts/ui/estilo.gd")

@export_multiline var texto: String = "":
    set(v):
        texto = v
        queue_redraw()
@export var tam: int = 15:
    set(v):
        tam = v
        queue_redraw()
@export var color: Color = Color("#d0c8b0"):
    set(v):
        color = v
        queue_redraw()


func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
    Estilo.parrafo(self, texto, Rect2(Vector2.ZERO, size), tam, color)
