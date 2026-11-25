extends "res://scripts/vigilia/hud/pieza_vigilia.gd"
## Barra de abajo: lo que se usa a menudo (dormir, reparar la puerta,
## potenciar y escudo); el resto se toca en la celda. Con la celda vacía,
## una pista sobre ella.
##
## Datos: margen, acciones ([icono, nombre, detalle, se_puede] × 4),
## durmiendo, en_partida, raton, t y, con la celda vacía, pista (dónde va).

const PISTA := "Toca cualquier baldosa libre para construir · toca algo construido para mejorarlo"


## Botón «i» de la barra (0 dormir, 1 reparar, 2 potenciar, 3 escudo).
static func boton(i: int) -> Rect2:
    return Rect2(6.0 + float(i) * 238.0, 512.0, 230.0, 120.0)


func _draw() -> void:
    var m := margen()
    draw_rect(Rect2(-m.x, 504, Estilo.ANCHO + m.x * 2.0, Estilo.ALTO - 504 + m.y), Color(0.02, 0.018, 0.03, 0.95))
    draw_rect(Rect2(-m.x, 504, Estilo.ANCHO + m.x * 2.0, 2), EV.ORO)
    var en_partida: bool = bool(datos.get("en_partida", false))
    var durmiendo: bool = bool(datos.get("durmiendo", false))
    var raton: Vector2 = datos.get("raton", Vector2(-100, -100))
    var acciones: Array = datos.get("acciones", [])
    for i in range(acciones.size()):
        var r := boton(i)
        var it: Array = acciones[i]
        var encima: bool = r.has_point(raton)
        var puede: bool = bool(it[3]) and en_partida
        var brilla: bool = i == 0 and not durmiendo and en_partida
        EV.caja(self, r, Color("#2a1d36") if brilla else (Color("#241c2c") if encima else Color("#141018")), EV.ORO_CLARO if encima or brilla else (EV.ORO if puede else EV.BORDE))
        draw_texture_rect(EV.icono(it[0]), Rect2(r.position + Vector2(16, 24), Vector2(64, 64)), false, Color.WHITE if puede else Color(0.45, 0.45, 0.5, 0.8))
        draw_string(fuente(), r.position + Vector2(92, 52), it[1], HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 96.0, 15, EV.CREMA)
        draw_string(fuente(), r.position + Vector2(92, 76), ("TOCA" if DisplayServer.is_touchscreen_available() else it[2]) if i == 0 else it[2], HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 96.0, 12, EV.ALMA if puede else Color("#6d6772"))
    if datos.has("pista"):
        var a: float = 0.6 + 0.4 * sin(float(datos.get("t", 0.0)) * 3.0)
        EV.pastilla(self, PISTA, datos["pista"], 12, Color(EV.ORO_CLARO.r, EV.ORO_CLARO.g, EV.ORO_CLARO.b, a))
