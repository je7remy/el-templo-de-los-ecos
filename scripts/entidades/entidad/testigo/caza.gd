extends Node
## Te ha visto moverte con el ojo abierto (o quedarte quieto, invertido): va a
## por ti y la campaña recuerda la regla.


func actuar(e: Node, dt: float, ctx: Dictionary) -> void:
    e.ir_a((e.position as Vector2).move_toward(ctx["jugador"], float(e.VELOCIDAD["testigo"]) * dt))
    e.regla.emit(bool(ctx["invertido"]))
