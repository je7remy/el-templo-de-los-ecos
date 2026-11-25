extends CanvasLayer
## Pantallas de la Vigilia (portada, fase superada, puerta cedida y pausa):
## una escena cada una en scripts/vigilia/pantallas/, estados de «Maquina»
## (scripts/comun/maquina_estados.gd). La Vigilia (scripts/defense.gd) dice
## cuál se ve y con qué datos; durante la partida no se ve ninguna.

@onready var maquina: Node = $Maquina


## Muestra «nombre» (vacío = ninguna) con sus datos; si ya se ve, los refresca.
func mostrar(nombre: StringName, datos: Dictionary = {}) -> void:
    if nombre != &"" and maquina.nombre_actual() == nombre:
        maquina.estado.call("refrescar", datos)
    else:
        maquina.cambiar_a(nombre, datos)


func activa() -> StringName:
    return maquina.nombre_actual()


func pantalla(nombre: StringName) -> Node:
    return maquina.get_node_or_null(NodePath(String(nombre)))


## La celda va centrada en pantallas anchas: las pantallas, con ella.
func ajustar_margen(m: Vector2) -> void:
    offset = m
