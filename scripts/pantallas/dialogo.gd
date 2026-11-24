extends "res://scripts/pantallas/pantalla.gd"
## Cuadro de diálogo. La campaña lleva la cola de frases y cuántas letras se
## ven (efecto de máquina de escribir); esta escena solo las muestra.
##
## Datos: «quien», «color_quien», «texto», «letras», «mas» (aviso de seguir,
## vacío mientras se escribe), «tecla_interactuar».
## Acciones: «avanzar» (clic/toque, ENTER, ESPACIO, E, A, B) y «saltar»
## (botón SALTAR, ESC, Y, START).

const CAJA := Rect2(110, 432, 740, 128)

var _t: float = 0.0


func _ready() -> void:
    $Saltar.pressed.connect(elegir.bind(&"saltar"))


func actualizar(delta: float) -> void:
    _t += delta
    queue_redraw()


func _draw() -> void:
    oscurecer(Color(0, 0, 0, 0.25))
    Estilo.panel(self, CAJA, Color(0.04, 0.045, 0.06, 0.95), Estilo.ORO)
    draw_rect(CAJA.grow(-6.0), Color(1, 1, 1, 0.04), false, 1.0)
    var quien: String = str(datos.get("quien", ""))
    var col: Color = datos.get("color_quien", Estilo.ALMA)
    var etiqueta := Rect2(CAJA.position + Vector2(18, -16), Vector2(maxf(120.0, Estilo.fuente().get_string_size(quien, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x + 30.0), 28))
    Estilo.panel(self, etiqueta, Color("#2a1d22"), col)
    Estilo.texto(self, quien, Vector2(etiqueta.position.x, etiqueta.position.y + 20.0), 15, col, etiqueta.size.x)
    var texto: String = str(datos.get("texto", ""))
    draw_multiline_string(Estilo.fuente(), CAJA.position + Vector2(24, 44), texto.substr(0, int(datos.get("letras", 0))), HORIZONTAL_ALIGNMENT_LEFT, CAJA.size.x - 48.0, 18, 3, Estilo.CREMA)
    var mas: String = str(datos.get("mas", ""))
    if mas != "":
        var pulso: float = 0.5 + 0.5 * sin(_t * 5.0)
        Estilo.texto(self, mas, Vector2(CAJA.end.x - 230.0, CAJA.end.y - 12.0), 12, Color(Estilo.ORO.r, Estilo.ORO.g, Estilo.ORO.b, 0.5 + 0.5 * pulso), 210.0)


func _gui_input(event: InputEvent) -> void:
    if clic_de(event) != null:
        accept_event()
        elegir(&"avanzar")


func _unhandled_input(event: InputEvent) -> void:
    if not is_visible_in_tree():
        return
    var k := tecla_de(event)
    var b := boton_de(event)
    if k == KEY_ESCAPE or b in [JOY_BUTTON_Y, JOY_BUTTON_START]:
        get_viewport().set_input_as_handled()
        elegir(&"saltar")
    elif k in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_E, int(datos.get("tecla_interactuar", KEY_E))] or b in [JOY_BUTTON_A, JOY_BUTTON_B]:
        get_viewport().set_input_as_handled()
        elegir(&"avanzar")
