extends "res://scripts/vigilia/pantallas/pantalla_vigilia.gd"
## Fase superada: el botín que se ganó para la campaña y cómo seguir.
##
## Datos: «t», «fase» (la superada) y «botin»: [[nombre, descripción, nivel
## 1-4, icono], …] (Catalogo.botin()).


func _draw() -> void:
    velo(Color(0, 0, 0, 0.6))
    var panel := Rect2(160, 96, 640, 400)
    EV.modal(self, panel)
    var fase: int = int(datos.get("fase", 1))
    EV.rotulo(self, "Fase %d superada" % fase, Vector2(160, 152), 44, EV.CREMA, panel.size.x)
    EV.centrado(self, "Botín para la campaña (ya está en tu bolsa):", 186, 14, EV.ALMA)
    var botin: Array = datos.get("botin", [])
    var n: int = botin.size()
    var t: float = float(datos.get("t", 0.0))
    for i in range(n):
        var o: Array = botin[i]
        var carta := Rect2(480.0 - float(n) * 140.0 + float(i) * 280.0 + 10.0, 206, 260, 170)
        var nivel: int = clampi(int(o[2]) - 1, 0, 3)
        var color: Color = EV.COLOR_NIVEL[nivel]
        EV.caja(self, carta, Color("#141018"), color)
        var brillo: float = 0.5 + 0.5 * sin(t * 3.0 + float(i))
        draw_circle(carta.position + Vector2(carta.size.x * 0.5, 50), 34.0, Color(color.r, color.g, color.b, 0.08 + 0.06 * brillo))
        var tex: Texture2D = EV.icono(str(o[3])) if ResourceLoader.exists("res://assets/visual/iconos/%s.png" % str(o[3])) else null
        if tex != null:
            draw_texture_rect(tex, Rect2(carta.position + Vector2(carta.size.x * 0.5 - 28.0, 22), Vector2(56, 56)), false)
        EV.en_caja(self, str(o[0]), Rect2(carta.position.x, carta.position.y + 88.0, carta.size.x, 18), 15, EV.CREMA)
        draw_multiline_string(EV.Estilo.fuente(), carta.position + Vector2(14, 128), str(o[1]), HORIZONTAL_ALIGNMENT_CENTER, carta.size.x - 28.0, 12, 2, EV.ALMA)
        EV.en_caja(self, EV.NOMBRE_NIVEL[nivel], Rect2(carta.position.x, carta.end.y - 22.0, carta.size.x, 14), 11, color)
    var p: float = pulso()
    EV.centrado(self, "TOCA O PULSA ENTER: FASE %d%s" % [fase + 1, " (JEFE)" if (fase + 1) % 5 == 0 else ""], 418, 18, Color(EV.ORO_CLARO.r, EV.ORO_CLARO.g, EV.ORO_CLARO.b, p))
    EV.centrado(self, "ESC o SALIR: volver con lo ganado", 452, 12, EV.CREMA)
