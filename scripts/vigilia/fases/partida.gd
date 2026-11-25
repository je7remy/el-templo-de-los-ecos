extends "res://scripts/vigilia/fases/fase_vigilia.gd"
## Partida: dormir, construir y mejorar con toques, teclado o mando, el
## tutorial guiado y la pausa. Las reglas (qué cuesta cada cosa, cómo atacan
## las entidades) siguen en la Vigilia: este estado decide qué hacer con cada
## entrada.

const Vigilia := preload("res://scripts/defense.gd")


func tecla(v: Node, k: Key) -> void:
    var paso: int = int(v.get("tut_step"))
    var menu: Dictionary = v.get("popup")
    if paso >= 0 and k == KEY_ENTER and paso in [0, Vigilia.TUT_STEPS.size() - 1] and menu.is_empty():
        v.call("_tut_tap", Vigilia.TUT_CARD.get_center())
        return
    if paso >= 0 and k == KEY_BACKSPACE:
        v.call("_end_tutorial")
        return
    if k == KEY_P:
        v.call("_action", 8)
    elif k in [KEY_LEFT, KEY_A]:
        v.call("_move_cursor", Vector2i(-1, 0))
    elif k in [KEY_RIGHT, KEY_D]:
        v.call("_move_cursor", Vector2i(1, 0))
    elif k in [KEY_UP, KEY_W]:
        v.call("_move_cursor", Vector2i(0, -1))
    elif k in [KEY_DOWN, KEY_S]:
        v.call("_move_cursor", Vector2i(0, 1))
    elif k in [KEY_ENTER, KEY_E]:
        if menu.is_empty():
            v.call("_open_popup_for", v.get("cursor"))
        else:
            v.call("_popup_choose", v.get("popup_sel"))
    elif k == KEY_SPACE:
        v.call("_action", 0)
    elif k >= KEY_1 and k <= KEY_8:
        if not menu.is_empty() and int(k) - int(KEY_1) < (menu["options"] as Array).size():
            v.call("_popup_choose", int(k) - int(KEY_1))
        else:
            v.call("_action", int(k) - int(KEY_1))


## Y dormir, X escudo, RB potenciar, START pausa.
func boton(v: Node, b: int) -> void:
    match b:
        JOY_BUTTON_Y:
            v.call("_action", 0)
        JOY_BUTTON_X:
            v.call("_action", 7)
        JOY_BUTTON_RIGHT_SHOULDER:
            v.call("_action", 6)
        JOY_BUTTON_START:
            v.call("_action", 8)


func tocar(v: Node, at: Vector2) -> void:
    if Vigilia.PAUSE_RECT.has_point(at):
        v.call("_action", 8)
        return
    if bool(v.get("paused")):
        return
    if int(v.get("tut_step")) >= 0 and v.call("_tut_tap", at):
        return
    var menu: Dictionary = v.get("popup")
    if not menu.is_empty():
        for i in range((menu["options"] as Array).size()):
            if (v.call("_popup_option_rect", i) as Rect2).has_point(at):
                v.set("popup_sel", i)
                v.call("_popup_choose", i)
                return
        if (v.call("_popup_rect") as Rect2).has_point(at):
            return
        v.set("popup", {})
    if at.y >= 512.0:
        var i: int = clampi(int((at.x - 6.0) / 238.0), 0, 3)
        v.call("_action", [0, 4, 6, 7][i])
        return
    if Vigilia.DOOR.grow(18.0).has_point(at):
        v.call("_open_door_popup")
        return
    var t: Vector2i = v.call("_tile_at", at)
    if t.x >= 0:
        v.call("_open_popup_for", t)


## El menú abierto se rehace (precios al día) y, sin pausa, avanza la fase.
func avanzar(v: Node, dt: float) -> void:
    v.call("_refresh_popup")
    if not bool(v.get("paused")):
        v.call("_advance", dt)


func pantalla(v: Node) -> Array:
    return [&"Pausa" if bool(v.get("paused")) else &"", {}]
