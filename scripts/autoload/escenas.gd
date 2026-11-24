extends CanvasLayer
## Cambio de escena con pantalla de carga real (autoload «Escenas»).
##
##   Escenas.ir_a("res://scenes/defense.tscn")
##
## 1. Funde a negro.
## 2. Pide la escena en segundo plano (ResourceLoader.load_threaded_request)
##    y muestra la barra con el progreso de verdad mientras se carga.
## 3. Cambia a la escena ya cargada y vuelve a fundir.
## Mientras tanto la pantalla de carga frena los clics y las teclas.
## Sin pantalla (pruebas automáticas) cambia directamente.

const DURA_FUNDIDO := 0.18

@onready var carga: Control = $PantallaCarga

var ruta_pendiente: String = ""
var _fase: String = "" # "" | entrando | cargando | saliendo
var _t: float = 0.0


func _ready() -> void:
    layer = 100
    process_mode = Node.PROCESS_MODE_ALWAYS
    carga.visible = false
    set_process(false)


func ocupado() -> bool:
    return _fase != ""


func ir_a(ruta: String) -> void:
    if ocupado():
        return
    if DisplayServer.get_name() == "headless":
        Eventos.escena_cambiando.emit(ruta)
        get_tree().change_scene_to_file(ruta)
        Eventos.escena_cambiada.emit(ruta)
        return
    ruta_pendiente = ruta
    Eventos.escena_cambiando.emit(ruta)
    var err := ResourceLoader.load_threaded_request(ruta)
    if err != OK:
        push_warning("No se pudo empezar a cargar %s (error %d)." % [ruta, err])
        get_tree().change_scene_to_file(ruta)
        return
    carga.call("empezar")
    _fase = "entrando"
    _t = 0.0
    set_process(true)


func _process(delta: float) -> void:
    _t += delta
    match _fase:
        "entrando":
            carga.call("poner_opacidad", clampf(_t / DURA_FUNDIDO, 0.0, 1.0))
            if _t >= DURA_FUNDIDO:
                _fase = "cargando"
        "cargando":
            var progreso: Array = []
            var estado := ResourceLoader.load_threaded_get_status(ruta_pendiente, progreso)
            carga.call("poner_progreso", float(progreso[0]) if not progreso.is_empty() else 0.0)
            if estado == ResourceLoader.THREAD_LOAD_LOADED:
                var escena: PackedScene = ResourceLoader.load_threaded_get(ruta_pendiente)
                carga.call("poner_progreso", 1.0)
                get_tree().change_scene_to_packed(escena)
                _fase = "saliendo"
                _t = 0.0
            elif estado in [ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE]:
                push_warning("Falló la carga de %s." % ruta_pendiente)
                _fase = "saliendo"
                _t = 0.0
        "saliendo":
            carga.call("poner_opacidad", 1.0 - clampf(_t / DURA_FUNDIDO, 0.0, 1.0))
            if _t >= DURA_FUNDIDO:
                carga.visible = false
                _fase = ""
                set_process(false)
                Eventos.escena_cambiada.emit(ruta_pendiente)
