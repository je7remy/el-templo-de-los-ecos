extends Node
## El pisotón; luego vuelve a andar (descansa menos con cada columna).


func actuar(c: Node, _dt: float, _ctx: Dictionary) -> void:
    if float(c.t) <= 0.0:
        c.poner("walk")
        c.cd = maxf(1.0, 2.2 - 0.4 * float(c.golpes))
