extends "res://scripts/pantallas/pantalla.gd"
## Habilidades (izquierda) y Ecos de cada piso (derecha), por páginas para
## que nunca se salgan del cuadro. La campaña reparte las filas por página.
##
## Datos: «filas» (de esta página: {icono, nombre, tecla, detalle, tiene,
## coste}), «ecos» ({icono, nombre, detalle, tiene}), «vacia» (no hay
## habilidades en esta página), «resumen_ecos», «pagina», «paginas»,
## «arriba», «alto_fila», «alto_eco», «tecla_habilidades», «ayuda».
## Acciones: «pagina» (valor = +1/−1) y «cerrar».

const BOTON_ANTERIOR := Rect2(372, 546, 48, 34)
const BOTON_SIGUIENTE := Rect2(540, 546, 48, 34)

var _raton: Vector2 = Vector2(-100, -100)


func _draw() -> void:
    oscurecer(Color(0, 0, 0, 0.8))
    Estilo.panel(self, Rect2(70, 46, 820, 548), Color(0.05, 0.05, 0.075, 0.97), Estilo.ORO)
    Estilo.panel(self, Rect2(360, 34, 240, 30), Color("#241a30"), Estilo.ORO)
    Estilo.titulo(self, "Habilidades", Vector2(360, 58), 24, Estilo.CREMA, 240.0)
    Estilo.texto(self, "ACTIVAS Y PROPIAS", Vector2(96, 92), 13, Estilo.ORO)
    var arriba: float = float(datos.get("arriba", 102.0))
    var alto_fila: float = float(datos.get("alto_fila", 84.0))
    var alto_eco: float = float(datos.get("alto_eco", 70.0))
    var filas: Array = datos.get("filas", [])
    var apagado := Color("#5d5a52")
    for i in range(filas.size()):
        var f: Dictionary = filas[i]
        var r := Rect2(96, arriba + float(i) * alto_fila, 420, 76)
        var tiene: bool = bool(f.get("tiene", false))
        Estilo.panel(self, r, Color("#141922") if tiene else Color("#0e1015"), Estilo.BORDE if tiene else Color("#24262c"))
        if f.get("icono") != null:
            draw_texture_rect(f["icono"], Rect2(r.position + Vector2(10, 14), Vector2(48, 48)), false, Color.WHITE if tiene else Color(0.12, 0.12, 0.14, 0.9))
        Estilo.texto(self, str(f.get("nombre", "")) if tiene else "???", Vector2(r.position.x + 70.0, r.position.y + 22.0), 14, Estilo.CREMA if tiene else apagado)
        var tecla: String = str(f.get("tecla", ""))
        var kw: float = Estilo.fuente().get_string_size(tecla, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x + 14.0
        Estilo.panel(self, Rect2(r.end.x - kw - 10.0, r.position.y + 8.0, kw, 18), Color("#1d2230"), Estilo.ORO if tiene else Estilo.BORDE)
        Estilo.texto(self, tecla, Vector2(r.end.x - kw - 10.0, r.position.y + 22.0), 11, Estilo.ORO if tiene else apagado, kw)
        draw_multiline_string(Estilo.fuente(), r.position + Vector2(70, 42), str(f.get("detalle", "")) if tiene else "Aún no la tienes.", HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 84.0, 11, 2, Estilo.GRIS if tiene else apagado)
        if tiene:
            Estilo.texto(self, str(f.get("coste", "")), Vector2(r.position.x + 70.0, r.end.y - 6.0), 10, Estilo.ALMA)
    Estilo.texto(self, "ECOS · PASIVAS DE CADA PISO", Vector2(540, 92), 13, Estilo.ORO)
    var ecos: Array = datos.get("ecos", [])
    for i in range(ecos.size()):
        var e: Dictionary = ecos[i]
        var r := Rect2(540, arriba + float(i) * alto_eco, 324, 62)
        var tiene: bool = bool(e.get("tiene", false))
        Estilo.panel(self, r, Color("#141922"), Color("#3b6f7d") if tiene else Estilo.BORDE)
        if e.get("icono") != null:
            draw_texture_rect(e["icono"], Rect2(r.position + Vector2(10, 15), Vector2(32, 32)), false, Color.WHITE if tiene else Color(0.15, 0.15, 0.18, 0.9))
        Estilo.texto(self, str(e.get("nombre", "")) if tiene else "ECO SIN DESPERTAR", Vector2(r.position.x + 52.0, r.position.y + 22.0), 12, Estilo.ALMA if tiene else apagado)
        draw_multiline_string(Estilo.fuente(), r.position + Vector2(52, 40), str(e.get("detalle", "")) if tiene else "???", HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 60.0, 10, 2, Color("#9a957f"))
    if bool(datos.get("vacia", false)):
        Estilo.texto(self, "Tus habilidades están en la página 1.", Vector2(96, arriba + 20.0), 12, Color("#8a8574"))
    Estilo.texto(self, str(datos.get("resumen_ecos", "")), Vector2(540, arriba + float(ecos.size()) * alto_eco + 14.0), 11, Color("#8a8574"))
    var paginas: int = int(datos.get("paginas", 1))
    if paginas > 1:
        for b in [[BOTON_ANTERIOR, "<"], [BOTON_SIGUIENTE, ">"]]:
            var r: Rect2 = b[0]
            Estilo.panel(self, r, Color("#241a30") if r.has_point(_raton) else Color("#141922"), Estilo.ORO)
            Estilo.texto(self, b[1], Vector2(r.position.x, r.position.y + 23.0), 18, Estilo.CREMA, r.size.x)
        Estilo.texto(self, "PÁGINA %d / %d" % [int(datos.get("pagina", 0)) + 1, paginas], Vector2(420, 568), 13, Estilo.ORO, 120.0)
    Estilo.texto(self, str(datos.get("ayuda", "")), Vector2(96, 590), 11, Color("#8a8574"), 768.0)


func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        _raton = event.position
        queue_redraw()
        return
    if event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
        accept_event()
        elegir(&"pagina", 1 if event.button_index == MOUSE_BUTTON_WHEEL_DOWN else -1)
        return
    var en: Variant = clic_de(event)
    if en == null:
        return
    accept_event()
    var varias: bool = int(datos.get("paginas", 1)) > 1
    if varias and BOTON_ANTERIOR.grow(8.0).has_point(en):
        elegir(&"pagina", -1)
    elif varias and BOTON_SIGUIENTE.grow(8.0).has_point(en):
        elegir(&"pagina", 1)
    else:
        elegir(&"cerrar")


func _unhandled_input(event: InputEvent) -> void:
    if not is_visible_in_tree():
        return
    var k := tecla_de(event)
    var b := boton_de(event)
    var hecho := true
    if k in [int(datos.get("tecla_habilidades", KEY_K)), KEY_ESCAPE, KEY_E, KEY_K] or b in [JOY_BUTTON_A, JOY_BUTTON_B, JOY_BUTTON_RIGHT_SHOULDER, JOY_BUTTON_START]:
        elegir(&"cerrar")
    elif k in [KEY_PAGEDOWN, KEY_TAB] or b == JOY_BUTTON_LEFT_SHOULDER:
        elegir(&"pagina", 1)
    elif k == KEY_PAGEUP:
        elegir(&"pagina", -1)
    else:
        var d := direccion(event)
        if d in [Vector2i.RIGHT, Vector2i.DOWN]:
            elegir(&"pagina", 1)
        elif d in [Vector2i.LEFT, Vector2i.UP]:
            elegir(&"pagina", -1)
        else:
            hecho = false
    if hecho:
        get_viewport().set_input_as_handled()
