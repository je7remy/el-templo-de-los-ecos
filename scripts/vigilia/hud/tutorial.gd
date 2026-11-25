extends "res://scripts/vigilia/hud/pieza_vigilia.gd"
## Tutorial guiado: el recuadro que señala qué tocar, con su flecha, y la
## tarjeta del paso (título, número, texto y SALTAR o «toca aquí»).
##
## Datos: objetivo (Rect2; vacío = nada que señalar), t, destello (0-1),
## titulo, texto, paso (desde 0), total, de_leer (paso que avanza al tocar
## la tarjeta).

const TARJETA := Rect2(726, 72, 226, 156)
const SALTAR := Rect2(822, 192, 122, 28)


func _draw() -> void:
    var t: float = float(datos.get("t", 0.0))
    var objetivo: Rect2 = datos.get("objetivo", Rect2())
    var a: float = 0.55 + 0.45 * sin(t * 6.0)
    if objetivo.size != Vector2.ZERO:
        draw_rect(objetivo.grow(4.0), Color(1.0, 0.85, 0.4, a), false, 3.0)
        var punta := Vector2(objetivo.get_center().x, objetivo.position.y - 6.0 - 6.0 * absf(sin(t * 4.0)))
        if objetivo.position.y < 110.0:
            punta = Vector2(objetivo.get_center().x, objetivo.end.y + 6.0 + 6.0 * absf(sin(t * 4.0)))
            draw_colored_polygon(PackedVector2Array([punta, punta + Vector2(-10, 16), punta + Vector2(10, 16)]), EV.ORO_CLARO)
        else:
            draw_colored_polygon(PackedVector2Array([punta, punta + Vector2(-10, -16), punta + Vector2(10, -16)]), EV.ORO_CLARO)
    var r := TARJETA
    EV.caja(self, r, Color(0.05, 0.04, 0.07, 0.96), EV.ORO_CLARO.lerp(Color.WHITE, float(datos.get("destello", 0.0))))
    EV.etiqueta(self, str(datos.get("titulo", "")), r.position + Vector2(12, 22), 15, EV.ORO_CLARO)
    EV.etiqueta(self, "%d/%d" % [int(datos.get("paso", 0)) + 1, int(datos.get("total", 1))], r.position + Vector2(r.size.x - 44.0, 22), 11, EV.APAGADO)
    draw_multiline_string(fuente(), r.position + Vector2(10, 44), str(datos.get("texto", "")), HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 18.0, 13, 6, EV.CREMA)
    if bool(datos.get("de_leer", false)):
        EV.etiqueta(self, "▶ TOCA AQUÍ / ENTER", r.position + Vector2(12, r.size.y - 12.0), 11, Color(EV.ALMA.r, EV.ALMA.g, EV.ALMA.b, a))
    else:
        EV.caja(self, SALTAR, Color("#141018"), EV.BORDE)
        EV.en_caja(self, "SALTAR", Rect2(SALTAR.position.x, SALTAR.position.y + 6.0, SALTAR.size.x, 14), 11, EV.APAGADO)
