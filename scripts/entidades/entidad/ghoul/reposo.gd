extends Node
## Sin luz que cazar, el Ghoul vuelve despacio a su sitio.


func actuar(e: Node, dt: float, _ctx: Dictionary) -> void:
    e.ir_a((e.position as Vector2).move_toward(e.hogar, e.VUELTA_GHOUL * dt))
