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
## Capa de las reliquias: encima del panel (el _draw propio queda debajo de
## los hijos) y debajo de los textos y botones.
var _reliquias := Control.new()


func _ready() -> void:
    Estilo.preparar_fuentes()
    _reliquias.name = "Reliquias"
    _reliquias.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _reliquias.size = size
    _reliquias.draw.connect(_dibujar_reliquias)
    add_child(_reliquias)
    move_child(_reliquias, $Panel.get_index() + 1)
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


## Reliquias en 3D que flotan a los lados del título: [modelo, hueco].
const RELIQUIAS := [["reliquia", Rect2(170, 206, 88, 88)], ["calavera", Rect2(702, 206, 88, 88)]]


func actualizar(_delta: float) -> void:
    pass


func _process(_delta: float) -> void:
    if is_visible_in_tree():
        _reliquias.queue_redraw() # las vitrinas solo giran mientras se piden


func _draw() -> void:
    var margen: Vector2 = datos.get("margen", Vector2.ZERO)
    draw_rect(Rect2(-margen, size + margen * 2.0), Color(0.018, 0.027, 0.032, 0.62))


func _dibujar_reliquias() -> void:
    for r in RELIQUIAS:
        var hueco: Rect2 = r[1]
        var pie := Vector2(hueco.get_center().x, hueco.get_center().y + 38.0)
        # Halo en el suelo: la luz que suelta la reliquia.
        for i in range(4):
            var k: float = float(4 - i) / 4.0
            _reliquias.draw_set_transform(pie, 0.0, Vector2(1.0, 0.3))
            _reliquias.draw_circle(Vector2.ZERO, 30.0 * k, Color(0.5, 0.85, 1.0, 0.05) if r[0] == "reliquia" else Color(0.9, 0.7, 0.4, 0.04))
        _reliquias.draw_set_transform(Vector2.ZERO)
        Vitrinas.dibujar(_reliquias, str(r[0]), hueco)


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
