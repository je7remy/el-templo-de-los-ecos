extends Node
## Líneas de aviso: al acabarse el tiempo, los hilos cortan.


func actuar(h: Node, _dt: float, _ctx: Dictionary) -> void:
    if float(h.t) <= 0.0:
        h.poner("threads")
        h.t = 2.6
        h.hilos_activos.emit()
