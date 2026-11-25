extends Node
## Se lanza al punto donde estabas; si te alcanza, te hiere. Luego vuelve a
## mirar con un respiro (el esquive con el que la evitaste no cuenta).


func actuar(v: Node, dt: float, _ctx: Dictionary) -> void:
    v.position = (v.position as Vector2).move_toward(v.objetivo, 560.0 * dt)
    if (v.position as Vector2).distance_to(v.jugador.position) < 34.0 and v.jugador_expuesto():
        v.alcanza.emit()
        v.estado_t = 0.0
    if float(v.estado_t) <= 0.0 or (v.position as Vector2).distance_to(v.objetivo) < 4.0:
        v.poner("mira")
        v.espalda_t = 0.0
        v.estado_t = 0.8
