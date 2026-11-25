extends Node
## Base de los estados de la partida de la Vigilia (máquina «Fases» de
## scenes/defense.tscn): portada, partida, fase superada y derrota.
##
## La Vigilia (scripts/defense.gd, «v») recibe la entrada y se la pasa al
## estado activo; cada estado decide qué hace y qué pantalla se ve. Lo común a
## todos (ESC para salir, el botón de salir, mover el cursor con el stick) lo
## sigue haciendo la Vigilia.

## Una tecla recién pulsada (ESC ya lo trató la Vigilia).
func tecla(_v: Node, _k: Key) -> void:
    pass


## Botones del mando con un uso propio en este estado (Y, X, RB, START). Por
## defecto START hace lo mismo que ENTER.
func boton(v: Node, b: int) -> void:
    if b == JOY_BUTTON_START:
        v.call("_key", KEY_ENTER)


## Un toque o clic en «at» (coordenadas de la celda; el botón de salir ya lo
## trató la Vigilia).
func tocar(_v: Node, _at: Vector2) -> void:
    pass


## Cada cuadro, en el momento en que la Vigilia avanza la partida.
func avanzar(_v: Node, _dt: float) -> void:
    pass


## Pantalla que se ve encima de la celda: [nombre, datos] (nombre vacío =
## ninguna).
func pantalla(_v: Node) -> Array:
    return [&"", {}]
