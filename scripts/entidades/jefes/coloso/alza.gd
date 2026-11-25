extends Node
## Pie en alto (círculo rojo): al acabarse el aviso, pisa.


func actuar(c: Node, _dt: float, ctx: Dictionary) -> void:
    if float(c.t) <= 0.0:
        c.poner("stomp")
        c.t = 0.35
        c.pisoton.emit(float(ctx["d"]) < c.RADIO and c.jugador_expuesto())
