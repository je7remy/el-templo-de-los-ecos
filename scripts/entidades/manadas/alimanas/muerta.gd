extends Node
## Aplastada. Si hay nido, vuelve a salir al rato (lejos de ti).


func actuar(m: Node, cr: Dictionary, dt: float, _ctx: Dictionary) -> void:
    cr["dead_t"] = float(cr["dead_t"]) + dt
    if bool(cr["respawn"]) and float(cr["dead_t"]) > m.REAPARECE and m.jugador.position.distance_to(cr["a"]) > 160.0:
        cr["alive"] = true # el nido repone la alimaña
        cr["dead_t"] = 0.0
        cr["pos"] = cr["a"]
        cr["to_b"] = true
