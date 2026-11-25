extends "res://scripts/vigilia/fases/fase_vigilia.gd"
## Fase superada: se ve el botín ganado; tocar o ENTER sigue con la siguiente.

const Botin := preload("res://scripts/botin.gd")


func tecla(v: Node, k: Key) -> void:
    if k in [KEY_ENTER, KEY_SPACE]:
        v.call("_next_stage")


func tocar(v: Node, at: Vector2) -> void:
    if at.y > 300.0:
        v.call("_next_stage")


func pantalla(v: Node) -> Array:
    var botin: Array = (v.get("rewards") as Array).map(func(k): return Botin.OBJETOS.get(k, [k, "", 1, "alma"]))
    return [&"FaseSuperada", {"t": v.get("tick"), "fase": v.get("stage"), "botin": botin}]
