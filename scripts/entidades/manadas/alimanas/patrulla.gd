extends Node
## Va y viene por su trayecto; al llegar a un extremo, da media vuelta.


func actuar(m: Node, cr: Dictionary, dt: float, ctx: Dictionary) -> void:
    var destino: Vector2 = cr["b"] if bool(cr["to_b"]) else cr["a"]
    if Vector2(cr["pos"]).distance_to(destino) < 6.0:
        cr["to_b"] = not bool(cr["to_b"])
    m.avanzar(cr, destino, float(ctx["info"]["speed"]), dt, ctx)
