extends Node
## Aviso rojo: al acabarse, se lanza hacia donde estás.


func actuar(v: Node, _dt: float, _ctx: Dictionary) -> void:
    if float(v.estado_t) <= 0.0:
        v.poner("golpe")
        v.estado_t = 0.8
        v.objetivo = v.jugador.position
        v.ataca.emit()
