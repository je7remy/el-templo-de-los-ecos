extends Control
## Base de las piezas del HUD de la Vigilia (barras, aviso, tutorial, menú de
## la baldosa). Cada pieza se dibuja con los datos que le pasa la Vigilia
## (scripts/defense.gd) en actualizar(); no guarda estado de la partida.
## De momento no frenan los clics: la entrada la sigue leyendo la Vigilia.

const EV := preload("res://scripts/ui/estilo_vigilia.gd")
const Estilo := preload("res://scripts/ui/estilo.gd")

var datos: Dictionary = {}


func _init() -> void:
    size = Vector2(Estilo.ANCHO, Estilo.ALTO)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


## Datos nuevos (vacío = la pieza no se ve).
func actualizar(nuevos: Dictionary) -> void:
    datos = nuevos
    visible = not nuevos.is_empty()
    queue_redraw()


## Márgenes de las pantallas anchas (la celda va centrada).
func margen() -> Vector2:
    return datos.get("margen", Vector2.ZERO)


func fuente() -> Font:
    return Estilo.fuente()
