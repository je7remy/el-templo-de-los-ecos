extends "res://scripts/vigilia/hud/pieza_vigilia.gd"
## Aviso breve al pie de la celda («Escudo: 8 segundos…», «¡Jefe!»…).
##
## Datos: texto, centro (punto de la línea del aviso).


func _draw() -> void:
    EV.pastilla(self, str(datos.get("texto", "")), datos.get("centro", Vector2.ZERO), 13, EV.ORO_CLARO)
