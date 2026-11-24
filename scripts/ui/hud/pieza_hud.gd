extends Control
## Base de las piezas del HUD (scenes/ui/hud.tscn). Cada pieza dibuja una
## parte de la interfaz de la partida con los datos que le da la campaña y no
## sabe nada más del juego. Sin datos, la pieza no se ve.
##
## Las piezas no atienden la entrada: los toques sobre el HUD (retrato, pausa,
## minimapa, habilidades, joystick) los sigue resolviendo main.gd.

const Estilo := preload("res://scripts/ui/estilo.gd")
const ICONO_ORO := Color("#ffd36b")

var d: Dictionary = {}


func _init() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    size = Vector2(Estilo.ANCHO, Estilo.ALTO)


func poner(datos: Dictionary) -> void:
    d = datos
    visible = not d.is_empty()
    if visible:
        queue_redraw()


func tiempo() -> float:
    return float(d.get("t", 0.0))
