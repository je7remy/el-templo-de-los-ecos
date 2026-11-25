extends Node
## Zarpa en alto: aviso para apartarse o esquivar.


func actuar(e: Node, dt: float, ctx: Dictionary) -> void:
    e.teje_t = float(e.teje_t) - dt
    if float(e.teje_t) <= 0.0:
        e.poner_estado("tejedora", "zarpa")
        e.teje_t = 0.35
        e.zarpazo.emit(float(ctx["d"]) < e.TEJE_ALCANCE + 16.0)
