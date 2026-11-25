extends Node
## Lejos de ti: deambula cerca de su sitio.


func actuar(m: Node, h: Dictionary, dt: float, ctx: Dictionary) -> void:
    h["wander_t"] = float(h["wander_t"]) - dt
    if float(h["wander_t"]) <= 0.0:
        h["wander_t"] = randf_range(1.5, 3.0)
        h["wander"] = Vector2(h["home"]) + Vector2(randf_range(-70, 70), randf_range(-50, 50))
    var pos: Vector2 = ctx["pos"]
    if pos.distance_to(h["wander"]) > 6.0:
        m.mover(h, Vector2(h["wander"]) - pos, m.VELOCIDAD, dt)
