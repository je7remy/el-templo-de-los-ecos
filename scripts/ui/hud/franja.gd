extends "res://scripts/ui/hud/pieza_hud.gd"
## Franja oscura en degradado detrás de la barra superior o del pie. Llega
## hasta los bordes reales de la pantalla (margen de las pantallas anchas).
## Datos: «rect», «arriba», «abajo».


func _draw() -> void:
    Estilo.degradado_v(self, d.get("rect", Rect2()), d.get("arriba", Color.BLACK), d.get("abajo", Color.BLACK))
