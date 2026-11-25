extends Node
## Se prepara (línea roja): al acabarse el tiempo, embiste.


func actuar(m: Node, r: Dictionary, dt: float, _ctx: Dictionary) -> void:
    r["t"] = float(r["t"]) - dt
    if float(r["t"]) <= 0.0:
        m.poner(r, "charge")
        r["t"] = 1.6
        m.embiste.emit(r)
