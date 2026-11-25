extends Node
## Aturdido tras chocar: es el momento de romperlo. Luego vuelve a rondar.


func actuar(m: Node, r: Dictionary, dt: float, _ctx: Dictionary) -> void:
    r["t"] = float(r["t"]) - dt
    if float(r["t"]) <= 0.0:
        m.poner(r, "idle")
        r["cd"] = 1.2
