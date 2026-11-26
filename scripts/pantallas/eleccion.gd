extends "res://scripts/pantallas/pantalla.gd"
## Elección con dos (o más) opciones, p. ej. guiar o no a los peregrinos.
##
## Datos: «quien», «texto», «opciones» ([[id, título, detalle], …]), «ayuda»,
## «tecla_interactuar».
## Acciones: «opcion» (valor = índice) y «cancelar».
## Teclas: ←→ ↑↓ TAB elegir · ENTER/E aceptar · 1, 2… directo · ESC pensarlo.

const PANEL := Rect2(170, 170, 620, 300)

var seleccion: int = 0


func _al_entrar() -> void:
    seleccion = 0


func rect_opcion(i: int) -> Rect2:
    return Rect2(196.0 + float(i) * 292.0, 330.0, 276.0, 110.0)


func _n() -> int:
    return (datos.get("opciones", []) as Array).size()


func _draw() -> void:
    oscurecer(Color(0, 0, 0, 0.62))
    Estilo.panel(self, PANEL, Color(0.04, 0.035, 0.05, 0.97), Estilo.ORO)
    Estilo.texto(self, str(datos.get("quien", "")), Vector2(PANEL.position.x, PANEL.position.y + 34.0), 16, Estilo.ORO, PANEL.size.x)
    draw_multiline_string(Estilo.fuente(), Vector2(PANEL.position.x + 30.0, PANEL.position.y + 66.0), Estilo.t(str(datos.get("texto", ""))), HORIZONTAL_ALIGNMENT_CENTER, PANEL.size.x - 60.0, 15, 4, Estilo.CREMA)
    var opciones: Array = datos.get("opciones", [])
    for i in range(opciones.size()):
        var r := rect_opcion(i)
        var sel: bool = i == seleccion
        var buena: bool = i == 0
        Estilo.panel(self, r, (Color("#1f3326") if buena else Color("#3a1a20")) if sel else Color("#141018"), (Color("#7fd6a0") if buena else Estilo.CARMESI) if sel else Estilo.BORDE)
        Estilo.texto(self, "[%d] %s" % [i + 1, opciones[i][1]], Vector2(r.position.x, r.position.y + 36.0), 17, Estilo.CREMA, r.size.x)
        draw_multiline_string(Estilo.fuente(), Vector2(r.position.x + 14.0, r.position.y + 62.0), Estilo.t(str(opciones[i][2])), HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 28.0, 12, 3, Estilo.GRIS)
    Estilo.texto(self, str(datos.get("ayuda", "")), Vector2(PANEL.position.x, PANEL.end.y - 14.0), 11, Color("#8a8574"), PANEL.size.x)


func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        for i in range(_n()):
            if rect_opcion(i).has_point(event.position):
                seleccion = i
                queue_redraw()
    var en: Variant = clic_de(event)
    if en != null:
        accept_event()
        for i in range(_n()):
            if rect_opcion(i).has_point(en):
                elegir(&"opcion", i)
                return


func _unhandled_input(event: InputEvent) -> void:
    if not is_visible_in_tree() or _n() == 0:
        return
    var k := tecla_de(event)
    var b := boton_de(event)
    var d := direccion(event)
    var hecho := true
    if k == KEY_ESCAPE or b == JOY_BUTTON_B:
        elegir(&"cancelar")
    elif k in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_E, int(datos.get("tecla_interactuar", KEY_E))] or b == JOY_BUTTON_A:
        elegir(&"opcion", seleccion)
    elif k >= KEY_1 and k < KEY_1 + _n():
        elegir(&"opcion", k - KEY_1)
    elif k == KEY_TAB or d in [Vector2i.RIGHT, Vector2i.DOWN]:
        seleccion = (seleccion + 1) % _n()
    elif d in [Vector2i.LEFT, Vector2i.UP]:
        seleccion = (seleccion + _n() - 1) % _n()
    else:
        hecho = false
    if hecho:
        get_viewport().set_input_as_handled()
        queue_redraw()
