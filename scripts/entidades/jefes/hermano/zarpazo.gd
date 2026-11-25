extends Node
## Golpe corto a quien tenga pegado.


func actuar(h: Node, _dt: float, ctx: Dictionary) -> void:
    if float(h.t) > 0.0:
        return
    if (ctx["mira"] as Vector2).length() < 80.0 and h.jugador_expuesto():
        h.hiere.emit(h.ZARPAZO, 0.0, 0.8)
    h.poner("walk")
    h.cd = maxf(float(h.cd), 1.0)
