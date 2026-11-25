extends Node
## Te ve con la antorcha encendida: guarda distancia, ronda y gruñe.


func actuar(m: Node, h: Dictionary, dt: float, ctx: Dictionary) -> void:
    var lejos: Vector2 = ctx["lejos"]
    var d: float = float(ctx["d"])
    if d < m.DISTANCIA:
        m.mover(h, lejos, 120.0, dt)
    else:
        m.mover(h, Vector2(-lejos.y, lejos.x), 45.0, dt)
    h["growl_t"] = float(h["growl_t"]) - dt
    if float(h["growl_t"]) <= 0.0 and d < 180.0:
        h["growl_t"] = randf_range(2.5, 4.5)
        m.grunido.emit(h)
