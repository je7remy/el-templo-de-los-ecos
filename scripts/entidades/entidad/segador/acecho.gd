extends Node
## Ronda a distancia, rápido; cambia de sentido si choca. Cuando le toca y
## tiene línea limpia hacia ti, tensa sus hilos.


func actuar(e: Node, dt: float, ctx: Dictionary) -> void:
    var jugador: Vector2 = ctx["jugador"]
    var d: float = float(ctx["d"])
    var hacia: Vector2 = (jugador - e.position).normalized()
    if hacia == Vector2.ZERO:
        hacia = Vector2.LEFT
    var radial: float = clampf((d - e.SEG_DISTANCIA) / 60.0, -1.0, 1.0)
    var tangente := Vector2(-hacia.y, hacia.x) * float(e.seg_giro)
    var orbita: float = 0.9 if d < e.SEG_DISTANCIA + 120.0 else 0.25 # lejos, primero se acerca
    # Prueba la ruta ideal y, si choca, solo acercarse/alejarse o solo rodear.
    var movido: bool = false
    for v in [hacia * radial + tangente * orbita, hacia * signf(radial + 0.01), tangente, -tangente]:
        var quiere: Vector2 = e.position + (v as Vector2).normalized() * e.SEG_VELOCIDAD * dt
        if (v as Vector2).length() > 0.01 and not e.bloqueado(quiere):
            e.position = quiere
            movido = true
            break
    if not movido:
        e.seg_giro = -float(e.seg_giro)
    e.seg_cd = float(e.seg_cd) - dt
    if float(e.seg_cd) <= 0.0 and d < 430.0:
        var dir: Vector2 = (jugador - e.position).normalized()
        if dir == Vector2.ZERO:
            dir = Vector2.LEFT
        var fin: Vector2 = e.hilo_hasta(e.position, dir)
        if fin.distance_to(e.position) < d + 10.0:
            # Una columna te cubre: sigue rondando hasta tener línea limpia.
            e.seg_cd = 0.25
            return
        e.seg_t = e.SEG_TENSA
        e.seg_desde = e.position
        e.seg_hasta = fin
        var alcance: float = minf((e.seg_desde as Vector2).distance_to(jugador) + e.SEG_DE_MAS, (e.seg_desde as Vector2).distance_to(fin) - 26.0)
        e.seg_destino = (e.seg_desde as Vector2) + dir * maxf(0.0, alcance)
        e.poner_estado("segador", "tensa")
        e.hilos_tensos.emit()
