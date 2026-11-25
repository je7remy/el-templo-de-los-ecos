extends Node
## Te acompaña. El traidor se queda a tu espalda; el sincero (o ya amigo)
## camina a tu lado. Mientras sigue, compite por las almas: el sincero solo
## toma las que le quedan más cerca a él; el traidor, codicioso, va a por la
## que más ventaja te saca (la que tú no estás a punto de coger).


func actuar(p: Node, dt: float, ctx: Dictionary) -> void:
    var yo: Vector2 = p.jugador.position
    var dirn: Vector2 = p.tu_direccion()
    var destino: Vector2 = yo - dirn * 46.0
    var amigo: bool = p.estado() == "friend"
    if not bool(p.traidor) or amigo:
        destino = yo + dirn * 18.0 + Vector2(-dirn.y, dirn.x) * 40.0
    if not amigo:
        var almas: Array = ctx["almas"]
        var recogidas: Array = ctx["recogidas"]
        var mejor: int = -1
        var ventaja: float = -INF
        for i in range(almas.size()):
            if recogidas[i]:
                continue
            var suya: float = (p.position as Vector2).distance_to(almas[i])
            var tuya: float = yo.distance_to(almas[i])
            var quiere: bool = suya < 150.0 and suya < tuya
            if bool(p.traidor):
                quiere = suya < 340.0 and tuya > 110.0
            if quiere and tuya - suya > ventaja:
                ventaja = tuya - suya
                mejor = i
        if mejor >= 0:
            destino = almas[mejor]
            if (p.position as Vector2).distance_to(almas[mejor]) < 22.0:
                p.toma_alma.emit(mejor)
    p.mover_a(destino, 140.0, dt)
