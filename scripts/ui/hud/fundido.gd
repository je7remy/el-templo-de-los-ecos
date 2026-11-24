extends "res://scripts/ui/hud/pieza_hud.gd"
## Fundido a negro de la sala al cruzar una puerta (por encima de los
## marcadores de la sala, por debajo del tutorial y los controles táctiles).
## Datos: «caja», «k» (0..1).


func _draw() -> void:
    var k: float = float(d.get("k", 0.0))
    draw_rect(d.get("caja", Rect2()), Color(0.01, 0.005, 0.015, k * k))
