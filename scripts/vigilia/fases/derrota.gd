extends "res://scripts/vigilia/fases/fase_vigilia.gd"
## La puerta ha cedido: tocar (abajo) o ENTER empieza otra vigilia.



func tecla(v: Node, k: Key) -> void:
    if k == KEY_ENTER:
        v.call("_start", v.get("chamber"))


func tocar(v: Node, at: Vector2) -> void:
    if at.y > 350.0:
        v.call("_start", v.get("chamber"))


func pantalla(v: Node) -> Array:
    return [&"PuertaCedida", {"fase": v.get("stage"), "entidades": v.get("slain"), "puntos": v.get("session_score")}]
