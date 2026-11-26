extends "res://scripts/pantallas/pantalla.gd"
## El altar del Mercader: Resonancia y Llama Interior a cambio de almas.
##
## Datos: «ofertas» ([{icono, titulo, detalle, derecha, color_derecha}]),
## «almas», «icono_alma», «ayuda», «seleccion».
## Acciones: «comprar» (valor = 1 o 2) y «salir».
## Teclas: 1/2 comprar · ↑↓ elegir · ESC/E salir. Mando: A comprar, X 1, Y 2, B salir.

var seleccion: int = 0


func _al_entrar() -> void:
    seleccion = int(datos.get("seleccion", 0))


func rect_fila(i: int) -> Rect2:
    return Rect2(190.0, 262.0 + float(i) * 96.0, 580.0, 86.0)


func _draw() -> void:
    oscurecer(Color(0, 0, 0, 0.75))
    Estilo.panel(self, Rect2(164, 155, 632, 357), Color(0.05, 0.06, 0.08, 0.97), Estilo.ORO)
    Estilo.centrado(self, "EL MERCADER SILENCIOSO", 200, 26, Estilo.CREMA)
    Estilo.centrado(self, "«Todo préstamo tiene un dueño que no conoces.»", 232, 15, Estilo.ALMA)
    var ofertas: Array = datos.get("ofertas", [])
    for i in range(ofertas.size()):
        var fila := rect_fila(i)
        var o: Dictionary = ofertas[i]
        var sel: bool = seleccion == i
        Estilo.panel(self, fila, Color("#202a36") if sel else Color("#141922"), Estilo.ORO if sel else Estilo.BORDE)
        if o.get("icono") != null:
            draw_texture_rect(o["icono"], Rect2(fila.position + Vector2(12, 11), Vector2(64, 64)), false)
        Estilo.plano(self, str(o.get("titulo", "")), fila.position + Vector2(92, 32), 18, Estilo.CREMA)
        Estilo.plano(self, str(o.get("detalle", "")), fila.position + Vector2(92, 60), 13, Estilo.GRIS)
        draw_string(Estilo.fuente(), fila.position + Vector2(0, 32), Estilo.t(str(o.get("derecha", ""))), HORIZONTAL_ALIGNMENT_RIGHT, fila.size.x - 14.0, 15, o.get("color_derecha", Estilo.CREMA))
    if datos.get("icono_alma") != null:
        draw_texture_rect(datos["icono_alma"], Rect2(196, 464, 26, 26), false)
    Estilo.plano(self, "ALMAS: %d" % int(datos.get("almas", 0)), Vector2(228, 484), 16, Estilo.ALMA)
    Estilo.plano(self, str(datos.get("ayuda", "")), Vector2(600, 484), 14, Estilo.CREMA)


func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        for i in range(2):
            if rect_fila(i).has_point(event.position):
                seleccion = i
                queue_redraw()
    var en: Variant = clic_de(event)
    if en != null:
        accept_event()
        for i in range(2):
            if rect_fila(i).has_point(en):
                seleccion = i
                elegir(&"comprar", i + 1)
                return
        elegir(&"salir")


func _unhandled_input(event: InputEvent) -> void:
    if not is_visible_in_tree():
        return
    var k := tecla_de(event)
    var b := boton_de(event)
    var d := direccion(event)
    var hecho := true
    if k == KEY_1 or b == JOY_BUTTON_X:
        elegir(&"comprar", 1)
    elif k == KEY_2 or b == JOY_BUTTON_Y:
        elegir(&"comprar", 2)
    elif b == JOY_BUTTON_A:
        elegir(&"comprar", seleccion + 1)
    elif k in [KEY_ESCAPE, KEY_E] or b in [JOY_BUTTON_B, JOY_BUTTON_START]:
        elegir(&"salir")
    elif d != Vector2i.ZERO and k not in [KEY_E]:
        seleccion = clampi(seleccion + d.x + d.y, 0, 1)
    else:
        hecho = false
    if hecho:
        get_viewport().set_input_as_handled()
        queue_redraw()
