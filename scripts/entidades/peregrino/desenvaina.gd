extends Node
## Te mira con el cuchillo fuera: al acabarse el aviso, ataca.


func actuar(p: Node, dt: float, _ctx: Dictionary) -> void:
    p.temporizador = float(p.temporizador) - dt
    p.mirar(p.jugador.position - p.position)
    p.moviendose = false
    if float(p.temporizador) <= 0.0:
        p.poner("hostile")
