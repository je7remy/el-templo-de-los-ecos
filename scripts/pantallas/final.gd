extends "res://scripts/pantallas/pantalla.gd"
## Pantalla de muerte o de victoria. La campaña decide el texto (según cómo
## terminó la partida) y si ya se puede cerrar: los primeros segundos no
## responde, para que un toque de más no la cierre antes de leerla.
##
## Datos: «lineas» ([{texto, y, tam, color, gotico}], …), «aviso» {texto, y},
## «espera» (0 → 1 mientras no se puede cerrar), «vineta» (-1 sin viñeta roja).
## Acciones: «seguir» (ENTER, A, clic o toque) y «menu» (ESC, B).

func _draw() -> void:
    oscurecer(Color(0, 0, 0, 0.75))
    var k: float = float(datos.get("vineta", -1.0))
    if k >= 0.0:
        for i in range(6):
            var g: float = float(i) * 18.0
            draw_rect(Rect2(g, g, Estilo.ANCHO - g * 2.0, Estilo.ALTO - g * 2.0), Color(0.45, 0.02, 0.06, 0.07 * k), false, 18.0)
    for l in datos.get("lineas", []):
        var d: Dictionary = l
        if bool(d.get("gotico", false)):
            Estilo.titulo(self, str(d["texto"]), Vector2(0, float(d["y"])), int(d.get("tam", 48)), d.get("color", Estilo.CREMA), Estilo.ANCHO)
        else:
            Estilo.centrado(self, str(d["texto"]), float(d["y"]), int(d.get("tam", 16)), d.get("color", Estilo.CREMA))
    var aviso: Dictionary = datos.get("aviso", {})
    if aviso.is_empty():
        return
    var y: float = float(aviso.get("y", 418))
    var espera: float = float(datos.get("espera", 1.0))
    if espera < 1.0:
        var barra := Rect2(Estilo.ANCHO * 0.5 - 90.0, y - 8.0, 180.0, 4.0)
        draw_rect(barra, Color(1, 1, 1, 0.10))
        draw_rect(Rect2(barra.position, Vector2(barra.size.x * espera, barra.size.y)), Color(Estilo.CREMA.r, Estilo.CREMA.g, Estilo.CREMA.b, 0.45))
        return
    var a: float = 0.65 + 0.35 * sin(float(datos.get("t", 0.0)) * 3.0)
    Estilo.centrado(self, str(aviso.get("texto", "")), y, 18, Color(Estilo.CREMA.r, Estilo.CREMA.g, Estilo.CREMA.b, a))


func _gui_input(event: InputEvent) -> void:
    if clic_de(event) != null:
        accept_event()
        elegir(&"seguir")


func _unhandled_input(event: InputEvent) -> void:
    if not is_visible_in_tree():
        return
    var k := tecla_de(event)
    var b := boton_de(event)
    if k in [KEY_ENTER, KEY_KP_ENTER] or b in [JOY_BUTTON_A, JOY_BUTTON_START]:
        get_viewport().set_input_as_handled()
        elegir(&"seguir")
    elif k == KEY_ESCAPE or b == JOY_BUTTON_B:
        get_viewport().set_input_as_handled()
        elegir(&"menu")
