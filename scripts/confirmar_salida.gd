extends CanvasLayer
## Pregunta antes de cerrar el juego (autoload «ConfirmarSalida»).
##
## Godot avisa con NOTIFICATION_WM_CLOSE_REQUEST al cerrar la ventana y con
## NOTIFICATION_WM_GO_BACK_REQUEST al pulsar «Atrás» en Android. Como el cierre
## automático está desactivado, aquí se muestra un cuadro con SÍ / NO. Mientras
## está abierto, el juego queda en pausa (este nodo sigue procesando).
## Es una escena de interfaz normal (Control + Button): funciona con ratón,
## toque, teclado y mando sin código propio de entrada.

signal respondida(salir: bool)

@onready var _fondo: Control = $Fondo
@onready var _si: Button = $Fondo/Panel/Margen/Caja/Botones/Si
@onready var _no: Button = $Fondo/Panel/Margen/Caja/Botones/No

var _pausa_previa: bool = false
var _fuentes_puestas: bool = false


func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    layer = 100
    _fondo.visible = false
    get_tree().set_auto_accept_quit(false)
    get_tree().set_quit_on_go_back(false)
    _si.pressed.connect(_responder.bind(true))
    _no.pressed.connect(_responder.bind(false))


func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
        preguntar()


func abierta() -> bool:
    return _fondo.visible


## Muestra el cuadro. Se puede llamar desde cualquier menú (p. ej., un botón SALIR).
func preguntar() -> void:
    if _fondo.visible:
        return
    _poner_fuentes()
    _pausa_previa = get_tree().paused
    get_tree().paused = true
    _fondo.visible = true
    _no.grab_focus() # por defecto, no salir


func _unhandled_input(event: InputEvent) -> void:
    if not _fondo.visible:
        return
    if event.is_action_pressed("ui_cancel"):
        _responder(false)
        get_viewport().set_input_as_handled()


func _responder(salir: bool) -> void:
    _fondo.visible = false
    get_tree().paused = _pausa_previa
    respondida.emit(salir)
    if salir:
        get_tree().quit()


## Las fuentes se cargan al abrir el cuadro, no al arrancar: así el autoload no
## pide recursos antes de que Godot los haya importado (primera importación).
func _poner_fuentes() -> void:
    if _fuentes_puestas:
        return
    _fuentes_puestas = true
    var pixel: Font = load("res://assets/fonts/Jersey15-Templo.ttf")
    var gotica: Font = load("res://assets/fonts/Jacquard24-Regular.ttf")
    for nodo in [$Fondo/Panel/Margen/Caja/Texto, _si, _no]:
        (nodo as Control).add_theme_font_override("font", pixel)
    ($Fondo/Panel/Margen/Caja/Titulo as Control).add_theme_font_override("font", gotica)
