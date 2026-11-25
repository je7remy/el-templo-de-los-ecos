extends Node
## Hilos tensos (línea roja visible): al acabarse el tiempo, dispara.


func actuar(e: Node, dt: float, _ctx: Dictionary) -> void:
    e.seg_t = float(e.seg_t) - dt
    if float(e.seg_t) <= 0.0:
        e.poner_estado("segador", "engancha")
        e.seg_t = e.SEG_ENGANCHA
        e.seg_destello = 0.18
        e.hilos_disparados.emit()
