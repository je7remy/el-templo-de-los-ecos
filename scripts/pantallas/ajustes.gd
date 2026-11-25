extends "res://scripts/pantallas/pantalla.gd"
## Configuración: cuatro pestañas (sonido, controles, idioma, privacidad) y
## las páginas legales (acuerdo, política, créditos).
##
## Edita los ajustes directamente (scripts/ajustes.gd). Lo que afecta a la
## partida sale por «accion»: «volver», «repetir_tutorial», «ver_intro»,
## «borrar», «ventana», «actualizaciones» y «tactil».
##
## Datos: «pestana» y «legal» (con qué abrir), «ruta_progreso».
##
## Entrada: clic/toque (los deslizadores se arrastran), ↑↓ elegir, ←→ ajustar
## o cambiar de pestaña, TAB pestaña siguiente, ENTER activar, ESC volver.
## Mando: cruceta/stick, A activar, B volver, LB/RB pestañas.

const Ajustes := preload("res://scripts/ajustes.gd")
const Textos := preload("res://scripts/datos/textos.gd")

const PANEL := Rect2(100, 60, 760, 520)
const PESTANAS := ["sonido", "controles", "idioma", "privacidad"]

var pestana: int = 0
## Índice dentro de los controles que pueden tener el foco (sin pestañas).
var seleccion: int = 0
var reasignando: String = ""
var arrastrando: String = ""
var confirmar_borrar: bool = false
var legal: String = ""
var _raton: Vector2 = Vector2(-100, -100)


func _al_entrar() -> void:
    pestana = int(datos.get("pestana", 0))
    legal = str(datos.get("legal", ""))
    seleccion = 0
    reasignando = ""
    arrastrando = ""
    confirmar_borrar = false


func actualizar(_delta: float) -> void:
    queue_redraw()


func _t(clave: String) -> String:
    return Textos.t(clave)


func _sonido(nombre: String, db: float = -8.0, tono: float = 1.0) -> void:
    Eventos.sonido_pedido.emit(nombre, db, tono)


## Controles de la pestaña actual: se usan para dibujar y para la entrada.
func widgets() -> Array:
    var lista: Array = []
    for i in range(PESTANAS.size()):
        # Leyendo un texto legal, las pestañas quedan apagadas: se sale con VOLVER.
        lista.append({"kind": "tab", "id": i, "label": _t(PESTANAS[i]), "rect": Rect2(118.0 + float(i) * 182.0, 112.0, 174.0, 40.0), "off": legal != ""})
    if legal != "":
        lista.append({"kind": "button", "id": "cerrar_legal", "label": _t("volver"), "rect": Rect2(660, 520, 180, 44)})
        return lista
    match pestana:
        0:
            var filas := [["slider", "volumen_general", "vol_general"], ["slider", "volumen_musica", "vol_musica"], ["slider", "volumen_efectos", "vol_efectos"],
                ["toggle", "silencio", "silencio"], ["toggle", "pantalla_completa", "pantalla_completa"], ["toggle", "buscar_actualizaciones", "buscar_actualizaciones"],
                ["choice", "zoom_movil", "zoom_movil"]]
            for i in range(filas.size()):
                lista.append({"kind": filas[i][0], "id": filas[i][1], "label": _t(filas[i][2]), "rect": Rect2(140, 166.0 + float(i) * 51.0, 680, 45)})
        1:
            for i in range(Ajustes.ORDEN.size()):
                var accion_id: String = Ajustes.ORDEN[i]
                var col: int = i / 6
                lista.append({"kind": "key", "id": accion_id, "label": Textos.elegir(Ajustes.ACCIONES[accion_id]),
                    "rect": Rect2(130.0 + float(col) * 356.0, 182.0 + float(i % 6) * 38.0, 344, 33)})
            lista.append({"kind": "choice", "id": "tactil", "label": _t("tactil"), "rect": Rect2(130, 418, 700, 40)})
            lista.append({"kind": "button", "id": "restablecer", "label": _t("restablecer"), "rect": Rect2(130, 470, 224, 42)})
            lista.append({"kind": "button", "id": "repetir_tutorial", "label": _t("repetir_tutorial"), "rect": Rect2(368, 470, 224, 42)})
            lista.append({"kind": "button", "id": "ver_intro", "label": _t("ver_intro"), "rect": Rect2(606, 470, 224, 42)})
        2:
            lista.append({"kind": "lang", "id": "es", "label": "ESPAÑOL", "rect": Rect2(250, 200, 460, 56)})
            lista.append({"kind": "lang", "id": "en", "label": "ENGLISH", "rect": Rect2(250, 268, 460, 56)})
        3:
            lista.append({"kind": "button", "id": "acuerdo", "label": _t("acuerdo"), "rect": Rect2(140, 330, 330, 46)})
            lista.append({"kind": "button", "id": "politica", "label": _t("politica"), "rect": Rect2(490, 330, 330, 46)})
            lista.append({"kind": "button", "id": "borrar", "label": _t("borrar_seguro") if confirmar_borrar else _t("borrar"), "rect": Rect2(140, 392, 330, 46)})
            lista.append({"kind": "button", "id": "creditos", "label": _t("creditos"), "rect": Rect2(490, 392, 330, 46)})
    lista.append({"kind": "button", "id": "volver", "label": _t("volver"), "rect": Rect2(660, 520, 180, 44)})
    return lista


func enfocables() -> Array:
    return widgets().filter(func(w): return w["kind"] != "tab")


func _pista_deslizador(r: Rect2) -> Rect2:
    return Rect2(r.position.x + 300.0, r.position.y + 15.0, r.size.x - 320.0, 24.0)


## Ajustes de varias opciones: clave → valores posibles (el texto de cada
## valor está en scripts/datos/textos.gd).
const OPCIONES := {"tactil": ["auto", "siempre", "nunca"], "zoom_movil": ["cerca", "medio", "lejos"]}


func _rect_opcion(r: Rect2, i: int) -> Rect2:
    return Rect2(r.end.x - 360.0 + float(i) * 120.0, r.position.y + 5.0, 112, 30)


# ------------------------------------------------------------ DIBUJO
func _draw() -> void:
    var margen: Vector2 = datos.get("margen", Vector2.ZERO)
    draw_rect(Rect2(-margen, size + margen * 2.0), Color(0, 0, 0, 0.82))
    Estilo.panel(self, PANEL, Color(0.05, 0.06, 0.08, 0.98), Estilo.ORO)
    Estilo.panel(self, Rect2(380, 48, 200, 30), Color("#2a1d22"), Estilo.ORO)
    Estilo.titulo(self, _titulo_capital(_t("ajustes")), Vector2(380, 72), 24, Estilo.CREMA, 200.0)
    var foco: Array = enfocables()
    var enfocado: Dictionary = foco[clampi(seleccion, 0, foco.size() - 1)] if not foco.is_empty() else {}
    for w in widgets():
        var r: Rect2 = w["rect"]
        var hot: bool = r.has_point(_raton) or (not enfocado.is_empty() and str(w["id"]) == str(enfocado["id"]) and w["kind"] == enfocado["kind"])
        match w["kind"]:
            "tab":
                if bool(w.get("off", false)):
                    Estilo.panel(self, r, Color("#0d1015"), Color(Estilo.BORDE.r, Estilo.BORDE.g, Estilo.BORDE.b, 0.4))
                    Estilo.texto(self, w["label"], Vector2(r.position.x, r.position.y + 26.0), 15, Color("#4a4740"), r.size.x)
                    continue
                var on: bool = int(w["id"]) == pestana
                Estilo.panel(self, r, Color("#2a1d22") if on else Color("#141922"), Estilo.ORO if on or hot else Estilo.BORDE)
                Estilo.texto(self, w["label"], Vector2(r.position.x, r.position.y + 26.0), 15, Estilo.CREMA if on else Color("#9a957f"), r.size.x)
            "slider":
                Estilo.panel(self, r, Color("#1a1f2a") if hot else Color("#11151c"), Estilo.ORO if hot else Estilo.BORDE)
                Estilo.texto(self, w["label"], Vector2(r.position.x + 18.0, r.position.y + 33.0), 15, Estilo.CREMA)
                var v: float = float(Ajustes.obtener(w["id"]))
                Estilo.barra(self, _pista_deslizador(r), v, Estilo.ALMA, "%d%%" % int(round(v * 100.0)))
            "toggle":
                Estilo.panel(self, r, Color("#1a1f2a") if hot else Color("#11151c"), Estilo.ORO if hot else Estilo.BORDE)
                Estilo.texto(self, w["label"], Vector2(r.position.x + 18.0, r.position.y + 33.0), 15, Estilo.CREMA)
                var on2: bool = bool(Ajustes.obtener(w["id"]))
                var pastilla := Rect2(r.end.x - 110.0, r.position.y + 10.0, 92, 34)
                Estilo.panel(self, pastilla, Color("#5a1f26") if on2 else Color("#1d3a2c"), Estilo.CLARO)
                Estilo.texto(self, _t("si") if on2 else _t("no"), Vector2(pastilla.position.x, pastilla.position.y + 23.0), 14, Estilo.CREMA, pastilla.size.x)
            "key":
                var esperando: bool = reasignando == str(w["id"])
                Estilo.panel(self, r, Color("#2a1d22") if esperando else (Color("#1a1f2a") if hot else Color("#11151c")), Estilo.ORO if hot or esperando else Estilo.BORDE)
                Estilo.texto(self, w["label"], Vector2(r.position.x + 12.0, r.position.y + 25.0), 13, Estilo.CREMA)
                var tecla := Rect2(r.end.x - 118.0, r.position.y + 5.0, 110, 28)
                Estilo.panel(self, tecla, Color("#232836"), Estilo.ORO if esperando else Estilo.CLARO)
                Estilo.texto(self, "…" if esperando else Ajustes.nombre_tecla(w["id"]), Vector2(tecla.position.x, tecla.position.y + 20.0), 13, Estilo.ORO if esperando else Estilo.CREMA, tecla.size.x)
            "choice":
                Estilo.panel(self, r, Color("#1a1f2a") if hot else Color("#11151c"), Estilo.ORO if hot else Estilo.BORDE)
                Estilo.texto(self, w["label"], Vector2(r.position.x + 12.0, r.position.y + 26.0), 14, Estilo.CREMA)
                var opciones: Array = OPCIONES[w["id"]]
                for i in range(opciones.size()):
                    var o := _rect_opcion(r, i)
                    var sel: bool = str(Ajustes.obtener(w["id"])) == opciones[i]
                    Estilo.panel(self, o, Color("#1d4a4f") if sel else Color("#141922"), Estilo.ALMA if sel else Estilo.BORDE)
                    Estilo.texto(self, _t(opciones[i]), Vector2(o.position.x, o.position.y + 21.0), 13, Estilo.CREMA, o.size.x)
            "lang":
                var sel2: bool = str(Ajustes.obtener("idioma")) == str(w["id"])
                Estilo.panel(self, r, Color("#1d4a4f") if sel2 else (Color("#1a1f2a") if hot else Color("#11151c")), Estilo.ALMA if sel2 else (Estilo.ORO if hot else Estilo.BORDE))
                Estilo.texto(self, ("● " if sel2 else "○ ") + w["label"], Vector2(r.position.x, r.position.y + 36.0), 20, Estilo.CREMA, r.size.x)
            "button":
                Estilo.boton(self, r, w["label"], str(w["id"]) == "volver", hot)
    # Textos propios de cada pestaña.
    if legal != "":
        Estilo.texto(self, _t(legal), Vector2(140, 192), 18, Estilo.ORO)
        var y: float = 210.0
        for parrafo in Textos.LEGAL[legal]:
            y = Estilo.parrafo(self, Textos.elegir(parrafo), Rect2(140, y, 680, 60), 13, Color("#d0c8b0")) + 14.0
        if legal != "creditos":
            Estilo.texto(self, "DRAFT · not legal advice" if Textos.en_ingles() else "BORRADOR · no es asesoramiento legal", Vector2(140, 548), 11, Color("#8a8574"))
        return
    match pestana:
        1:
            Estilo.texto(self, _t("pulsa_tecla") if reasignando != "" else _t("clic_cambiar"), Vector2(130, 172), 12, Estilo.ORO if reasignando != "" else Color("#9a957f"))
            Estilo.texto(self, _t("mando_esquema"), Vector2(118, 538), 11, Estilo.ALMA)
            Estilo.texto(self, _t("mando_esquema2"), Vector2(118, 556), 11, Estilo.ALMA)
        2:
            Estilo.parrafo(self, _t("nota_idioma"), Rect2(250, 350, 460, 60), 13, Color("#9a957f"))
        3:
            Estilo.parrafo(self, _t("privacidad_resumen"), Rect2(140, 178, 680, 60), 15, Color("#d0c8b0"))
            Estilo.parrafo(self, _t("privacidad_ruta") % [str(datos.get("ruta_progreso", "")), Ajustes.ruta()], Rect2(140, 262, 680, 40), 12, Color("#9a957f"))
            if confirmar_borrar:
                Estilo.texto(self, "Everything (campaign, Vigil and settings) will be deleted; you will start over." if Textos.en_ingles() else "Se borrará todo (campaña, Vigilia y ajustes) y empezarás de cero.", Vector2(490, 420), 12, Estilo.ROJO)


## «AJUSTES» → «Ajustes» (la gótica en mayúsculas no se lee).
func _titulo_capital(msg: String) -> String:
    var m := msg.to_lower()
    return m.substr(0, 1).to_upper() + m.substr(1)


# ------------------------------------------------------------ ACCIONES
func activar(w: Dictionary, en: Vector2 = Vector2(-1, -1)) -> void:
    if bool(w.get("off", false)):
        return # pestaña apagada mientras se lee un texto legal
    match w["kind"]:
        "tab":
            pestana = int(w["id"])
            seleccion = 0
            confirmar_borrar = false
            reasignando = ""
            _sonido("interfaz", -12.0, 1.1)
        "slider":
            arrastrando = w["id"]
            if en.x >= 0.0:
                _poner_deslizador(w, en.x)
        "toggle":
            Ajustes.poner(w["id"], not bool(Ajustes.obtener(w["id"])))
            Ajustes.aplicar_audio()
            if w["id"] == "pantalla_completa":
                elegir(&"ventana")
            elif w["id"] == "buscar_actualizaciones":
                elegir(&"actualizaciones")
            _sonido("toque", -8.0)
        "key":
            reasignando = w["id"]
        "choice":
            var opciones: Array = OPCIONES[w["id"]]
            var idx: int = opciones.find(str(Ajustes.obtener(w["id"])))
            if en.x >= 0.0:
                for i in range(opciones.size()):
                    if _rect_opcion(w["rect"], i).has_point(en):
                        idx = i
            else:
                idx = (idx + 1) % opciones.size()
            Ajustes.poner(w["id"], opciones[idx])
            elegir(StringName(w["id"]))
        "lang":
            Ajustes.poner("idioma", w["id"])
            _sonido("interfaz", -10.0)
        "button":
            match w["id"]:
                "volver":
                    elegir(&"volver")
                "cerrar_legal":
                    legal = ""
                "acuerdo", "politica", "creditos":
                    legal = w["id"]
                "restablecer":
                    Ajustes.restablecer_teclas()
                    _sonido("interfaz", -8.0)
                "repetir_tutorial":
                    elegir(&"repetir_tutorial")
                "ver_intro":
                    elegir(&"ver_intro")
                "borrar":
                    if confirmar_borrar:
                        confirmar_borrar = false
                        elegir(&"borrar")
                    else:
                        confirmar_borrar = true
    queue_redraw()


func _poner_deslizador(w: Dictionary, x: float) -> void:
    var pista: Rect2 = _pista_deslizador(w["rect"])
    var v: float = clampf((x - pista.position.x) / pista.size.x, 0.0, 1.0)
    Ajustes.datos[w["id"]] = snappedf(v, 0.05)
    Ajustes.aplicar_audio()


func clic(en: Vector2) -> void:
    for w in widgets():
        if (w["rect"] as Rect2).has_point(en):
            activar(w, en)
            return


func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        _raton = event.position
        if arrastrando != "" and (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
            for w in widgets():
                if w["kind"] == "slider" and w["id"] == arrastrando:
                    _poner_deslizador(w, _raton.x)
        queue_redraw()
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        accept_event()
        if event.pressed:
            _raton = event.position
            clic(event.position)
        else:
            arrastrando = ""


# ------------------------------------------------------------ TECLADO Y MANDO
func tecla(k: int) -> void:
    if reasignando != "":
        if k != KEY_ESCAPE:
            Ajustes.asignar_tecla(reasignando, k)
            _sonido("interfaz", -8.0, 1.2)
        reasignando = ""
        return
    if k == KEY_ESCAPE:
        if legal != "":
            legal = ""
        else:
            elegir(&"volver")
        return
    var foco: Array = enfocables()
    if foco.is_empty():
        return
    seleccion = clampi(seleccion, 0, foco.size() - 1)
    var w: Dictionary = foco[seleccion]
    if k in [KEY_DOWN, KEY_S]:
        seleccion = (seleccion + 1) % foco.size()
    elif k in [KEY_UP, KEY_W]:
        seleccion = (seleccion + foco.size() - 1) % foco.size()
    elif k in [KEY_LEFT, KEY_RIGHT, KEY_A, KEY_D]:
        var dir: float = -1.0 if k in [KEY_LEFT, KEY_A] else 1.0
        if w["kind"] == "slider":
            Ajustes.datos[w["id"]] = clampf(float(Ajustes.obtener(w["id"])) + 0.05 * dir, 0.0, 1.0)
            Ajustes.aplicar_audio()
        elif w["kind"] == "choice":
            activar(w)
        elif legal == "":
            _pestana_siguiente(1 if dir > 0.0 else -1)
    elif k in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
        activar(w)
    elif k == KEY_TAB and legal == "":
        _pestana_siguiente(1)


func _pestana_siguiente(paso: int) -> void:
    pestana = posmod(pestana + paso, PESTANAS.size())
    seleccion = 0


func _unhandled_input(event: InputEvent) -> void:
    if not is_visible_in_tree():
        return
    if event is InputEventKey and event.pressed and not event.echo:
        get_viewport().set_input_as_handled()
        tecla((event as InputEventKey).keycode)
        queue_redraw()
        return
    if event is InputEventJoypadButton and event.pressed:
        var b: int = (event as InputEventJoypadButton).button_index
        if reasignando != "":
            # Las teclas se reasignan con teclado; el mando tiene su esquema fijo.
            reasignando = ""
            Eventos.aviso_pedido.emit(_t("mando_reasignar"), 2.4)
        elif b in [JOY_BUTTON_LEFT_SHOULDER, JOY_BUTTON_RIGHT_SHOULDER] and legal == "":
            _pestana_siguiente(1 if b == JOY_BUTTON_RIGHT_SHOULDER else -1)
        elif b == JOY_BUTTON_A:
            tecla(KEY_ENTER)
        elif b in [JOY_BUTTON_B, JOY_BUTTON_START]:
            tecla(KEY_ESCAPE)
        else:
            var d := direccion(event)
            if d != Vector2i.ZERO:
                tecla(_tecla_de(d))
        get_viewport().set_input_as_handled()
        queue_redraw()
        return
    var dir := direccion(event)
    if dir != Vector2i.ZERO:
        get_viewport().set_input_as_handled()
        tecla(_tecla_de(dir))
        queue_redraw()


func _tecla_de(d: Vector2i) -> int:
    if d == Vector2i.UP:
        return KEY_UP
    if d == Vector2i.DOWN:
        return KEY_DOWN
    return KEY_LEFT if d == Vector2i.LEFT else KEY_RIGHT
