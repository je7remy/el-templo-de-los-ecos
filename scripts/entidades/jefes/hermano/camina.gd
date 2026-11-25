extends Node
## Se acerca (más rápido enfurecido). Pegado a ti, prepara un zarpazo; cuando
## le toca, usa su siguiente regla.


func actuar(h: Node, dt: float, ctx: Dictionary) -> void:
    var mira: Vector2 = ctx["mira"]
    var enfurecido: bool = bool(ctx["enfurecido"])
    if mira.length() > 70.0:
        var sig: Vector2 = h.position + mira.normalized() * h.VELOCIDAD * (1.3 if enfurecido else 1.0) * dt
        if not h.bloqueado(sig):
            h.position = Vector2(clampf(sig.x, 110.0, 850.0), clampf(sig.y, 200.0, 540.0))
    elif float(h.cd) <= 0.6:
        h.poner("swipe")
        h.t = 0.55
    if float(h.cd) <= 0.0:
        h.siguiente_regla(enfurecido)
