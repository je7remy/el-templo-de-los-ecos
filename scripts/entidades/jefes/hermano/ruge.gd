extends Node
## Toma aire y ruge: alcanza a quien esté cerca (salvo esquivando). Después
## queda cansado.


func actuar(h: Node, _dt: float, ctx: Dictionary) -> void:
    if float(h.t) > 0.0:
        return
    h.rugido.emit((ctx["mira"] as Vector2).length() < h.RADIO_RUGIDO and float(h.jugador.esquiva_t) <= 0.0)
    h.poner("tired")
    h.t = 2.5
