extends "res://scripts/ui/hud/pieza_hud.gd"
## Pie de pantalla: el objetivo de la sala y, con teclado o mando, los atajos.
## Datos: «texto», «color», «atajos» ("" en pantallas táctiles).


func _draw() -> void:
    Estilo.panel(self, Rect2(8, 580, 568, 34))
    draw_colored_polygon(PackedVector2Array([Vector2(22, 597), Vector2(28, 591), Vector2(34, 597), Vector2(28, 603)]), Estilo.ORO)
    Estilo.texto(self, str(d.get("texto", "")), Vector2(42, 603), 15, d.get("color", Estilo.CREMA))
    var atajos: String = str(d.get("atajos", ""))
    if atajos != "":
        Estilo.texto(self, atajos, Vector2(12, 632), 10, Color("#8d8877"))
