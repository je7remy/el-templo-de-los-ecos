extends Node
## Tras rugir, un respiro para golpearlo.


func actuar(h: Node, _dt: float, ctx: Dictionary) -> void:
    if float(h.t) <= 0.0:
        h.poner("walk")
        h.cd = 1.6 if bool(ctx["enfurecido"]) else 2.2
