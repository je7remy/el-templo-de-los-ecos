extends Node
## Huele la sangre: se lanza hacia ti, más rápido.


func actuar(m: Node, cr: Dictionary, dt: float, ctx: Dictionary) -> void:
    m.avanzar(cr, m.jugador.position, float(ctx["info"]["chase"]), dt, ctx)
