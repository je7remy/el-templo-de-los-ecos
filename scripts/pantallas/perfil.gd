extends "res://scripts/pantallas/pantalla.gd"
## Perfil del jugador (I / Tab, LB o tocar el retrato): ficha de personaje.
## Izquierda: retrato, datos y estadísticas. Derecha: tres pestañas
## (MOCHILA Y HABILIDADES, OBJETOS, EQUIPO), los Ecos y la descripción de la
## casilla señalada. La campaña decide qué hay en cada casilla y qué pasa al
## usarla; aquí solo se dibuja y se avisa de lo que hace el jugador.
##
## Datos: «retrato», «equipo_retrato» (peto, amuleto, mascara, casco),
## «nombre», «identidad», «lugar», «destino», «nivel», «xp_texto»,
## «xp_fraccion», «barras» ({fraccion, color, texto}), «estadisticas»
## ([etiqueta, valor]), «pestana», «pestanas» (tres textos), «seleccion»,
## «mochila» ({icono, nombre, tiene}), «objetos» ({icono, nombre, detalle,
## usable}), «huecos» ({etiqueta, icono, fantasma, nombre, lleno, activo}),
## «encontrado» ({icono, puesto}), «ecos» ({icono, tiene}), «descripcion»
## ({titulo, color_titulo, texto, color_texto, envuelto, pie, color_pie,
## pie_derecha; y opcionales y_titulo, y_texto, tam_texto}), «boton_habilidades», «tecla_perfil», «tecla_habilidades»,
## «ayuda».
## Acciones: «pestana» (valor = 0..2), «cambiar_pestana», «senalar» (valor =
## casilla), «tocar» (valor = casilla), «usar», «mover» (valor = Vector2i),
## «habilidades» y «cerrar».
##
## Casillas: 0-5 mochila, 0-11 objetos, 0-6 huecos de equipo, 10-17 lo
## encontrado y 100+ los Ecos (como en main.gd).

const EquipoRetrato := preload("res://scripts/ui/equipo_retrato.gd")
const HOJA := Rect2(70, 46, 820, 548)
const BOTON_HABILIDADES := Rect2(706, 538, 162, 42)
const OBJETOS_COLUMNAS := 4
const OBJETOS_MAX := 12
## Hueco del objeto en 3D dentro del panel de descripción.
const MODELO := Rect2(794, 455, 72, 72)
const ENCONTRADO_MAX := 8
const APAGADO := Color("#5d5a52")
const FONDO_CASILLA := Color("#141922")
const FONDO_SELECCION := Color("#222c39")

var _raton: Vector2 = Vector2(-100, -100)


# ------------------------------------------------------------ DISPOSICIÓN
static func rect_pestana(t: int) -> Rect2:
    return Rect2(372.0 + float(t) * 168.0, 72.0, 160.0, 24.0)


## MOCHILA: arriba lo que llevas y, bajo su título, las habilidades nativas.
static func rect_mochila(i: int) -> Rect2:
    return Rect2(372.0 + float(i % 3) * 168.0, 116.0 + float(i / 3) * 128.0, 160.0, 98.0)


## OBJETOS: rejilla de 4 × 3.
static func rect_objeto(i: int) -> Rect2:
    return Rect2(372.0 + float(i % OBJETOS_COLUMNAS) * 126.0, 104.0 + float(i / OBJETOS_COLUMNAS) * 84.0, 118.0, 78.0)


## EQUIPO: cuatro huecos grandes (arma, casco, peto, botas) y tres accesorios.
static func rect_hueco(i: int) -> Rect2:
    if i < 4:
        return Rect2(372.0 + float(i) * 126.0, 120.0, 118.0, 96.0)
    return Rect2(372.0 + float(i - 4) * 126.0, 246.0, 118.0, 80.0)


static func rect_encontrado(i: int) -> Rect2:
    return Rect2(372.0 + float(i % 8) * 62.0, 360.0, 56.0, 56.0)


static func rect_eco(i: int) -> Rect2:
    return Rect2(372.0 + float(i) * 49.0, 382.0, 44.0, 44.0) # caben los diez Ecos


func pestana() -> int:
    return int(datos.get("pestana", 0))


func seleccion() -> int:
    return int(datos.get("seleccion", 0))


## Casilla bajo un punto (-1 si ninguna).
func casilla_en(en: Vector2) -> int:
    var p: int = pestana()
    if p == 2:
        for i in range((datos.get("huecos", []) as Array).size()):
            if rect_hueco(i).has_point(en):
                return i
        for i in range(ENCONTRADO_MAX):
            if rect_encontrado(i).has_point(en):
                return 10 + i
        return -1
    var cuantas: int = OBJETOS_MAX if p == 1 else (datos.get("mochila", []) as Array).size()
    for i in range(cuantas):
        if (rect_objeto(i) if p == 1 else rect_mochila(i)).has_point(en):
            return i
    for i in range((datos.get("ecos", []) as Array).size()):
        if rect_eco(i).has_point(en):
            return 100 + i
    return -1


# ------------------------------------------------------------ DIBUJO
func _draw() -> void:
    oscurecer(Color(0, 0, 0, 0.78))
    Estilo.panel(self, HOJA, Color(0.05, 0.06, 0.08, 0.97), Estilo.ORO)
    Estilo.panel(self, Rect2(380, 34, 200, 30), Color("#2a1d22"), Estilo.ORO)
    Estilo.titulo(self, "Perfil", Vector2(380, 58), 24, Estilo.CREMA, 200.0)
    _dibujar_ficha()
    var p: int = pestana()
    var nombres: Array = datos.get("pestanas", ["", "", ""])
    for t in range(3):
        var r: Rect2 = rect_pestana(t)
        var on: bool = p == t
        Estilo.panel(self, r, Color("#2a1d22") if on else FONDO_CASILLA, Estilo.ORO if on else Estilo.BORDE)
        Estilo.texto(self, str(nombres[t]), Vector2(r.position.x, r.position.y + 17.0), 12, Estilo.CREMA if on else Color("#9a957f"), r.size.x)
    match p:
        0:
            _dibujar_mochila()
        1:
            _dibujar_objetos()
        2:
            _dibujar_equipo()
    if p != 2:
        _dibujar_ecos()
    var hot: bool = BOTON_HABILIDADES.has_point(_raton)
    Estilo.panel(self, BOTON_HABILIDADES, Color("#241a30") if hot else FONDO_CASILLA, Estilo.ORO)
    if datos.get("icono_habilidades") != null:
        draw_texture_rect(datos["icono_habilidades"], Rect2(BOTON_HABILIDADES.position + Vector2(8, 10), Vector2(24, 24)), false)
    Estilo.texto(self, str(datos.get("boton_habilidades", "HABILIDADES")), Vector2(BOTON_HABILIDADES.position.x + 36.0, BOTON_HABILIDADES.position.y + 26.0), 12, Estilo.CREMA)
    _dibujar_descripcion()
    Estilo.texto(self, str(datos.get("ayuda", "")), Vector2(372, 564), 12, Color("#8a8574"), 320.0)


## Columna izquierda: retrato, datos, barras y estadísticas.
func _dibujar_ficha() -> void:
    var marco := Rect2(102, 84, 140, 140)
    Estilo.panel(self, marco, Color("#1a1f2a"), Estilo.ORO)
    var cara := Rect2(marco.position + Vector2(6, 6), Vector2(128, 128))
    if datos.get("retrato") != null:
        draw_texture_rect(datos["retrato"], cara, false)
    EquipoRetrato.dibujar(self, cara, datos.get("equipo_retrato", {}))
    Estilo.texto(self, str(datos.get("nombre", "")), Vector2(252, 112), 26, Estilo.CREMA)
    Estilo.texto(self, "IDENTIDAD %03d" % int(datos.get("identidad", 0)), Vector2(252, 136), 13, Color("#a0b6b2"))
    Estilo.texto(self, str(datos.get("lugar", "")), Vector2(252, 158), 13, Estilo.ORO)
    Estilo.texto(self, str(datos.get("destino", "")), Vector2(252, 180), 12, Color("#8a8574"))
    Estilo.texto(self, "NIVEL %d" % int(datos.get("nivel", 1)), Vector2(252, 204), 14, Estilo.ORO)
    Estilo.barra(self, Rect2(252, 210, 108, 14), float(datos.get("xp_fraccion", 0.0)), Color("#c9a25e"), str(datos.get("xp_texto", "")))
    var barras: Array = datos.get("barras", [])
    for i in range(barras.size()):
        var b: Dictionary = barras[i]
        Estilo.barra(self, Rect2(102, 236.0 + float(i) * 22.0, 238, 18), float(b.get("fraccion", 0.0)), b.get("color", Estilo.CREMA), str(b.get("texto", "")))
    Estilo.panel(self, Rect2(96, 310, 250, 268), Color("#0f1218"))
    var stats: Array = datos.get("estadisticas", [])
    for i in range(stats.size()):
        var y: float = 338.0 + float(i) * 29.0
        Estilo.texto(self, str(stats[i][0]), Vector2(112, y), 13, Estilo.GRIS)
        draw_string(Estilo.fuente(), Vector2(112, y), Estilo.t(str(stats[i][1])), HORIZONTAL_ALIGNMENT_RIGHT, 220.0, 15, Estilo.CREMA)
        if i < stats.size() - 1:
            draw_rect(Rect2(112, y + 11.0, 220, 1), Color(1, 1, 1, 0.06))


func _casilla(r: Rect2, sel: bool, borde: Color = Estilo.BORDE) -> void:
    Estilo.panel(self, r, FONDO_SELECCION if sel else FONDO_CASILLA, Estilo.ORO if sel else borde)


## Texto que se encoge (10 → 8) hasta caber en la casilla.
func _nombre_ajustado(msg: String, r: Rect2, y: float, color: Color) -> void:
    msg = Estilo.t(msg)
    var tam: int = 10
    while tam > 8 and Estilo.fuente().get_string_size(msg, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x > r.size.x - 8.0:
        tam -= 1
    Estilo.texto(self, msg, Vector2(r.position.x, y), tam, color, r.size.x)


func _dibujar_mochila() -> void:
    Estilo.texto(self, "MOCHILA", Vector2(372, 111), 12, Estilo.ORO)
    draw_rect(Rect2(440, 106, 428, 1), Color(Estilo.ORO.r, Estilo.ORO.g, Estilo.ORO.b, 0.3))
    Estilo.texto(self, "HABILIDADES NATIVAS", Vector2(372, 239), 12, Estilo.ALMA)
    draw_rect(Rect2(528, 234, 340, 1), Color(Estilo.ALMA.r, Estilo.ALMA.g, Estilo.ALMA.b, 0.3))
    var mochila: Array = datos.get("mochila", [])
    for i in range(mochila.size()):
        var c: Dictionary = mochila[i]
        var r: Rect2 = rect_mochila(i)
        var tiene: bool = bool(c.get("tiene", false))
        _casilla(r, seleccion() == i)
        if c.get("icono") != null:
            draw_texture_rect(c["icono"], Rect2(r.position + Vector2(roundf(r.size.x * 0.5) - 22.0, 8), Vector2(44, 44)), false, Color.WHITE if tiene else Color(0.1, 0.1, 0.12, 0.9))
        Estilo.texto(self, str(c.get("nombre", "")) if tiene else "???", Vector2(r.position.x, r.end.y - 10.0), 11, Estilo.CREMA if tiene else APAGADO, r.size.x)


func _dibujar_objetos() -> void:
    var lista: Array = datos.get("objetos", [])
    for i in range(OBJETOS_MAX):
        var r: Rect2 = rect_objeto(i)
        _casilla(r, seleccion() == i)
        if i >= lista.size():
            Estilo.texto(self, "—", Vector2(r.position.x, r.get_center().y + 6.0), 16, Color("#4a4740"), r.size.x)
            continue
        var o: Dictionary = lista[i]
        if o.get("icono") != null:
            draw_texture_rect(o["icono"], Rect2(r.position + Vector2(roundf(r.size.x * 0.5) - 16.0, 4), Vector2(32, 32)), false)
        Estilo.texto(self, str(o.get("detalle", "")), Vector2(r.position.x, r.position.y + 50.0), 10, Color("#ffd36b") if bool(o.get("usable", false)) else Estilo.ALMA, r.size.x)
        _nombre_ajustado(str(o.get("nombre", "")), r, r.end.y - 8.0, Estilo.CREMA)


func _dibujar_equipo() -> void:
    Estilo.texto(self, "LO QUE LLEVAS PUESTO · toca un hueco para quitar o poner", Vector2(372, 111), 12, Estilo.ORO)
    Estilo.texto(self, "ACCESORIOS", Vector2(372, 240), 11, Color("#9a957f"))
    var huecos: Array = datos.get("huecos", [])
    for i in range(huecos.size()):
        var h: Dictionary = huecos[i]
        var r: Rect2 = rect_hueco(i)
        var sel: bool = seleccion() == i
        Estilo.panel(self, r, FONDO_SELECCION if sel else FONDO_CASILLA, Estilo.ORO if sel or bool(h.get("lleno", false)) else Estilo.BORDE)
        Estilo.texto(self, str(h.get("etiqueta", "")), Vector2(r.position.x, r.position.y + 15.0), 10, Color("#9a957f"), r.size.x)
        if h.get("icono") != null:
            var isz: float = 40.0 if i < 4 else 32.0
            draw_texture_rect(h["icono"], Rect2(r.position + Vector2(roundf(r.size.x * 0.5 - isz * 0.5), 20), Vector2(isz, isz)), false, Color(1, 1, 1, 0.3) if bool(h.get("fantasma", false)) else Color.WHITE)
        _nombre_ajustado(str(h.get("nombre", "—")), r, r.end.y - 9.0, Estilo.CREMA if bool(h.get("activo", false)) else APAGADO)
    Estilo.texto(self, "ENCONTRADO · toca para ponerlo o quitarlo", Vector2(372, 352), 12, Estilo.ALMA)
    var lista: Array = datos.get("encontrado", [])
    for i in range(ENCONTRADO_MAX):
        var r: Rect2 = rect_encontrado(i)
        if i >= lista.size():
            Estilo.panel(self, r, Color("#10131a"), Estilo.BORDE)
            continue
        var e: Dictionary = lista[i]
        var puesto: bool = bool(e.get("puesto", false))
        _casilla(r, seleccion() == 10 + i, Estilo.ALMA if puesto else Estilo.BORDE)
        if e.get("icono") != null:
            draw_texture_rect(e["icono"], Rect2(r.position + Vector2(8, 8), Vector2(40, 40)), false, Color.WHITE if puesto else Color(1, 1, 1, 0.45))


## Ecos: iconos compactos (el detalle está en HABILIDADES).
func _dibujar_ecos() -> void:
    Estilo.texto(self, "ECOS", Vector2(372, 368), 13, Estilo.ORO)
    var ecos: Array = datos.get("ecos", [])
    for i in range(ecos.size()):
        var e: Dictionary = ecos[i]
        var r: Rect2 = rect_eco(i)
        var tiene: bool = bool(e.get("tiene", false))
        _casilla(r, seleccion() == 100 + i, Color("#3b6f7d") if tiene else Estilo.BORDE)
        if e.get("icono") != null:
            draw_texture_rect(e["icono"], Rect2(r.position + Vector2(6, 6), Vector2(32, 32)), false, Color.WHITE if tiene else Color(0.15, 0.15, 0.18, 0.9))


## Descripción de la casilla señalada (cursor, flechas o toque).
func _dibujar_descripcion() -> void:
    Estilo.panel(self, Rect2(372, 454, 496, 76), Color("#0f1218"))
    var d: Dictionary = datos.get("descripcion", {})
    if d.is_empty():
        return
    # El objeto elegido en 3D, girando a la derecha del texto.
    var ancho: float = 470.0
    if Vitrinas.dibujar(self, str(d.get("modelo", "")), MODELO):
        ancho = MODELO.position.x - 392.0
    var fuente: Font = Estilo.fuente()
    if bool(d.get("envuelto", false)):
        Estilo.texto(self, str(d.get("titulo", "")), Vector2(388, 476), 15, d.get("color_titulo", Estilo.CREMA))
        var lineas: PackedStringArray = Estilo.lineas(str(d.get("texto", "")), ancho, 12)
        for i in range(mini(2, lineas.size())):
            draw_string(fuente, Vector2(388, 496 + i * 15), lineas[i], HORIZONTAL_ALIGNMENT_LEFT, ancho, 12, d.get("color_texto", Estilo.ALMA))
    else:
        Estilo.texto(self, str(d.get("titulo", "")), Vector2(388, float(d.get("y_titulo", 478))), 15, d.get("color_titulo", Estilo.CREMA))
        draw_string(fuente, Vector2(388, float(d.get("y_texto", 502))), Estilo.t(str(d.get("texto", ""))), HORIZONTAL_ALIGNMENT_LEFT, ancho, int(d.get("tam_texto", 13)), d.get("color_texto", Estilo.ALMA))
    var pie: String = str(d.get("pie", ""))
    if pie != "":
        var alinear: int = HORIZONTAL_ALIGNMENT_RIGHT if bool(d.get("pie_derecha", false)) else HORIZONTAL_ALIGNMENT_LEFT
        draw_string(fuente, Vector2(388, 526), Estilo.t(pie), alinear, ancho, 11, d.get("color_pie", Color("#ffd36b")))


## Mientras se ve un objeto en 3D hay que volver a pedirlo (si no, se para).
func _process(_delta: float) -> void:
    if is_visible_in_tree() and Vitrinas.tiene(str((datos.get("descripcion", {}) as Dictionary).get("modelo", ""))):
        queue_redraw()


# ------------------------------------------------------------ ENTRADA
func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        _raton = event.position
        var bajo: int = casilla_en(_raton)
        if bajo >= 0 and bajo != seleccion():
            elegir(&"senalar", bajo)
        queue_redraw()
        return
    var en: Variant = clic_de(event)
    if en == null:
        return
    accept_event()
    _raton = en
    if BOTON_HABILIDADES.has_point(en):
        elegir(&"habilidades")
        return
    for t in range(3):
        if rect_pestana(t).has_point(en):
            elegir(&"pestana", t)
            return
    var c: int = casilla_en(en)
    if c >= 0:
        elegir(&"tocar", c)
    else:
        elegir(&"cerrar")


func _unhandled_input(event: InputEvent) -> void:
    if not is_visible_in_tree():
        return
    var k := tecla_de(event)
    var b := boton_de(event)
    var hecho := true
    if k in [int(datos.get("tecla_perfil", KEY_I)), KEY_TAB, KEY_ESCAPE, KEY_E] or b in [JOY_BUTTON_B, JOY_BUTTON_LEFT_SHOULDER, JOY_BUTTON_BACK, JOY_BUTTON_START]:
        elegir(&"cerrar")
    elif k == int(datos.get("tecla_habilidades", KEY_K)) or b == JOY_BUTTON_RIGHT_SHOULDER:
        elegir(&"habilidades")
    elif k == KEY_O or b == JOY_BUTTON_Y:
        elegir(&"cambiar_pestana")
    elif k in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE] or b == JOY_BUTTON_A:
        elegir(&"usar")
    else:
        var d := direccion(event)
        if d != Vector2i.ZERO:
            elegir(&"mover", d)
        else:
            hecho = false
    if hecho:
        get_viewport().set_input_as_handled()
