@tool
extends Control
## Texto con el estilo del templo (pixel con borde, o rótulo gótico).
## Se centra en el ancho del nodo si «centrado» está activo. No recibe ratón.

const Estilo := preload("res://scripts/ui/estilo.gd")

@export_multiline var texto: String = "":
    set(v):
        texto = v
        queue_redraw()
@export var tam: int = 14:
    set(v):
        tam = v
        queue_redraw()
@export var color: Color = Color("#d9d2ba"):
    set(v):
        color = v
        queue_redraw()
@export var centrado: bool = true:
    set(v):
        centrado = v
        queue_redraw()
## Rótulo gótico (Jacquard 24) en vez de la letra pixel.
@export var gotico: bool = false:
    set(v):
        gotico = v
        queue_redraw()


func _ready() -> void:
    Estilo.preparar_fuentes()
    mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
    # La línea base queda a «tam» píxeles de la parte de arriba del nodo.
    var en := Vector2(0, float(tam))
    var ancho: float = size.x if centrado else -1.0
    if gotico:
        Estilo.titulo(self, texto, en, tam, color, ancho)
    else:
        Estilo.texto(self, texto, en, tam, color, ancho)
