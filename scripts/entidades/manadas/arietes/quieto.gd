extends Node
## Ronda despacio por su sitio; si te alineas con él en horizontal o en
## vertical (y no está recuperándose), apunta.


func actuar(m: Node, r: Dictionary, dt: float, ctx: Dictionary) -> void:
    var pos: Vector2 = ctx["pos"]
    var d: Vector2 = m.jugador.position - pos
    var en_x: bool = absf(d.y) < m.ALINEADO and absf(d.x) < m.VISTA
    var en_y: bool = absf(d.x) < m.ALINEADO and absf(d.y) < m.VISTA
    if float(r["cd"]) <= 0.0 and (en_x or en_y):
        m.poner(r, "aim")
        r["t"] = m.APUNTA
        r["dir"] = Vector2(signf(d.x), 0) if en_x else Vector2(0, signf(d.y))
        m.apunta.emit(r)
        return
    r["t"] = float(r["t"]) - dt
    if float(r["t"]) <= 0.0:
        r["t"] = randf_range(1.2, 2.4)
        r["wander"] = Vector2(r["home"]) + Vector2(randf_range(-60, 60), randf_range(-40, 40))
    var sig: Vector2 = pos.move_toward(r["wander"], 30.0 * dt)
    if not m.bloqueado(sig):
        r["pos"] = sig
