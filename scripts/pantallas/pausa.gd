extends "res://scripts/pantallas/pantalla.gd"
## Menú de pausa. Las opciones llegan en datos["opciones"] como
## [[id, texto], …] (cambian si se está en el tutorial). La primera es
## siempre «reanudar». Al elegir, emite accion(id).
##
## Teclas: ESC o la tecla de pausa → reanudar · ↑↓/W S → moverse ·
## ENTER/ESPACIO/E → elegir. Mando: START/B → reanudar, cruceta y A.

const BOTON := preload("res://scenes/ui/boton_templo.tscn")
const ALTO_FILA := 62.0

@onready var _panel: Control = $Panel
@onready var _lista: Control = $Lista
@onready var _aviso: Control = $Aviso

var _ids: Array[StringName] = []


func _al_entrar() -> void:
    $Titulo.texto = str(datos.get("titulo", "Pausa"))
    _aviso.texto = str(datos.get("aviso_abandono", ""))
    var opciones: Array = datos.get("opciones", [])
    _construir(opciones)
    _panel.size.y = 90.0 + float(opciones.size()) * ALTO_FILA
    _aviso.position.y = _panel.position.y + _panel.size.y + 24.0 - float(_aviso.tam)
    if _lista.get_child_count() > 0:
        (_lista.get_child(0) as Control).grab_focus()
    _actualizar_aviso()


func _al_salir() -> void:
    var foco: Control = get_viewport().gui_get_focus_owner() if is_inside_tree() else null
    if foco != null and is_ancestor_of(foco):
        foco.release_focus()


func _construir(opciones: Array) -> void:
    var iguales: bool = _ids.size() == opciones.size()
    for i in range(opciones.size()):
        if iguales and _ids[i] != StringName(str(opciones[i][0])):
            iguales = false
    if iguales:
        for i in range(opciones.size()):
            (_lista.get_child(i) as Control).set("texto", str(opciones[i][1]))
        return
    for hijo in _lista.get_children():
        _lista.remove_child(hijo)
        hijo.queue_free()
    _ids.clear()
    for i in range(opciones.size()):
        var id := StringName(str(opciones[i][0]))
        var b: Control = BOTON.instantiate()
        b.name = String(id)
        b.set("variante", "menu")
        b.set("texto", str(opciones[i][1]))
        b.set("principal", i == 0)
        b.position = Vector2(0, float(i) * ALTO_FILA)
        b.size = Vector2(300, 50)
        b.pressed.connect(elegir.bind(id))
        b.focus_entered.connect(_actualizar_aviso)
        b.mouse_entered.connect(b.grab_focus)
        _lista.add_child(b)
        _ids.append(id)
    # Navegación en círculo: de la última se pasa a la primera.
    var n: int = _lista.get_child_count()
    for i in range(n):
        var b: Control = _lista.get_child(i)
        b.focus_neighbor_top = b.get_path_to(_lista.get_child((i + n - 1) % n))
        b.focus_neighbor_bottom = b.get_path_to(_lista.get_child((i + 1) % n))


## Índice de la opción con el foco (-1 si ninguna).
func seleccion() -> int:
    for i in range(_lista.get_child_count()):
        if (_lista.get_child(i) as Control).has_focus():
            return i
    return -1


func _actualizar_aviso() -> void:
    var i := seleccion()
    _aviso.visible = i >= 0 and _ids[i] == &"volver_inicio"


func _draw() -> void:
    var margen: Vector2 = datos.get("margen", Vector2.ZERO)
    draw_rect(Rect2(-margen, size + margen * 2.0), Color(0, 0, 0, 0.7))


func _mover(paso: int) -> void:
    var n: int = _lista.get_child_count()
    if n == 0:
        return
    var i: int = seleccion()
    (_lista.get_child((maxi(i, 0) + paso + n) % n) as Control).grab_focus()


func _unhandled_input(event: InputEvent) -> void:
    if not is_visible_in_tree():
        return
    if event is InputEventKey and event.pressed and not event.echo:
        var k: Key = (event as InputEventKey).keycode
        if k == KEY_ESCAPE or k == int(datos.get("tecla_pausa", KEY_ESCAPE)):
            get_viewport().set_input_as_handled()
            elegir(&"reanudar")
        elif k in [KEY_S, KEY_DOWN]:
            get_viewport().set_input_as_handled()
            _mover(1)
        elif k in [KEY_W, KEY_UP]:
            get_viewport().set_input_as_handled()
            _mover(-1)
        elif k == KEY_E:
            get_viewport().set_input_as_handled()
            var i := seleccion()
            elegir(_ids[maxi(i, 0)])
    elif event is InputEventJoypadButton and event.pressed:
        var b: int = (event as InputEventJoypadButton).button_index
        if b in [JOY_BUTTON_START, JOY_BUTTON_B]:
            get_viewport().set_input_as_handled()
            elegir(&"reanudar")
