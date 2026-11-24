extends "res://scripts/pantallas/pantalla.gd"
## Creación del personaje: primero el nombre (teclado en pantalla, teclado
## físico, mando o el teclado del móvil) y después el género.
##
## La campaña guarda lo escrito y decide (nombre vacío, a dónde ir después);
## esta escena dibuja, sabe dónde está cada tecla y avisa de lo pulsado.
##
## Datos: «paso» (0 nombre, 1 género), «nombre», «nombre_limpio», «genero»,
## «max», «textos» (claves → texto), «hojas» y «retratos» (por género).
## Acciones: «letra» (valor = carácter), «borrar», «espacio», «azar»,
## «siguiente», «genero» (valor = 0/1), «comenzar», «atras», «foco_nativo».

const Textos := preload("res://scripts/datos/textos.gd")

const PANEL := Rect2(150, 104, 660, 452)
const CAJA_NOMBRE := Rect2(300, 182, 360, 54)
const FILAS := ["ABCDEFGHIJ", "KLMNÑOPQRS", "TUVWXYZ"]
const TECLA := Vector2(52, 44)
const REJILLA := Vector2(193, 252)

## Tecla elegida con el mando (índice en teclas()).
var seleccion: int = 0
var _raton: Vector2 = Vector2(-100, -100)
var _t: float = 0.0


func _al_entrar() -> void:
    seleccion = 0


func actualizar(delta: float) -> void:
    _t += delta
    queue_redraw()


func _paso() -> int:
    return int(datos.get("paso", 0))


func _tx(clave: String) -> String:
    return Textos.t(clave)


## Teclas en pantalla: [rect, acción]. Acción: una letra o «borrar»,
## «espacio», «azar», «siguiente».
func teclas() -> Array:
    var lista: Array = []
    for fila in range(FILAS.size()):
        var letras: String = FILAS[fila]
        for col in range(letras.length()):
            lista.append([Rect2(REJILLA + Vector2(col * (TECLA.x + 6.0), fila * (TECLA.y + 6.0)), TECLA), letras[col]])
    var y3: float = REJILLA.y + 2.0 * (TECLA.y + 6.0)
    lista.append([Rect2(REJILLA.x + 7.0 * (TECLA.x + 6.0), y3, 3.0 * TECLA.x + 12.0, TECLA.y), "borrar"])
    var y4: float = REJILLA.y + 3.0 * (TECLA.y + 6.0) + 8.0
    lista.append([Rect2(193, y4, 170, 44), "espacio"])
    lista.append([Rect2(373, y4, 170, 44), "azar"])
    lista.append([Rect2(553, y4, 214, 44), "siguiente"])
    return lista


func rect_tecla(accion_id: String) -> Rect2:
    for t in teclas():
        if str(t[1]) == accion_id:
            return t[0]
    return Rect2()


func tarjeta(i: int) -> Rect2:
    return Rect2(215.0 + i * 280.0, 196.0, 250.0, 236.0)


func botones_genero() -> Array:
    return [[Rect2(215, 452, 200, 48), "atras"], [Rect2(545, 452, 200, 48), "comenzar"]]


# ------------------------------------------------------------ DIBUJO
func _boton(r: Rect2, etiqueta: String, tam: int, acento: bool = false, marcado: bool = false) -> void:
    var hot: bool = r.has_point(_raton) or marcado
    var relleno := Color("#1d4a4f") if acento else Color("#141922")
    Estilo.panel(self, r, relleno.lightened(0.12) if hot else relleno, Estilo.ORO if hot or acento else Estilo.BORDE)
    Estilo.texto(self, etiqueta, Vector2(r.position.x, r.position.y + r.size.y * 0.5 + tam * 0.36), tam, Estilo.CREMA, r.size.x)


func _draw() -> void:
    oscurecer(Color(0.018, 0.027, 0.032, 0.72))
    Estilo.panel(self, PANEL, Color(0.045, 0.055, 0.07, 0.96), Estilo.ORO)
    draw_rect(PANEL.grow(-8.0), Color("#3a3f4c"), false, 1.0)
    for i in range(2): # paso 1 nombre · 2 género
        draw_rect(Rect2(462.0 + i * 24.0, 120.0, 12.0, 12.0), Estilo.ORO if _paso() >= i else Estilo.BORDE)
    var pista := func(teclado: String, tactil: String, mando: String) -> String:
        return _tx(ayuda(teclado, tactil, mando))
    if _paso() == 0:
        Estilo.texto(self, _tx("pj_nombre"), Vector2(150, 168), 30, Estilo.CREMA, PANEL.size.x)
        Estilo.panel(self, CAJA_NOMBRE, Color("#0b0e13"), Estilo.ALMA)
        var nombre: String = str(datos.get("nombre", ""))
        var maximo: int = int(datos.get("max", 12))
        var visto: String = nombre + ("_" if int(_t * 2.0) % 2 == 0 and nombre.length() < maximo else " ")
        Estilo.texto(self, visto, Vector2(CAJA_NOMBRE.position.x, CAJA_NOMBRE.position.y + 38.0), 30, Estilo.ALMA, CAJA_NOMBRE.size.x)
        Estilo.texto(self, "%d/%d" % [nombre.length(), maximo], Vector2(CAJA_NOMBRE.end.x - 46.0, CAJA_NOMBRE.end.y - 6.0), 10, Color("#6b6f80"))
        var lista: Array = teclas()
        var con_mando: bool = str(datos.get("entrada", "")) == "mando"
        for i in range(lista.size()):
            var accion_id: String = str(lista[i][1])
            var marcado: bool = con_mando and i == seleccion
            match accion_id:
                "borrar":
                    _boton(lista[i][0], "< " + _tx("pj_borrar"), 15, false, marcado)
                "espacio":
                    _boton(lista[i][0], _tx("pj_espacio"), 15, false, marcado)
                "azar":
                    _boton(lista[i][0], _tx("pj_azar"), 15, false, marcado)
                "siguiente":
                    _boton(lista[i][0], _tx("pj_siguiente") + " »", 17, true, marcado)
                _:
                    _boton(lista[i][0], accion_id, 20, false, marcado)
        Estilo.texto(self, pista.call("pj_nombre_ayuda", "pj_nombre_tactil", "pj_nombre_mando"), Vector2(150, 520), 12, Color("#9fb3b3"), PANEL.size.x)
        return
    Estilo.texto(self, _tx("pj_genero"), Vector2(150, 162), 30, Estilo.CREMA, PANEL.size.x)
    Estilo.texto(self, _tx("pj_te_llamas") % str(datos.get("nombre_limpio", "")), Vector2(150, 186), 14, Estilo.ALMA, PANEL.size.x)
    var etiquetas := [_tx("pj_masculino"), _tx("pj_femenino")]
    var hojas: Array = datos.get("hojas", [])
    var retratos: Array = datos.get("retratos", [])
    var genero: int = int(datos.get("genero", 0))
    for i in range(2):
        var r := tarjeta(i)
        var sel: bool = genero == i
        Estilo.panel(self, r, Color("#1a2430") if sel else Color("#10141b"), Estilo.ORO if sel else Estilo.BORDE)
        if sel:
            draw_rect(r.grow(3.0), Color(Estilo.ORO.r, Estilo.ORO.g, Estilo.ORO.b, 0.25 + 0.2 * sin(_t * 4.0)), false, 2.0)
        # Círculo de luz y el personaje caminando de frente (o quieto si no está elegido).
        var pies := Vector2(r.position.x + 142.0, r.position.y + 186.0)
        draw_circle(pies + Vector2(0, -4), 46.0, Color(0.95, 0.85, 0.55, 0.07 if sel else 0.03))
        draw_set_transform(pies + Vector2(0, -2), 0.0, Vector2(1.0, 0.35))
        draw_circle(Vector2.ZERO, 30.0, Color(0, 0, 0, 0.45))
        draw_set_transform(Vector2.ZERO)
        var cuadro: int = (2 + int(_t * 7.0) % 4) if sel else int(_t * 1.6) % 2
        if i < hojas.size() and hojas[i] != null:
            draw_texture_rect_region(hojas[i], Rect2(pies - Vector2(60, 150), Vector2(120, 168)), Rect2(cuadro * 40.0, 0.0, 40.0, 56.0), Color(1, 1, 1, 1.0 if sel else 0.6))
        if i < retratos.size() and retratos[i] != null:
            draw_texture_rect(retratos[i], Rect2(r.position + Vector2(12, 12), Vector2(64, 64)), false, Color(1, 1, 1, 1.0 if sel else 0.55))
        Estilo.texto(self, etiquetas[i], Vector2(r.position.x, r.end.y - 14.0), 22, Estilo.CREMA if sel else Color("#8f8a7a"), r.size.x)
    for b in botones_genero():
        var comenzar: bool = b[1] == "comenzar"
        _boton(b[0], (_tx("pj_comenzar") + " »") if comenzar else ("« " + _tx("pj_atras")), 18, comenzar)
    Estilo.texto(self, pista.call("pj_genero_ayuda", "pj_genero_tactil", "pj_genero_mando"), Vector2(150, 530), 12, Color("#9fb3b3"), PANEL.size.x)


# ------------------------------------------------------------ ENTRADA
func _pulsar_tecla(accion_id: String) -> void:
    match accion_id:
        "borrar", "espacio", "azar", "siguiente":
            elegir(StringName(accion_id))
        _:
            elegir(&"letra", accion_id)


func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        _raton = event.position
        queue_redraw()
        return
    var en: Variant = clic_de(event)
    if en == null:
        return
    accept_event()
    _raton = en
    if _paso() == 0:
        for t in teclas():
            if (t[0] as Rect2).has_point(en):
                _pulsar_tecla(str(t[1]))
                return
        if CAJA_NOMBRE.has_point(en):
            elegir(&"foco_nativo") # tocar el recuadro abre el teclado del móvil
        return
    for i in range(2):
        if tarjeta(i).has_point(en):
            # Segundo toque sobre la misma tarjeta: confirma.
            elegir(&"comenzar" if int(datos.get("genero", 0)) == i else &"genero", i)
            return
    for b in botones_genero():
        if (b[0] as Rect2).has_point(en):
            elegir(StringName(b[1]))
            return


## Mueve la selección del mando a la tecla más cercana en esa dirección.
func _mover(dir: Vector2i) -> void:
    var lista: Array = teclas()
    seleccion = clampi(seleccion, 0, lista.size() - 1)
    var desde: Vector2 = (lista[seleccion][0] as Rect2).get_center()
    var mejor: int = -1
    var mejor_nota: float = INF
    for i in range(lista.size()):
        var d: Vector2 = (lista[i][0] as Rect2).get_center() - desde
        var a_lo_largo: float = d.x * dir.x + d.y * dir.y
        if i == seleccion or a_lo_largo < 8.0:
            continue
        var nota: float = a_lo_largo + (absf(d.x * dir.y) + absf(d.y * dir.x)) * 2.0
        if nota < mejor_nota:
            mejor_nota = nota
            mejor = i
    if mejor >= 0:
        seleccion = mejor
        Eventos.sonido_pedido.emit("toque", -18.0, 1.3)


func _unhandled_input(event: InputEvent) -> void:
    if not is_visible_in_tree():
        return
    var hecho := true
    if event is InputEventKey and event.pressed and not event.echo:
        var k: int = (event as InputEventKey).keycode
        if k == KEY_ESCAPE:
            elegir(&"atras")
        elif _paso() == 0:
            if k in [KEY_ENTER, KEY_KP_ENTER]:
                elegir(&"siguiente")
            elif k == KEY_BACKSPACE:
                elegir(&"borrar")
            elif (event as InputEventKey).unicode > 0:
                elegir(&"letra", char((event as InputEventKey).unicode))
            else:
                hecho = false
        elif k in [KEY_LEFT, KEY_A, KEY_RIGHT, KEY_D, KEY_TAB]:
            elegir(&"genero", 1 - int(datos.get("genero", 0)))
        elif k in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_E]:
            elegir(&"comenzar")
        else:
            hecho = false
    elif event is InputEventJoypadButton and event.pressed:
        var b: int = (event as InputEventJoypadButton).button_index
        var d := direccion(event)
        if _paso() == 0:
            if d != Vector2i.ZERO:
                _mover(d)
            elif b == JOY_BUTTON_A:
                _pulsar_tecla(str(teclas()[clampi(seleccion, 0, teclas().size() - 1)][1]))
            elif b == JOY_BUTTON_X:
                elegir(&"borrar")
            elif b == JOY_BUTTON_Y:
                elegir(&"azar")
            elif b == JOY_BUTTON_START:
                elegir(&"siguiente")
            elif b == JOY_BUTTON_B and str(datos.get("nombre", "")) != "":
                elegir(&"borrar")
            elif b in [JOY_BUTTON_B, JOY_BUTTON_BACK]:
                elegir(&"atras")
            else:
                hecho = false
        elif d.x != 0:
            elegir(&"genero", 1 - int(datos.get("genero", 0)))
        elif b in [JOY_BUTTON_A, JOY_BUTTON_START]:
            elegir(&"comenzar")
        elif b in [JOY_BUTTON_B, JOY_BUTTON_BACK]:
            elegir(&"atras")
        else:
            hecho = false
    elif event is InputEventJoypadMotion:
        var d := direccion(event)
        if d == Vector2i.ZERO:
            hecho = false
        elif _paso() == 0:
            _mover(d)
        elif d.x != 0:
            elegir(&"genero", 1 - int(datos.get("genero", 0)))
    else:
        hecho = false
    if hecho:
        get_viewport().set_input_as_handled()
        queue_redraw()
