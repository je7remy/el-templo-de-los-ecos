extends "res://scripts/pantallas/pantalla.gd"
## Base de las pantallas de la Vigilia (portada, fase superada, puerta
## cedida, pausa). Se dibujan encima de la celda con las piezas de
## estilo_vigilia.gd. De momento solo se ven: los toques y las teclas los sigue
## leyendo la Vigilia (scripts/defense.gd), así que no frenan los clics.

const EV := preload("res://scripts/ui/estilo_vigilia.gd")


func _init() -> void:
    super()
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


## Pulso de 0,2 a 1 que late con el tiempo de la Vigilia.
func pulso() -> float:
    return 0.6 + 0.4 * sin(float(datos.get("t", 0.0)) * 3.0)


## Velo sobre la celda (no tapa las barras de arriba y de abajo).
func velo(color: Color) -> void:
    draw_rect(Rect2(0, 64, EV.Estilo.ANCHO, 440), color)
