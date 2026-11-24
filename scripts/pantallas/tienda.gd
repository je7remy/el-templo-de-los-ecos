extends "res://scripts/pantallas/pantalla.gd"
## El puesto del Mercader Silencioso. Antes de vender la llave de la Vigilia
## explica qué abre (ficha «info»).
##
## Datos: «nota», «filas» ([{icono, nombre, detalle, derecha, color_derecha,
## tenue, llevas, destello}]), «almas», «icono_alma», «vida», «color_vida»,
## «ayuda», «seleccion», «info» (ficha abierta), «ficha» {icono, filas,
## precio, puede, almas}, «tecla_interactuar».
## Acciones: «elegir» (valor = fila), «info_si», «info_no», «salir».

const PANEL := Rect2(150, 86, 660, 494)
const FICHA := Rect2(170, 96, 620, 474)

var seleccion: int = 0
var _raton: Vector2 = Vector2(-100, -100)


func _al_entrar() -> void:
    seleccion = int(datos.get("seleccion", 0))


func rect_fila(i: int) -> Rect2:
    return Rect2(180, 182 + float(i) * 55.0, 600, 51)


func rect_boton_ficha(i: int) -> Rect2:
    return Rect2(230 + float(i) * 260.0, 500, 240, 50)


func _n() -> int:
    return (datos.get("filas", []) as Array).size()


func _draw() -> void:
    oscurecer(Color(0, 0, 0, 0.75))
    Estilo.panel(self, PANEL, Color(0.05, 0.045, 0.06, 0.97), Estilo.ORO)
    Estilo.titulo(self, "El Mercader Silencioso", Vector2(150, 134), 40, Estilo.CREMA, PANEL.size.x)
    Estilo.texto(self, "Se paga primero. No se toca el manto." + str(datos.get("nota", "")), Vector2(150, 164), 13, Color("#d1747b"), PANEL.size.x)
    var filas: Array = datos.get("filas", [])
    for i in range(filas.size()):
        var fila := rect_fila(i)
        var f: Dictionary = filas[i]
        var sel: bool = seleccion == i
        var destello: float = float(f.get("destello", 0.0))
        Estilo.panel(self, fila, Color("#241c2c").lerp(Color("#5a4a2a"), destello) if sel or destello > 0.0 else Color("#141018"), Estilo.ORO if sel else Estilo.BORDE)
        if f.get("icono") != null:
            draw_texture_rect(f["icono"], Rect2(fila.position + Vector2(12, 5), Vector2(40, 40)), false, Color(1, 1, 1, 0.5) if bool(f.get("tenue", false)) else Color.WHITE)
        Estilo.plano(self, "[%d] %s" % [i + 1, f.get("nombre", "")], fila.position + Vector2(66, 22), 16, Estilo.CREMA)
        Estilo.plano(self, str(f.get("detalle", "")), fila.position + Vector2(66, 42), 11, Estilo.GRIS)
        draw_string(Estilo.fuente(), fila.position + Vector2(0, 22), str(f.get("derecha", "")), HORIZONTAL_ALIGNMENT_RIGHT, fila.size.x - 14.0, 15, f.get("color_derecha", Estilo.CREMA))
        # Lo que ya llevas: el número salta al comprar.
        draw_string(Estilo.fuente(), fila.position + Vector2(0, 42), str(f.get("llevas", "")), HORIZONTAL_ALIGNMENT_RIGHT, fila.size.x - 14.0, int(13.0 * (1.0 + 0.5 * destello)), Color("#ffd36b").lerp(Estilo.ALMA, 1.0 - destello))
    if datos.get("icono_alma") != null:
        draw_texture_rect(datos["icono_alma"], Rect2(180, 520, 26, 26), false)
    Estilo.plano(self, "ALMAS: %d" % int(datos.get("almas", 0)), Vector2(212, 540), 16, Estilo.ALMA)
    Estilo.plano(self, str(datos.get("vida", "")), Vector2(360, 540), 14, datos.get("color_vida", Estilo.CREMA))
    draw_string(Estilo.fuente(), Vector2(180, 566), str(datos.get("ayuda", "")), HORIZONTAL_ALIGNMENT_RIGHT, 600, 13, Estilo.CREMA)
    if bool(datos.get("info", false)):
        _dibujar_ficha()


func _dibujar_ficha() -> void:
    var f: Dictionary = datos.get("ficha", {})
    oscurecer(Color(0, 0, 0, 0.75))
    var r := FICHA
    Estilo.panel(self, r, Color(0.045, 0.035, 0.06, 0.985), Estilo.ORO)
    if f.get("icono") != null:
        draw_texture_rect(f["icono"], Rect2(r.position + Vector2(22, 18), Vector2(48, 48)), false)
    Estilo.titulo(self, "La Vigilia del Claustro", Vector2(r.position.x + 40.0, r.position.y + 52.0), 34, Estilo.CREMA, r.size.x - 40.0)
    Estilo.texto(self, "Lo que compras con la llave", Vector2(r.position.x, r.position.y + 80.0), 13, Color("#d1747b"), r.size.x)
    var y: float = r.position.y + 112.0
    for fila in f.get("filas", []):
        Estilo.plano(self, str(fila[0]), Vector2(r.position.x + 34.0, y), 13, Estilo.ORO)
        var n: int = 0
        for ln in Estilo.lineas(str(fila[1]), r.size.x - 220.0, 13):
            draw_string(Estilo.fuente(), Vector2(r.position.x + 190.0, y + float(n) * 18.0), ln, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Estilo.CREMA)
            n += 1
        y += maxf(1.0, float(n)) * 18.0 + 14.0
    var precio: int = int(f.get("precio", 0))
    var puede: bool = bool(f.get("puede", false))
    for i in range(2):
        var b := rect_boton_ficha(i)
        var hot: bool = b.has_point(_raton)
        Estilo.panel(self, b, Color("#3a2a18") if i == 0 and puede else (Color("#241c2c") if hot else Color("#141018")), Estilo.ORO if hot or (i == 0 and puede) else Estilo.BORDE)
        var etiqueta: String = ("[1] COMPRAR · %d ALMAS" % precio) if i == 0 else "[2] AHORA NO"
        draw_string(Estilo.fuente(), b.position + Vector2(0, 31), etiqueta, HORIZONTAL_ALIGNMENT_CENTER, b.size.x, 15, (Estilo.CREMA if puede else Estilo.ROJO) if i == 0 else Estilo.CREMA)
    if not puede:
        draw_string(Estilo.fuente(), Vector2(r.position.x, r.end.y - 12.0), "Tienes %d almas: te faltan %d." % [int(f.get("almas", 0)), precio - int(f.get("almas", 0))], HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 12, Estilo.GRIS)


func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        _raton = event.position
        if not bool(datos.get("info", false)):
            for i in range(_n()):
                if rect_fila(i).has_point(_raton):
                    seleccion = i
        queue_redraw()
    var en: Variant = clic_de(event)
    if en == null:
        return
    accept_event()
    if bool(datos.get("info", false)):
        if rect_boton_ficha(0).has_point(en):
            elegir(&"info_si")
        elif rect_boton_ficha(1).has_point(en) or not FICHA.has_point(en):
            elegir(&"info_no")
        return
    for i in range(_n()):
        if rect_fila(i).has_point(en):
            seleccion = i
            elegir(&"elegir", i)
            return
    elegir(&"salir")


func _unhandled_input(event: InputEvent) -> void:
    if not is_visible_in_tree() or _n() == 0:
        return
    var k := tecla_de(event)
    var b := boton_de(event)
    var interactuar: int = int(datos.get("tecla_interactuar", KEY_E))
    var hecho := true
    if bool(datos.get("info", false)):
        if k in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_1] or b == JOY_BUTTON_A:
            elegir(&"info_si")
        elif k in [KEY_ESCAPE, KEY_E, KEY_2, KEY_BACKSPACE, interactuar] or b == JOY_BUTTON_B:
            elegir(&"info_no")
        else:
            hecho = false
    else:
        var d := direccion(event)
        if k in [KEY_ESCAPE, KEY_E, interactuar] or b in [JOY_BUTTON_B, JOY_BUTTON_START]:
            elegir(&"salir")
        elif k in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE] or b == JOY_BUTTON_A:
            elegir(&"elegir", seleccion)
        elif k >= KEY_1 and k < KEY_1 + _n():
            seleccion = k - KEY_1
            elegir(&"elegir", seleccion)
        elif d in [Vector2i.DOWN, Vector2i.RIGHT]:
            seleccion = (seleccion + 1) % _n()
        elif d in [Vector2i.UP, Vector2i.LEFT]:
            seleccion = (seleccion + _n() - 1) % _n()
        else:
            hecho = false
    if hecho:
        get_viewport().set_input_as_handled()
        queue_redraw()
