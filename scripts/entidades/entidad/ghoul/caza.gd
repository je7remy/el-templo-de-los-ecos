extends Node
## Ve tu antorcha: va a por ti.


func actuar(e: Node, dt: float, ctx: Dictionary) -> void:
    e.ir_a((e.position as Vector2).move_toward(ctx["jugador"], float(e.VELOCIDAD["ghoul"]) * dt))
