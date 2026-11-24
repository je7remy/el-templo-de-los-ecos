extends "res://scripts/pantallas/pantalla.gd"
## Menú principal: JUGAR (elegir piso), VIGILIA, SALIR, cambiar de personaje,
## configuración y el aviso de versión nueva.
##
## Acciones: «jugar», «vigilia», «salir», «ajustes», «cambiar_personaje».
## Teclas: ENTER/P jugar · H vigilia · C cambiar · ESC salir · U actualizar.
## Mando: A el botón con foco · START/Y jugar · RB vigilia · X cambiar ·
## SELECT configuración · B salir.

@onready var _jugar: Control = $Jugar
@onready var _vigilia: Control = $Vigilia
@onready var _aviso: Control = $AvisoActualizacion


func _ready() -> void:
    Estilo.preparar_fuentes()
    _jugar.pressed.connect(elegir.bind(&"jugar"))
    _vigilia.pressed.connect(elegir.bind(&"vigilia"))
    $Salir.pressed.connect(elegir.bind(&"salir"))
    $Engranaje.pressed.connect(elegir.bind(&"ajustes"))
    $Cambiar.pressed.connect(elegir.bind(&"cambiar_personaje"))


func _al_entrar() -> void:
    var abierta: bool = bool(datos.get("vigilia_abierta", false))
    _vigilia.relleno = Color("#43301a") if abierta else Color("#1a1620")
    _vigilia.borde = Estilo.ORO if abierta else Color("#4a4452")
    $Bloqueada.visible = not abierta
    $Bloqueada.texto = str(datos.get("bloqueada", "BLOQUEADA"))
    $Genero.texto = "ROGUELIKE DE TERROR · PISOS I–%s · REGLAS POR DESCUBRIR" % str(datos.get("ultimo_piso", "X"))
    $Ayuda.texto = str(datos.get("ayuda", ""))
    $Salir.texto = str(datos.get("salir", "SALIR"))
    var nombre: String = str(datos.get("nombre", ""))
    $Retrato.visible = nombre != ""
    $Cambiar.visible = nombre != ""
    if nombre != "":
        $Retrato.texture = datos.get("retrato", null)
        $Ficha.texto = "%s · ID %03d   |   MUERTES %d" % [nombre, int(datos.get("id", 1)), int(datos.get("muertes", 0))]
        $Ficha.color = Estilo.CREMA
        $Cambiar.texto = str(datos.get("cambiar", ""))
    else:
        $Ficha.texto = str(datos.get("sin_personaje", ""))
        $Ficha.color = Estilo.GRIS
    _aviso.vincular(datos.get("actualizador", null))
    if str(datos.get("entrada", "")) != "tactil" and not _algo_con_foco():
        _jugar.grab_focus()


func _al_salir() -> void:
    var foco: Control = get_viewport().gui_get_focus_owner() if is_inside_tree() else null
    if foco != null and is_ancestor_of(foco):
        foco.release_focus()


func _algo_con_foco() -> bool:
    var foco: Control = get_viewport().gui_get_focus_owner()
    return foco != null and is_ancestor_of(foco) and foco.is_visible_in_tree()


func actualizar(_delta: float) -> void:
    pass


func _draw() -> void:
    var margen: Vector2 = datos.get("margen", Vector2.ZERO)
    draw_rect(Rect2(-margen, size + margen * 2.0), Color(0.018, 0.027, 0.032, 0.62))


func _unhandled_input(event: InputEvent) -> void:
    if not is_visible_in_tree():
        return
    if event is InputEventKey and event.pressed and not event.echo:
        var k: Key = (event as InputEventKey).keycode
        var eleccion: StringName = &""
        match k:
            KEY_ENTER, KEY_KP_ENTER, KEY_P:
                eleccion = &"jugar"
            KEY_H:
                eleccion = &"vigilia"
            KEY_C:
                eleccion = &"cambiar_personaje" if $Cambiar.visible else &"jugar"
            KEY_ESCAPE:
                eleccion = &"salir"
        if eleccion != &"":
            get_viewport().set_input_as_handled()
            elegir(eleccion)
    elif event is InputEventJoypadButton and event.pressed:
        var eleccion: StringName = &""
        match (event as InputEventJoypadButton).button_index:
            JOY_BUTTON_START, JOY_BUTTON_Y:
                eleccion = &"jugar"
            JOY_BUTTON_RIGHT_SHOULDER:
                eleccion = &"vigilia"
            JOY_BUTTON_X:
                eleccion = &"cambiar_personaje" if $Cambiar.visible else &""
            JOY_BUTTON_BACK:
                eleccion = &"ajustes"
            JOY_BUTTON_B:
                eleccion = &"salir"
        if eleccion != &"":
            get_viewport().set_input_as_handled()
            elegir(eleccion)
