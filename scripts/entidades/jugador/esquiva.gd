extends Node
## Esquive: sale disparado y se frena solo; su impulso enlaza con el paso
## normal (curva de velocidad, no un salto de 157 a 480).


func mover(j: Node, _dt: float, _eje: Vector2, _paso: float) -> void:
    var p: float = 1.0 - float(j.esquiva_t) / float(j.ESQUIVA_TIEMPO)
    j.velocidad = (j.esquiva_dir as Vector2) * lerpf(j.ESQUIVA_PICO, j.ESQUIVA_FIN, p * p)
    j.direccion = j.esquiva_dir
