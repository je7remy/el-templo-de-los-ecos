extends Node
## Te persigue; pegado a ti, se detiene, alza el cuchillo y tira el tajo.


func actuar(p: Node, dt: float, _ctx: Dictionary) -> void:
    var yo: Vector2 = p.jugador.position
    if float(p.aturdido) > 0.0:
        p.moviendose = false
    elif float(p.temporizador) > 0.0:
        # Carga del tajo: se detiene y alza el cuchillo (aviso justo).
        p.temporizador = float(p.temporizador) - dt
        p.moviendose = false
        p.mirar(yo - p.position)
        if float(p.temporizador) <= 0.0:
            p.estocada = 0.22
            p.cd = 1.2
            p.tajo.emit((p.position as Vector2).distance_to(yo) < 46.0 and float(p.jugador.invulnerable_t) <= 0.0)
    else:
        p.mover_a(yo, 172.0, dt)
        if (p.position as Vector2).distance_to(yo) < 38.0 and float(p.cd) <= 0.0:
            p.temporizador = 0.42
            p.prepara_tajo.emit()
