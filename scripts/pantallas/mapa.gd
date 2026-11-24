extends "res://scripts/pantallas/pantalla.gd"
## Mapa grande: «ESTE PISO» (las salas) y «DESCENSO» (los pisos bajados).
## La campaña decide qué se sabe de cada sala y de cada piso.
##
## Datos: «pestana», «titulo_piso», «salas» ({vista, aqui, numero, nombre,
## mision, mision_hecha, cofre, color_cofre, caidas}), «enlaces» (bool por
## tramo), «pisos» ({conocido, aqui, superado, numero, titulo, etiqueta,
## caidas, cofres, color_cofres}), «verdad», «ayuda», «tecla_interactuar».
## Acciones: «pestana» (valor = 0/1), «cambiar» y «cerrar».

const PANEL := Rect2(48, 34, 864, 572)
const PESTANAS := [Rect2(330, 92, 140, 34), Rect2(490, 92, 140, 34)]

var _t: float = 0.0


func actualizar(delta: float) -> void:
    _t += delta
    queue_redraw()


func _draw() -> void:
    oscurecer(Color(0, 0, 0, 0.72))
    Estilo.panel(self, PANEL, Color(0.035, 0.032, 0.045, 0.97), Estilo.ORO)
    Estilo.titulo(self, "Mapa", Vector2(PANEL.position.x, PANEL.position.y + 44.0), 40, Estilo.CREMA, PANEL.size.x)
    var nombres := ["ESTE PISO", "DESCENSO"]
    var pestana: int = int(datos.get("pestana", 0))
    for i in range(2):
        var r: Rect2 = PESTANAS[i]
        var on: bool = i == pestana
        Estilo.panel(self, r, Color("#2a1d36") if on else Color("#141018"), Estilo.ORO if on else Estilo.BORDE)
        Estilo.texto(self, nombres[i], Vector2(r.position.x, r.position.y + 22.0), 13, Estilo.CREMA if on else Color("#8a8574"), r.size.x)
    if pestana == 0:
        _dibujar_piso()
    else:
        _dibujar_descenso()
    Estilo.texto(self, str(datos.get("ayuda", "")), Vector2(PANEL.position.x, PANEL.end.y - 14.0), 11, Color("#8a8574"), PANEL.size.x)


func _dibujar_piso() -> void:
    Estilo.texto(self, str(datos.get("titulo_piso", "")), Vector2(PANEL.position.x, 160.0), 16, Estilo.ORO, PANEL.size.x)
    var salas: Array = datos.get("salas", [])
    var enlaces: Array = datos.get("enlaces", [])
    var n: int = salas.size()
    var tam := Vector2(146, 230)
    var hueco: float = 22.0
    var x0: float = roundf(Estilo.ANCHO * 0.5 - (float(n) * tam.x + float(n - 1) * hueco) * 0.5)
    for i in range(n):
        var s: Dictionary = salas[i]
        var r := Rect2(x0 + float(i) * (tam.x + hueco), 196.0, tam.x, tam.y)
        if i < n - 1:
            draw_rect(Rect2(r.end.x, r.position.y + tam.y * 0.5 - 3.0, hueco, 6.0), Estilo.ORO if i < enlaces.size() and bool(enlaces[i]) else Color("#2a2e38"))
        var aqui: bool = bool(s.get("aqui", false))
        var vista: bool = bool(s.get("vista", false))
        var pulso: float = 0.6 + 0.4 * sin(_t * 4.0)
        Estilo.panel(self, r, Color(0.78, 0.67, 0.43, 0.18 + 0.1 * pulso) if aqui else (Color("#1d212b") if vista else Color("#0e1016")), Estilo.ORO if aqui else (Estilo.CLARO if vista else Color("#2a2e38")))
        if not vista:
            Estilo.texto(self, "???", Vector2(r.position.x, r.get_center().y + 8.0), 22, Color("#4a4e5a"), r.size.x)
            continue
        Estilo.texto(self, str(s.get("numero", "")), Vector2(r.position.x, r.position.y + 26.0), 15, Estilo.ORO, r.size.x)
        draw_multiline_string(Estilo.fuente(), Vector2(r.position.x + 8.0, r.position.y + 50.0), str(s.get("nombre", "")), HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 16.0, 12, 4, Estilo.CREMA)
        var y: float = r.position.y + 130.0
        if str(s.get("mision", "")) != "":
            var hecha: bool = bool(s.get("mision_hecha", false))
            draw_multiline_string(Estilo.fuente(), Vector2(r.position.x + 8.0, y - 10.0), ("✓ " if hecha else "· ") + str(s["mision"]), HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 16.0, 10, 3, Color("#7fd6a0") if hecha else Color("#d9d2ba"))
            y += 40.0
        if str(s.get("cofre", "")) != "":
            Estilo.texto(self, str(s["cofre"]), Vector2(r.position.x, y), 10, s.get("color_cofre", Color("#ffd36b")), r.size.x)
            y += 20.0
        if str(s.get("caidas", "")) != "":
            Estilo.texto(self, str(s["caidas"]), Vector2(r.position.x, y), 10, Color("#ff8a8a"), r.size.x)
        if aqui:
            Estilo.texto(self, "ESTÁS AQUÍ", Vector2(r.position.x, r.end.y - 12.0), 11, Estilo.CREMA, r.size.x)


## Solo se dibujan los pisos a los que has bajado, y uno más por descubrir.
func _dibujar_descenso() -> void:
    var pisos: Array = datos.get("pisos", [])
    var filas: int = pisos.size()
    var arriba: float = 150.0
    var alto: float = minf(38.0, 380.0 / float(maxi(filas, 1)))
    var x: float = 170.0
    if filas > 1:
        draw_rect(Rect2(x - 2.0, arriba + 8.0, 4.0, alto * float(filas - 1)), Color("#3a3440"))
    for i in range(filas):
        var p: Dictionary = pisos[i]
        var y: float = arriba + float(i) * alto
        var conocido: bool = bool(p.get("conocido", false))
        var aqui: bool = bool(p.get("aqui", false))
        var superado: bool = bool(p.get("superado", false))
        draw_circle(Vector2(x, y + 10.0), 8.0 if aqui else 6.0, Estilo.ORO if aqui else (Color("#7fd6a0") if superado else (Estilo.CREMA if conocido else Color("#4a4e5a"))))
        if aqui:
            draw_arc(Vector2(x, y + 10.0), 13.0 + 2.0 * sin(_t * 4.0), 0, TAU, 24, Estilo.ORO, 2.0)
        if not conocido:
            Estilo.texto(self, "PISO ???  ·  más abajo", Vector2(x + 24.0, y + 15.0), 13, Color("#4a4e5a"))
            continue
        Estilo.texto(self, "PISO %s" % str(p.get("numero", "")), Vector2(x + 24.0, y + 15.0), 13, Estilo.ORO)
        Estilo.texto(self, str(p.get("titulo", "")), Vector2(x + 110.0, y + 15.0), 13, Estilo.CREMA)
        if str(p.get("etiqueta", "")) != "":
            Estilo.texto(self, str(p["etiqueta"]), Vector2(560.0, y + 15.0), 11, Estilo.ORO if aqui else Color("#7fd6a0"))
        if str(p.get("caidas", "")) != "":
            Estilo.texto(self, str(p["caidas"]), Vector2(660.0, y + 15.0), 11, Color("#ff8a8a"))
        if str(p.get("cofres", "")) != "":
            Estilo.texto(self, str(p["cofres"]), Vector2(760.0, y + 15.0), 11, p.get("color_cofres", Color("#ffd36b")))
    if str(datos.get("verdad", "")) != "":
        draw_multiline_string(Estilo.fuente(), Vector2(PANEL.position.x + 60.0, 560.0), "«%s»" % str(datos["verdad"]), HORIZONTAL_ALIGNMENT_CENTER, PANEL.size.x - 120.0, 12, 2, Color("#9fb3b3"))


func _gui_input(event: InputEvent) -> void:
    var en: Variant = clic_de(event)
    if en == null:
        return
    accept_event()
    for i in range(2):
        if (PESTANAS[i] as Rect2).grow(6.0).has_point(en):
            elegir(&"pestana", i)
            return
    elegir(&"cerrar")


func _unhandled_input(event: InputEvent) -> void:
    if not is_visible_in_tree():
        return
    var k := tecla_de(event)
    var b := boton_de(event)
    var hecho := true
    if k in [KEY_M, KEY_ESCAPE, KEY_E, KEY_ENTER, int(datos.get("tecla_interactuar", KEY_E))] or b in [JOY_BUTTON_A, JOY_BUTTON_B, JOY_BUTTON_BACK, JOY_BUTTON_START]:
        elegir(&"cerrar")
    elif k in [KEY_TAB, KEY_PAGEDOWN, KEY_PAGEUP] or b in [JOY_BUTTON_LEFT_SHOULDER, JOY_BUTTON_RIGHT_SHOULDER] or direccion(event).x != 0:
        elegir(&"cambiar")
    else:
        hecho = false
    if hecho:
        get_viewport().set_input_as_handled()
