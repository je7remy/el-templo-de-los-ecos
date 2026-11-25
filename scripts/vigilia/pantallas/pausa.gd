extends "res://scripts/vigilia/pantallas/pantalla_vigilia.gd"
## Vigilia en pausa.


func _draw() -> void:
    EV.modal(self, Rect2(240, 200, 480, 150))
    EV.rotulo(self, "En pausa", Vector2(240, 262), 40, EV.CREMA, 480.0)
    EV.centrado(self, "Toca PAUSA o pulsa P para seguir", 312, 15, EV.ORO_CLARO)
