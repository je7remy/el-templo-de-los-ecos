extends Node
## Atraviesa la línea en un instante y queda clavado a sus hilos: es el
## momento de golpearlo. Al soltarse vuelve a rondar.


func actuar(e: Node, dt: float, _ctx: Dictionary) -> void:
    e.position = (e.position as Vector2).move_toward(e.seg_destino, 1600.0 * dt)
    e.seg_t = float(e.seg_t) - dt
    if float(e.seg_t) <= 0.0:
        e.poner_estado("segador", "acecho")
        e.seg_cd = randf_range(1.3, 2.2)
        e.seg_giro = -1.0 if randf() < 0.5 else 1.0
