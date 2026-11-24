extends "res://scripts/pantallas/pantalla.gd"
## Antes de entrar en un piso: una ventana circular a la sala, el número y el
## nombre del piso y la recompensa. Nada habla hasta pulsar ENTRAR.
##
## Datos: «numero», «titulo», «eco_ganado», «recompensa», «ayuda».
## Acción: «entrar» (ENTER, E, ESPACIO, A, clic o toque).

var _t: float = 0.0


func actualizar(delta: float) -> void:
    _t += delta
    queue_redraw()


func _draw() -> void:
    var c := Vector2(480, 330)
    var r_in: float = 128.0
    var oscuro := Color(0.01, 0.015, 0.02, 0.96)
    var seg: int = 64
    for i in range(seg):
        var a0: float = TAU * float(i) / float(seg)
        var a1: float = TAU * float(i + 1) / float(seg)
        draw_colored_polygon(PackedVector2Array([
            c + Vector2.from_angle(a0) * r_in, c + Vector2.from_angle(a0) * 1200.0,
            c + Vector2.from_angle(a1) * 1200.0, c + Vector2.from_angle(a1) * r_in]), oscuro)
    for k in range(6):
        draw_arc(c, r_in - float(k) * 4.0, 0.0, TAU, seg, Color(0.01, 0.015, 0.02, 0.5 - float(k) * 0.08), 4.0)
    draw_arc(c, r_in + 2.0, 0.0, TAU, seg, Color("#8d7957"), 2.0)
    Estilo.titulo(self, "Piso %s" % str(datos.get("numero", "")), Vector2(0, 124), 24, Estilo.ORO, Estilo.ANCHO)
    Estilo.titulo(self, str(datos.get("titulo", "")), Vector2(0, 176), 48, Estilo.CREMA, Estilo.ANCHO)
    if str(datos.get("eco_ganado", "")) != "":
        Estilo.centrado(self, str(datos["eco_ganado"]), 474, 13, Estilo.ALMA)
    if str(datos.get("recompensa", "")) != "":
        Estilo.centrado(self, str(datos["recompensa"]), 504, 14, Color("#ffd36b"))
    var pulso: float = 0.6 + 0.4 * sin(_t * 3.0)
    Estilo.centrado(self, str(datos.get("ayuda", "")), 560, 18, Color(0.89, 0.74, 0.48, pulso))


func _gui_input(event: InputEvent) -> void:
    if clic_de(event) != null:
        accept_event()
        elegir(&"entrar")


func _unhandled_input(event: InputEvent) -> void:
    if is_visible_in_tree() and (tecla_de(event) in [KEY_ENTER, KEY_KP_ENTER, KEY_E, KEY_SPACE] or boton_de(event) in [JOY_BUTTON_A, JOY_BUTTON_START]):
        get_viewport().set_input_as_handled()
        elegir(&"entrar")
