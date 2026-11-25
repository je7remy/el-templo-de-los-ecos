extends Node
## Avanza hacia ti (cada columna que le cae lo hace más rápido); cerca y
## descansado, alza el pie.


func actuar(c: Node, dt: float, ctx: Dictionary) -> void:
    var hacia: Vector2 = (c.position as Vector2).move_toward(c.jugador.position, c.VELOCIDAD * (1.0 + 0.25 * float(c.golpes)) * dt)
    c.position = Vector2(clampf(hacia.x, 110.0, 850.0), clampf(hacia.y, 220.0, 540.0))
    if float(ctx["d"]) < c.RADIO and float(c.cd) <= 0.0:
        c.poner("raise")
        c.t = c.ALZA - 0.12 * float(c.golpes) # cada vez pisa antes
        c.alza.emit()
