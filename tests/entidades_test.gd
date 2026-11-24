extends SceneTree
## Arquitectura por escenas (fase 3): el jugador y las entidades como escenas
## con su máquina de estados. Fase 3a: el jugador (Quieto, Camina, Esquiva).


func _initialize() -> void:
    Engine.set_meta("modo_prueba", true)
    for f in ["user://prueba_progreso.json", "user://prueba_ajustes.cfg", "user://prueba_vigilia.json"]:
        if FileAccess.file_exists(f):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(f))
    call_deferred("_run")


func _run() -> void:
    root.size = Vector2i(960, 640)
    var ajustes: Object = load("res://scripts/ajustes.gd")
    ajustes.call("poner", "intro_vista", true)
    ajustes.call("poner", "tutorial_hecho", true)
    ajustes.call("poner", "acuerdo_aceptado", true)
    var game: Node = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    await process_frame
    game.call("_new_run")
    game.call("_dialog_skip")
    game.set("game_mode", "play")
    game.set_process(false) # los cuadros los da la prueba, con paso fijo

    # --- Fase 3a: el jugador ------------------------------------------------------
    var jugador: Node2D = game.get_node_or_null("Jugador")
    if jugador == null or jugador.get_node_or_null("Maquina") == null:
        _fail("Falta la escena del jugador con su máquina de estados.")
        return
    for estado in ["Quieto", "Camina", "Esquiva"]:
        if not bool(jugador.get_node("Maquina").call("tiene", StringName(estado))):
            _fail("La máquina del jugador no tiene el estado %s." % estado)
            return
    if (game.get("player_pos") as Vector2) != jugador.position:
        _fail("player_pos de la campaña no es la posición del jugador.")
        return
    var cambios: Array = []
    jugador.get_node("Maquina").estado_cambiado.connect(func(_a, b): cambios.append(String(b)))
    var dt := 1.0 / 60.0
    # Quieto → Camina: avanza a la derecha y mira hacia allí.
    var x0: float = jugador.position.x
    game.set("mobile_axis", Vector2.RIGHT)
    for i in range(20):
        game.call("_update_play", dt)
    if String(jugador.call("estado")) != "Camina" or jugador.position.x <= x0 + 20.0 or jugador.get("direccion") != Vector2.RIGHT:
        _fail("El jugador no pasa a Camina o no avanza (%s)." % jugador.call("estado"))
        return
    # Camina → Esquiva: sale disparado, deja siluetas y gasta vigor.
    game.set("stamina", 100.0)
    game.set("dash_cd", 0.0)
    game.call("_start_dash")
    var antes: float = jugador.position.x
    game.call("_update_play", dt)
    if String(jugador.call("estado")) != "Esquiva" or float(game.get("stamina")) >= 100.0:
        _fail("Esquivar no pasa a Esquiva o no gasta vigor.")
        return
    if jugador.position.x - antes < 5.0:
        _fail("El esquive no sale disparado.")
        return
    for i in range(4):
        game.call("_update_play", dt)
    if (game.get("dash_ghosts") as Array).is_empty():
        _fail("El esquive no deja siluetas.")
        return
    # Esquiva → Camina al acabar; sin controles, Quieto y frena en décimas.
    for i in range(20):
        game.call("_update_play", dt)
    if String(jugador.call("estado")) != "Camina":
        _fail("Al acabar el esquive no vuelve a Camina.")
        return
    game.set("mobile_axis", Vector2.ZERO)
    for i in range(12):
        game.call("_update_play", dt)
    if String(jugador.call("estado")) != "Quieto" or bool(game.get("player_moving")):
        _fail("Sin controles el jugador no se queda Quieto.")
        return
    if cambios.slice(0, 4) != ["Camina", "Esquiva", "Camina", "Quieto"]:
        _fail("Orden de estados inesperado: %s." % [cambios])
        return
    # Los pasos suenan por la señal del jugador.
    var pasos := [0]
    jugador.paso.connect(func(_en, _esq): pasos[0] += 1)
    game.set("mobile_axis", Vector2.DOWN)
    for i in range(60):
        game.call("_update_play", dt)
        game.set("hp", 100.0)
    if pasos[0] < 2:
        _fail("Al andar no se oyen pasos (señal «paso»).")
        return
    # Los muros frenan: contra el borde izquierdo de la sala no se sale.
    game.set("mobile_axis", Vector2.LEFT)
    for i in range(400):
        game.call("_update_play", dt)
        game.set("hp", 100.0)
    if jugador.position.x < float((game.get("ARENA") as Rect2).position.x):
        _fail("El jugador atraviesa el muro izquierdo.")
        return
    print("OK: jugador como escena con máquina de estados (quieto, camina, esquiva).")
    game.queue_free()
    await process_frame
    call_deferred("quit", 0)


func _fail(reason: String) -> void:
    push_error(reason)
    quit(1)
