@tool
extends Control
## Filete ornamental dorado con rombo central, a lo ancho del nodo.

const Estilo := preload("res://scripts/ui/estilo.gd")


func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
    Estilo.adorno(self, Vector2(size.x * 0.5, roundf(size.y * 0.5)), size.x * 0.5)
