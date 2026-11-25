extends Node
## Va a por el peregrino que huye de pánico.


func actuar(v: Node, dt: float, _ctx: Dictionary) -> void:
    var presa: Dictionary = v.presa
    if presa.is_empty() or not bool(presa["alive"]):
        v.poner("mira")
        v.cortar = true
        return
    v.position = (v.position as Vector2).move_toward(presa["pos"], 520.0 * dt)
    if (v.position as Vector2).distance_to(presa["pos"]) < 30.0:
        v.presa_alcanzada.emit()
