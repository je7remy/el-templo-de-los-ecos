extends "res://scripts/vigilia/pantallas/pantalla_vigilia.gd"
## La puerta ha cedido: hasta dónde llegaste.
##
## Datos: «fase», «entidades» (desterradas) y «puntos».


func _draw() -> void:
    velo(Color(0.1, 0, 0, 0.55))
    var panel := Rect2(160, 130, 640, 320)
    EV.modal(self, panel)
    EV.rotulo(self, "La puerta ha cedido", Vector2(160, 190), 44, Color("#ff8a8a"), panel.size.x)
    EV.centrado(self, "Llegaste a la fase %d   ·   Entidades: %d   ·   Puntos: %d" % [int(datos.get("fase", 1)), int(datos.get("entidades", 0)), int(datos.get("puntos", 0))], 246, 15, EV.CREMA)
    EV.centrado(self, "El botín de las fases superadas ya está en tu bolsa.", 280, 13, EV.ALMA)
    EV.centrado(self, "TOCA PARA EMPEZAR DE NUEVO   ·   ESC PARA VOLVER", 398, 15, EV.ORO_CLARO)
