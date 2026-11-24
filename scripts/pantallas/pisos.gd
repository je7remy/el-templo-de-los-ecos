extends "res://scripts/pantallas/pantalla.gd"
## Menú de los diez pisos. Cada tarjeta es un botón; la primera vez que se
## toca se elige y la segunda se desciende (o DESCENDER). Las flechas, la
## cruceta y el stick mueven la selección; ENTER/A desciende; ESC/B vuelve.
##
## Datos: «pisos» (lista de tarjetas: numero, nombre, estado, color_estado,
## abierto, icono…), «seleccion» y «ayuda».
## Acciones: «piso» (valor = índice) y «volver».

const TARJETA := preload("res://scripts/ui/tarjeta_piso.gd")
const COLUMNAS := 5

@onready var _tarjetas: Control = $Tarjetas
@onready var _descender: Control = $Descender

var seleccion: int = 0
var _abiertos: Array = []


func _ready() -> void:
    $Volver.pressed.connect(elegir.bind(&"volver"))
    _descender.pressed.connect(func(): elegir(&"piso", seleccion))


func _al_entrar() -> void:
    var pisos: Array = datos.get("pisos", [])
    while _tarjetas.get_child_count() < pisos.size():
        var t: TextureButton = TARJETA.new()
        var i: int = _tarjetas.get_child_count()
        t.name = "Piso%d" % (i + 1)
        t.position = Vector2(float(i % COLUMNAS) * 152.0, float(i / COLUMNAS) * 178.0)
        t.size = Vector2(144, 168)
        t.pressed.connect(_tocar.bind(i))
        _tarjetas.add_child(t)
    _abiertos.clear()
    for i in range(_tarjetas.get_child_count()):
        var t: Node = _tarjetas.get_child(i)
        t.visible = i < pisos.size()
        if i < pisos.size():
            t.call("configurar", pisos[i])
            _abiertos.append(bool(pisos[i].get("abierto", false)))
    $Ayuda.texto = str(datos.get("ayuda", ""))
    _seleccionar(int(datos.get("seleccion", 0)))


func tarjeta(i: int) -> Control:
    return _tarjetas.get_child(i) as Control


func _seleccionar(i: int) -> void:
    var n: int = _abiertos.size()
    if n == 0:
        return
    seleccion = posmod(i, n)
    for k in range(_tarjetas.get_child_count()):
        _tarjetas.get_child(k).set("seleccionada", k == seleccion)
    var jugable: bool = bool(_abiertos[seleccion])
    _descender.texto = "DESCENDER »" if jugable else "BLOQUEADO"
    _descender.principal = jugable
    _descender.queue_redraw()


func _tocar(i: int) -> void:
    if i == seleccion:
        elegir(&"piso", i)
    else:
        _seleccionar(i)
        elegir(&"marcar") # solo el sonido de tocar


func _draw() -> void:
    var margen: Vector2 = datos.get("margen", Vector2.ZERO)
    draw_rect(Rect2(-margen, size + margen * 2.0), Color(0.012, 0.01, 0.02, 0.8))


func _unhandled_input(event: InputEvent) -> void:
    if not is_visible_in_tree():
        return
    var d := direccion(event)
    if d != Vector2i.ZERO:
        get_viewport().set_input_as_handled()
        if d.x != 0:
            _seleccionar(seleccion + d.x)
        else:
            _seleccionar(seleccion + COLUMNAS)
    elif es_aceptar(event):
        get_viewport().set_input_as_handled()
        elegir(&"piso", seleccion)
    elif es_volver(event):
        get_viewport().set_input_as_handled()
        elegir(&"volver")
