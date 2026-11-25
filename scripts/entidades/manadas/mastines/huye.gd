extends Node
## Se aparta de ti hasta que se le pasa el miedo.


func actuar(m: Node, h: Dictionary, dt: float, ctx: Dictionary) -> void:
    h["flee"] = float(h["flee"]) - dt
    m.mover(h, ctx["lejos"], 150.0, dt)
