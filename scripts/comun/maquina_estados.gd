extends Node
## Máquina de estados finitos genérica.
##
## Cada hijo directo es un estado. Un estado es cualquier nodo con estos
## métodos (todos opcionales):
##   entrar(datos: Dictionary)   se llama al pasar a ese estado
##   salir()                     se llama al dejarlo
##   actualizar(delta: float)    cada cuadro mientras está activo
##
## Solo un estado está activo a la vez. «cambiar_a("")» deja la máquina sin
## estado (todos inactivos). La usan las pantallas de la interfaz y la usarán
## el jugador y las entidades (fase 3 de docs/ARQUITECTURA.md).

signal estado_cambiado(anterior: StringName, nuevo: StringName)

## Estado con el que arranca (vacío = ninguno).
@export var estado_inicial: StringName = &""

var estado: Node = null


func _ready() -> void:
    for hijo in get_children():
        _desactivar(hijo)
    if estado_inicial != &"":
        cambiar_a(estado_inicial)


func nombre_actual() -> StringName:
    return estado.name if estado != null else &""


func tiene(nombre: StringName) -> bool:
    return nombre != &"" and has_node(NodePath(String(nombre)))


func cambiar_a(nombre: StringName, datos: Dictionary = {}) -> void:
    var siguiente: Node = get_node_or_null(NodePath(String(nombre))) if nombre != &"" else null
    var anterior: StringName = nombre_actual()
    if siguiente == estado:
        # Mismo estado: solo se refrescan sus datos.
        if estado != null and estado.has_method("entrar"):
            estado.call("entrar", datos)
        return
    if estado != null:
        if estado.has_method("salir"):
            estado.call("salir")
        _desactivar(estado)
    estado = siguiente
    if estado != null:
        _activar(estado)
        if estado.has_method("entrar"):
            estado.call("entrar", datos)
    estado_cambiado.emit(anterior, nombre_actual())


func _process(delta: float) -> void:
    if estado != null and estado.has_method("actualizar"):
        estado.call("actualizar", delta)


## Un estado inactivo no se ve, no procesa y no recibe entrada.
func _desactivar(n: Node) -> void:
    if n is CanvasItem:
        (n as CanvasItem).visible = false
    n.process_mode = Node.PROCESS_MODE_DISABLED


func _activar(n: Node) -> void:
    n.process_mode = Node.PROCESS_MODE_INHERIT
    if n is CanvasItem:
        (n as CanvasItem).visible = true
