extends Node
## Avanza hacia ti despacio; si choca, rodea por el lado que más la acerca.
## A tu alcance, alza la zarpa.


func actuar(e: Node, dt: float, ctx: Dictionary) -> void:
    var jugador: Vector2 = ctx["jugador"]
    var hacia: Vector2 = (jugador - e.position).normalized()
    var dir: Vector2 = hacia
    if float(e.teje_rodeo_t) > 0.0:
        e.teje_rodeo_t = float(e.teje_rodeo_t) - dt
        dir = e.teje_rodeo # rodea la columna un momento
    var sig: Vector2 = e.position + dir * e.TEJE_VELOCIDAD * dt
    if not e.bloqueado(sig):
        e.position = sig
    else:
        var perp := Vector2(-hacia.y, hacia.x)
        var opciones: Array = [perp, -perp, -hacia] if perp.dot(jugador - e.position) >= 0.0 else [-perp, perp, -hacia]
        for c in opciones:
            var prueba: Vector2 = e.position + (c as Vector2) * e.TEJE_VELOCIDAD * dt
            if not e.bloqueado(prueba):
                e.position = prueba
                e.teje_rodeo = c
                e.teje_rodeo_t = 0.7
                break
    if float(ctx["d"]) < e.TEJE_ALCANCE:
        e.poner_estado("tejedora", "alza")
        e.teje_t = e.TEJE_ALZA
        e.zarpa_alzada.emit()
