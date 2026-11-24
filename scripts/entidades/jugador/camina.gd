extends Node
## Andar con inercia corta: arranca en una décima y mira hacia donde va.


func mover(j: Node, dt: float, eje: Vector2, paso: float) -> void:
    j.velocidad = (j.velocidad as Vector2).move_toward(eje * paso, j.ACELERACION * dt)
    j.direccion = eje
