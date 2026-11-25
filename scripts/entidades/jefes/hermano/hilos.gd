extends Node
## Los hilos cortan a quien los toque (salvo esquivando).


func actuar(h: Node, _dt: float, ctx: Dictionary) -> void:
    if h.jugador_expuesto():
        for hilo in h.hilos:
            var p: Vector2 = h.jugador.position
            if p.distance_to(Geometry2D.get_closest_point_to_segment(p, hilo[0], hilo[1])) < 12.0:
                h.hiere.emit(h.HILO, 8.0, 0.9)
                break
    if float(h.t) <= 0.0:
        h.hilos.clear()
        h.poner("walk")
        h.cd = 1.8 if bool(ctx["enfurecido"]) else 2.4
