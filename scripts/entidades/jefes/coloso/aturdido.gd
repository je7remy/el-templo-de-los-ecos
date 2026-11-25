extends Node
## Le ha caído una columna encima: aturdido un momento.


func actuar(c: Node, _dt: float, _ctx: Dictionary) -> void:
    if float(c.t) <= 0.0:
        c.poner("walk")
        c.cd = 1.5
