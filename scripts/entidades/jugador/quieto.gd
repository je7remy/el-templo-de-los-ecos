extends Node
## Sin controles: frena en décimas de segundo, sin tirones.


func mover(j: Node, dt: float, _eje: Vector2, _paso: float) -> void:
    j.velocidad = (j.velocidad as Vector2).move_toward(Vector2.ZERO, j.FRENADA * dt)
