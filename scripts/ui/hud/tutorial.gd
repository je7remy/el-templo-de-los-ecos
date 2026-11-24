extends "res://scripts/ui/hud/pieza_hud.gd"
## Recuadro del paso actual del tutorial. Datos: «titulo», «texto», «t».


func _draw() -> void:
    var caja := Rect2(230, 146, 500, 52)
    var pulso: float = 0.5 + 0.5 * sin(tiempo() * 4.0)
    Estilo.panel(self, caja, Color(0.05, 0.06, 0.08, 0.93), Color(Estilo.ORO.r, Estilo.ORO.g, Estilo.ORO.b, 0.7 + 0.3 * pulso))
    Estilo.texto(self, str(d.get("titulo", "")), Vector2(caja.position.x, caja.position.y + 18.0), 11, Estilo.ORO, caja.size.x)
    Estilo.texto(self, str(d.get("texto", "")), Vector2(caja.position.x, caja.position.y + 40.0), 15, Estilo.CREMA, caja.size.x)
