extends Node
## Carga en línea recta; si choca contra algo, queda aturdido.


func actuar(m: Node, r: Dictionary, dt: float, ctx: Dictionary) -> void:
    var pos: Vector2 = ctx["pos"]
    r["t"] = float(r["t"]) - dt
    var sig: Vector2 = pos + Vector2(r["dir"]) * m.VELOCIDAD * dt
    if m.bloqueado(sig) or float(r["t"]) <= 0.0:
        m.poner(r, "stun")
        r["t"] = m.ATURDIDO
        m.choca.emit(r, pos)
        return
    r["pos"] = sig
    if sig.distance_to(m.jugador.position) < 30.0:
        m.alcanza.emit(r)
