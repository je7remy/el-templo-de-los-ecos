extends "res://scripts/pantallas/pantalla.gd"
## Intro: cinco diapositivas con un dibujo y un texto que se escribe solo.
## La campaña lleva qué diapositiva toca y cuánto texto se ve.
##
## Datos: «tipo» (despertar, templo, ojo, almas, descenso), «fundido»,
## «abrir» (el ojo), «texto», «indice», «total», «siguiente», «hoja»,
## «alma», «cuerpos», «t».
## Acciones: «siguiente» (clic, ENTER, ESPACIO, E, A, START) y «saltar»
## (botón SALTAR, ESC, B, SELECT).

func _ready() -> void:
    $Saltar.pressed.connect(elegir.bind(&"saltar"))


func _draw() -> void:
    oscurecer(Color(0, 0, 0, 1.0))
    var fundido: float = float(datos.get("fundido", 1.0))
    var t: float = float(datos.get("t", 0.0))
    var c := Vector2(480, 270)
    match str(datos.get("tipo", "")):
        "despertar":
            # Tendido en un círculo de luz mortecina.
            draw_circle(c + Vector2(0, 30), 120.0, Color(0.35, 0.45, 0.5, 0.10 * fundido))
            if datos.get("hoja") != null:
                draw_texture_rect_region(datos["hoja"], Rect2(c + Vector2(-60, -50), Vector2(120, 168)), Rect2(8.0 * 40.0, 0.0, 40.0, 56.0), Color(1, 1, 1, fundido))
        "templo":
            draw_set_transform(Vector2(-240, -160) * fundido * 0.05)
            for k in range(4):
                var x: float = 230.0 + float(k) * 170.0
                draw_rect(Rect2(x, 150, 28, 260), Color(0.25, 0.3, 0.28, 0.6 * fundido))
                draw_rect(Rect2(x - 8, 140, 44, 14), Color(0.35, 0.4, 0.36, 0.6 * fundido))
            draw_set_transform(Vector2.ZERO)
        "ojo":
            var abrir: float = float(datos.get("abrir", 1.0))
            draw_set_transform(c, 0.0, Vector2(1.0, 0.15 + 0.85 * abrir))
            draw_circle(Vector2.ZERO, 110.0, Color(0.85, 0.82, 0.74, fundido))
            draw_circle(Vector2.ZERO, 58.0, Color(0.42, 0.24, 0.57, fundido))
            draw_circle(Vector2.ZERO, 26.0, Color(0.05, 0.03, 0.07, fundido))
            draw_set_transform(Vector2.ZERO)
            for k in range(6):
                var a: float = float(k) * 1.05
                draw_line(c + Vector2.from_angle(a) * 80.0, c + Vector2.from_angle(a + 0.2) * 108.0, Color(0.76, 0.23, 0.25, 0.7 * fundido), 2.0)
        "almas":
            var cuerpos: Array = datos.get("cuerpos", [])
            for k in range(3):
                var p := c + Vector2(-160.0 + float(k) * 160.0, 40.0)
                if not cuerpos.is_empty():
                    var tex: Texture2D = cuerpos[k % cuerpos.size()]
                    var tam := Vector2(tex.get_width(), tex.get_height())
                    var dest := Rect2(roundf(p.x - tam.x * 0.5), roundf(p.y + 4.0 - tam.y * 0.5), tam.x, tam.y)
                    if k % 2 == 1: # variedad: espejo
                        draw_set_transform(Vector2(dest.end.x, dest.position.y), 0.0, Vector2(-1, 1))
                        draw_texture_rect(tex, Rect2(Vector2.ZERO, dest.size), false)
                        draw_set_transform(Vector2.ZERO)
                    else:
                        draw_texture_rect(tex, dest, false)
                draw_circle(p + Vector2(0, -26), 30.0, Color(0.56, 0.78, 0.84, 0.15 * fundido))
                if datos.get("alma") != null:
                    draw_texture_rect(datos["alma"], Rect2(p + Vector2(-16, -46 + sin(t * 2.0 + float(k)) * 4.0), Vector2(32, 32)), false, Color(1, 1, 1, fundido))
        "descenso":
            for k in range(6):
                var w: float = 300.0 - float(k) * 44.0
                draw_rect(Rect2(480.0 - w * 0.5, 140.0 + float(k) * 34.0, w, 26), Color(0.20, 0.24, 0.24, (0.7 - float(k) * 0.1) * fundido))
            draw_circle(Vector2(480, 380), 14.0, Color(1.0, 0.7, 0.3, 0.5 + 0.3 * sin(t * 9.0)))
    Estilo.texto(self, str(datos.get("texto", "")), Vector2(0, 500), 20, Estilo.CREMA, Estilo.ANCHO)
    var indice: int = int(datos.get("indice", 0))
    for k in range(int(datos.get("total", 0))):
        draw_rect(Rect2(430.0 + float(k) * 22.0, 540, 14, 4), Estilo.ORO if k <= indice else Color("#2a2e38"))
    Estilo.texto(self, str(datos.get("siguiente", "")), Vector2(24, 622), 12, Color("#8a8574"))


func _gui_input(event: InputEvent) -> void:
    if clic_de(event) != null:
        accept_event()
        elegir(&"siguiente")


func _unhandled_input(event: InputEvent) -> void:
    if not is_visible_in_tree():
        return
    var k := tecla_de(event)
    var b := boton_de(event)
    if k == KEY_ESCAPE or b in [JOY_BUTTON_B, JOY_BUTTON_BACK]:
        get_viewport().set_input_as_handled()
        elegir(&"saltar")
    elif k in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_E] or b in [JOY_BUTTON_A, JOY_BUTTON_START]:
        get_viewport().set_input_as_handled()
        elegir(&"siguiente")
