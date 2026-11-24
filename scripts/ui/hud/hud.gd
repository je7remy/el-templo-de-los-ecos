extends CanvasLayer
## HUD de la partida (capa 1: encima de la sala, debajo de las pantallas).
##
## Se compone de piezas (scripts/ui/hud/), cada una un nodo hijo de «Piezas»
## que se dibuja sola con sus datos: franjas, panel del jugador, cartel del
## piso, minimapa, misión, arma, rótulo de misión, almas de la sala, fundido,
## tutorial y controles táctiles. El orden de los nodos es el orden de dibujo.
##
## La campaña llama a actualizar(datos) cada cuadro con un diccionario
## {nombre de la pieza: sus datos}; una pieza sin datos no se ve.

@onready var piezas: Control = $Piezas


func actualizar(datos: Dictionary) -> void:
    for pieza in piezas.get_children():
        pieza.call("poner", datos.get(String(pieza.name), {}))


## Oculta todo (menús, intro, creación del personaje).
func ocultar() -> void:
    for pieza in piezas.get_children():
        pieza.call("poner", {})


func pieza(nombre: StringName) -> Control:
    return piezas.get_node_or_null(NodePath(nombre)) as Control
