extends "res://scripts/vigilia/fases/fase_vigilia.gd"
## Portada: empezar (o continuar la vigilia guardada), empezar de cero y el
## tutorial.

const Portada := preload("res://scripts/vigilia/pantallas/portada.gd")


func tecla(v: Node, k: Key) -> void:
    if k in [KEY_ENTER, KEY_SPACE]:
        v.call("_choose_start")
    elif k == KEY_N and v.call("_has_saved_run"):
        v.call("_new_vigil")
    elif k == KEY_T:
        v.call("_start_tutorial")


func boton(v: Node, b: int) -> void:
    if b == JOY_BUTTON_Y:
        v.call("_start_tutorial")
    else:
        super(v, b)


func tocar(v: Node, at: Vector2) -> void:
    var boton_2: Rect2 = Portada.BOTON_TUTORIAL.grow(6.0)
    if boton_2.has_point(at) and v.call("_has_saved_run"):
        v.call("_new_vigil")
    elif boton_2.has_point(at):
        if bool(v.get("tutorial_done")):
            v.call("_start_tutorial")
        else:
            v.set("tutorial_done", true) # «saltar tutorial»
            v.call("_save_records")
            v.call("_start")
    elif at.y > 270.0 and at.y < 515.0:
        v.call("_choose_start")


func pantalla(v: Node) -> Array:
    var guardada: Dictionary = v.get("saved_run")
    return [&"Portada", {"t": v.get("tick"), "guardada": v.call("_has_saved_run"), "fase_guardada": int(guardada.get("stage", 1)),
        "tutorial_hecho": v.get("tutorial_done"), "mejor_fase": v.get("best_stage"), "mejor_puntuacion": v.get("high_score")}]
