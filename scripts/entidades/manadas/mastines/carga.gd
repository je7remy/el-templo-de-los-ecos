extends Node
## A oscuras: carga y muerde; después se aparta un instante (Huye).


func actuar(m: Node, h: Dictionary, dt: float, ctx: Dictionary) -> void:
    m.mover(h, -(ctx["lejos"] as Vector2), m.CARGA, dt)
    if float(ctx["d"]) < 26.0 and float(h["bite_cd"]) <= 0.0:
        h["bite_cd"] = 1.2
        h["bite_t"] = 0.25
        h["flee"] = 0.5 # muerde y se aparta un instante
        m.mordisco.emit(h)
