extends Node
## La mirada robada a la Vigía: si le das la espalda o corres, te hiere.


func actuar(h: Node, dt: float, ctx: Dictionary) -> void:
    h.tick = maxf(0.0, float(h.tick) - dt)
    if bool(ctx["huye"]) and float(h.tick) <= 0.0:
        h.tick = 0.5
        h.hiere.emit(h.MIRADA, 6.0, -1.0)
    if float(h.t) <= 0.0:
        h.poner("walk")
        h.cd = 1.8 if bool(ctx["enfurecido"]) else 2.4
