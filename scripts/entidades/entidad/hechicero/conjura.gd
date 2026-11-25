extends Node
## Responde a tu luz: cuando tiene el conjuro cargado, lo lanza hacia ti.


func actuar(e: Node, _dt: float, ctx: Dictionary) -> void:
    if float(e.conjuro_cd) > 0.0:
        return
    var hacia: Vector2 = ((ctx["jugador"] as Vector2) - e.position).normalized()
    e.conjuro_cd = e.RECARGA_CONJURO
    e.conjuro.emit(e.position + Vector2(0.0, -20.0), hacia)
