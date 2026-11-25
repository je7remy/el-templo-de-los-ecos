extends Node
## El golpe y un instante para recuperarse.


func actuar(e: Node, dt: float, _ctx: Dictionary) -> void:
    e.teje_t = float(e.teje_t) - dt
    if float(e.teje_t) <= 0.0:
        e.poner_estado("tejedora", "anda")
