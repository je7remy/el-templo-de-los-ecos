extends "res://scripts/pantallas/pantalla.gd"
## Resumen al superar un piso: tiempo, almas, muertes, misiones… el Eco
## ganado y la verdad que revela el piso.
##
## Datos: «numero», «titulo», «filas» ([[nombre, valor], …]), «eco_icono»,
## «eco_texto», «eco_detalle», «verdad», «ayuda».
## Acción: «seguir» (ENTER, ESPACIO, E, ESC, A, B, clic o toque).

var _t: float = 0.0


func actualizar(delta: float) -> void:
    _t += delta
    queue_redraw()


func _draw() -> void:
    oscurecer(Color(0.012, 0.01, 0.02, 0.82))
    var panel := Rect2(170, 70, 620, 500)
    Estilo.panel(self, panel, Color(0.035, 0.03, 0.045, 0.96), Estilo.ORO)
    Estilo.titulo(self, "Piso %s superado" % str(datos.get("numero", "")), Vector2(170, 124), 48, Estilo.CREMA, panel.size.x)
    Estilo.texto(self, str(datos.get("titulo", "")), Vector2(170, 150), 15, Estilo.ORO, panel.size.x)
    Estilo.adorno(self, Vector2(480, 166), 200.0)
    var filas: Array = datos.get("filas", [])
    for i in range(filas.size()):
        var y: float = 200.0 + float(i) * 34.0
        Estilo.texto(self, str(filas[i][0]), Vector2(230, y), 15, Estilo.GRIS)
        Estilo.texto(self, str(filas[i][1]), Vector2(520, y), 15, Estilo.CREMA, 210.0)
        draw_rect(Rect2(230, y + 9.0, 500, 1), Color(Estilo.ORO.r, Estilo.ORO.g, Estilo.ORO.b, 0.15))
    var icono: Texture2D = datos.get("eco_icono", null)
    if str(datos.get("eco_texto", "")) != "":
        if icono != null:
            draw_texture_rect(icono, Rect2(230, 408, 32, 32), false)
        Estilo.texto(self, str(datos["eco_texto"]), Vector2(272, 422), 14, Estilo.ALMA)
        Estilo.texto(self, str(datos.get("eco_detalle", "")), Vector2(272, 440), 11, Color("#9a957f"))
    if str(datos.get("verdad", "")) != "":
        Estilo.texto(self, "VERDAD REVELADA", Vector2(230, 476), 11, Estilo.ORO)
        draw_multiline_string(Estilo.fuente(), Vector2(230, 496), "«%s»" % datos["verdad"], HORIZONTAL_ALIGNMENT_LEFT, 500.0, 15, 2, Estilo.CREMA)
    var pulso: float = 0.5 + 0.5 * sin(_t * 4.0)
    Estilo.texto(self, str(datos.get("ayuda", "")), Vector2(170, 552), 13, Color(Estilo.ORO.r, Estilo.ORO.g, Estilo.ORO.b, 0.5 + 0.5 * pulso), panel.size.x)


func _gui_input(event: InputEvent) -> void:
    if clic_de(event) != null:
        accept_event()
        elegir(&"seguir")


func _unhandled_input(event: InputEvent) -> void:
    if is_visible_in_tree() and (tecla_de(event) in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_E, KEY_ESCAPE] or boton_de(event) in [JOY_BUTTON_A, JOY_BUTTON_B, JOY_BUTTON_START]):
        get_viewport().set_input_as_handled()
        elegir(&"seguir")
