extends "res://scripts/ui/hud/pieza_hud.gd"
## Rótulo de misión que aparece y se desvanece en el centro de la sala.
## Datos: «texto», «alfa».


func _draw() -> void:
    var a: float = float(d.get("alfa", 1.0))
    var caja := Rect2(220, 186, 520, 44)
    Estilo.panel(self, caja, Color(0.08, 0.07, 0.04, 0.92 * a), Color(Estilo.ORO.r, Estilo.ORO.g, Estilo.ORO.b, a))
    Estilo.texto(self, str(d.get("texto", "")), Vector2(caja.position.x, caja.position.y + 28.0), 15, Color(Estilo.CREMA.r, Estilo.CREMA.g, Estilo.CREMA.b, a), caja.size.x)
