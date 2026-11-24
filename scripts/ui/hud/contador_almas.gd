extends "res://scripts/ui/hud/pieza_hud.gd"
## Almas de la sala recogidas, en la esquina de la sala.
## Datos: «caja», «recogidas», «total», «icono».


func _draw() -> void:
    var caja: Rect2 = d.get("caja", Rect2())
    var recogidas: int = int(d.get("recogidas", 0))
    var total: int = int(d.get("total", 0))
    Estilo.panel(self, caja, Color(0.035, 0.03, 0.045, 0.7), Estilo.BORDE)
    if d.get("icono") != null:
        draw_texture_rect(d["icono"], Rect2(caja.position + Vector2(6, 2), Vector2(20, 20)), false)
    Estilo.texto(self, "ALMAS %d/%d" % [recogidas, total], Vector2(caja.position.x + 30.0, caja.position.y + 17.0), 12, Estilo.ALMA if recogidas == total else Estilo.CREMA)
