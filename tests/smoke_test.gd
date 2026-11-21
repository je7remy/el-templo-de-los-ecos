extends SceneTree
## Prueba rapida no interactiva del primer piso. No sustituye las pruebas jugables.

func _initialize() -> void:
    call_deferred("_run_checks")

func _run_checks() -> void:
    var packed: PackedScene = load("res://scenes/main.tscn")
    if packed == null:
        _fail("No se puede cargar la escena principal.")
        return
    var game: Node = packed.instantiate()
    root.add_child(game)
    # _ready() se ejecuta al añadir la escena al arbol, no requiere espera.

    # Una prueba de jugabilidad sin verificar sprites podia pasar con escenas invisibles.
    var loaded_art = game.get("art")
    if not (loaded_art is Dictionary):
        _fail("El diccionario de texturas no se inicializo.")
        return
    var required_textures := ["room_0","room_1","room_2","room_3","room_4","player","knowledge_door","knowledge_altar","knowledge_book","knowledge_torch","angel_1","angel_8","ghoul_1","ghoul_8","wizard_1","wizard_5","fireball_1"]
    for texture_name in required_textures:
        if not loaded_art.has(texture_name):
            _fail("Falta el sprite %s." % texture_name)
            return
        var texture = loaded_art[texture_name]
        if not (texture is Texture2D) or texture.get_width() <= 0 or texture.get_height() <= 0:
            _fail("No se pudo importar o cargar %s." % texture_name)
            return
    print("OK: texturas de Knowledge Temple y enemigos GothicVania cargadas.")

    # Arranque: pantalla de inicio → acuerdo (primera vez) → menú.
    if game.get("game_mode") != "splash":
        _fail("El juego no arranca en la pantalla de inicio.")
        return
    game.call("_splash_continue")
    if game.get("game_mode") == "eula":
        game.call("_accept_eula")
    if game.get("game_mode") != "title":
        _fail("Tras la pantalla de inicio no aparece el menú.")
        return
    # Configuración: se abre desde el menú y vuelve a él.
    game.call("_open_settings", "title")
    game.call("_settings_key", KEY_ESCAPE)
    if game.get("game_mode") != "title":
        _fail("Configuración no vuelve al menú.")
        return
    # Tutorial: muñeco, pasos y salida al Piso I.
    game.call("_start_tutorial")
    if not bool(game.get("in_tutorial")) or game.get("game_mode") != "play":
        _fail("El tutorial no empieza.")
        return
    game.set("tutorial_step", 4)
    game.set("has_torch", true)
    game.set("torch_on", true)
    game.set("stamina", 100.0)
    game.set("player_pos", Vector2(game.get("DUMMY_POS")) + Vector2(-40, 0))
    game.set("player_dir", Vector2.RIGHT)
    game.call("_torch_strike")
    if int(game.get("dummy_hits")) != 1:
        _fail("El golpe no alcanza al muñeco del tutorial.")
        return
    # Pausa desde el juego y vuelta.
    game.call("_open_pause")
    if game.get("game_mode") != "pause":
        _fail("No se puede pausar el juego.")
        return
    game.call("_pause_key", KEY_ESCAPE)
    if game.get("game_mode") != "play" or not bool(game.get("tut_paused")):
        _fail("La pausa no vuelve al juego.")
        return
    game.call("_end_tutorial")
    if bool(game.get("in_tutorial")) or int(game.get("current_floor")) != 0:
        _fail("Al terminar el tutorial no se entra en el Piso I.")
        return
    print("OK: inicio, acuerdo, configuración, tutorial y pausa.")
    game.set("game_mode", "title")
    game.call("_new_run")
    if game.get("game_mode") != "play":
        _fail("No se pudo iniciar una partida.")
        return

    for index in range(5):
        game.set("current_room", index)
        game.call("_enter_room")
        if int(game.get("current_room")) != index:
            _fail("Fallo al acceder a la sala %d." % (index + 1))
            return

    # Inventario: se empieza a oscuras y la antorcha se construye en la sala 1.
    game.call("_new_run")
    if bool(game.get("torch_on")) or bool(game.get("has_torch")):
        _fail("La partida debe empezar sin luz.")
        return
    for item in (game.get("room_items") as Array).duplicate():
        game.set("player_pos", item["pos"])
        game.call("_update_play", 1.0 / 60.0)
    if not bool(game.get("has_torch")) or int(game.get("matches")) != 5:
        _fail("Madera + fósforos no construyen la antorcha con 5 fósforos.")
        return
    game.call("_toggle_torch")
    if not bool(game.get("torch_on")) or int(game.get("matches")) != 4:
        _fail("Encender la antorcha debe gastar un fósforo.")
        return
    game.call("_toggle_torch")
    if bool(game.get("torch_on")) or int(game.get("matches")) != 4:
        _fail("Apagar la antorcha no debe gastar fósforos.")
        return
    game.call("_toggle_torch")
    # Combate: el golpe de antorcha daña al Ghoul y a 0 de vida se destierra.
    game.set("current_room", 1)
    game.call("_enter_room")
    var foe: Vector2 = game.get("enemy_pos")
    game.set("player_pos", foe + Vector2(-40, 0))
    game.set("player_dir", Vector2.RIGHT)
    game.call("_torch_strike")
    if float(game.get("enemy_hp")) >= float(game.get("enemy_max")):
        _fail("El golpe de antorcha no daña a la entidad.")
        return
    game.set("enemy_hp", 1.0)
    game.set("strike_cd", 0.0)
    game.set("stamina", 100.0)
    game.call("_torch_strike")
    if bool(game.call("_enemy_active")) or (game.get("drops") as Array).size() != 1:
        _fail("La entidad no se destierra ni suelta almas a 0 de vida.")
        return
    # Debilidad: el Testigo es inmune con el ojo abierto.
    game.set("current_room", 2)
    game.call("_enter_room")
    game.set("watcher_open", true)
    if bool(game.call("_damage_enemy", 10.0)):
        _fail("El Testigo no debe recibir daño con el ojo abierto.")
        return
    game.set("watcher_open", false)
    if not bool(game.call("_damage_enemy", 10.0)):
        _fail("El Testigo debe recibir daño con el ojo cerrado.")
        return
    print("OK: antorcha, fósforos, golpe, debilidades y destierro.")

    # La puerta se cruza al tocarla, sin pulsar E; sellada, no deja pasar.
    game.set("current_room", 0)
    game.call("_enter_room")
    game.set("player_pos", Vector2(game.get("door_pos")) + Vector2(-12, 0))
    game.call("_update_play", 1.0 / 60.0)
    if int(game.get("current_room")) != 1:
        _fail("Tocar la puerta abierta no lleva a la siguiente sala.")
        return
    game.set("current_room", 2)
    game.call("_enter_room")
    game.set("seal_acquired", false)
    game.set("player_pos", Vector2(game.get("door_pos")) + Vector2(-12, 0))
    game.call("_update_play", 1.0 / 60.0)
    if int(game.get("current_room")) != 2:
        _fail("La puerta sellada no debe dejar pasar.")
        return
    print("OK: puerta por contacto.")

    # Pisos: la última puerta del Piso I da un Eco y lleva al Piso II.
    game.set("current_floor", 0)
    game.set("current_room", 4)
    game.call("_enter_room")
    game.call("_finish_floor")
    if int(game.get("current_floor")) != 1 or game.get("game_mode") != "floor_intro":
        _fail("Superar el Piso I no lleva a la entrada del Piso II.")
        return
    if not (game.get("ecos") as Array).has("respiracion"):
        _fail("Superar el Piso I no da el Eco de Respiración contenida.")
        return
    game.call("_enter_floor")
    if game.get("pilgrim_state") != "follow":
        _fail("El Peregrino no aparece al entrar en el Piso II.")
        return
    # La puerta exige reunir las almas de la sala.
    game.set("player_pos", Vector2(game.get("door_pos")) + Vector2(-12, 0))
    game.call("_update_play", 1.0 / 60.0)
    if int(game.get("current_room")) != 0:
        _fail("La puerta del Piso II deja pasar sin reunir las almas.")
        return
    # La Cosecha: un Peregrino traidor desenvaina al reunir la última alma.
    game.set("current_room", 2)
    game.call("_enter_room")
    game.set("pilgrim_traitor", true)
    game.set("pilgrim_state", "follow")
    var got: Array = game.get("collected")
    for k in range(got.size()):
        got[k] = true # el array tipado se modifica en su sitio
    game.call("_update_play", 1.0 / 60.0)
    if game.get("pilgrim_state") != "tell":
        _fail("El Peregrino traidor no reacciona en la Cosecha.")
        return
    game.call("_update_play", 1.0)
    if game.get("pilgrim_state") != "hostile":
        _fail("El Peregrino no pasa al ataque tras el aviso.")
        return
    game.set("pilgrim_hp", 1.0)
    game.call("_damage_pilgrim", 10.0)
    if game.get("pilgrim_state") != "dead" or (game.get("drops") as Array).is_empty():
        _fail("El Peregrino no cae ni suelta sus almas.")
        return
    print("OK: pisos, Eco, Peregrino y Cosecha.")
    game.set("current_floor", 0)

    game.set("current_room", 2)
    game.call("_enter_room")
    game.set("player_pos", game.get("seal_pos"))
    game.call("_interact")
    if not bool(game.get("seal_acquired")):
        _fail("No fue posible recoger el sello de la mision.")
        return

    # Las almas se recogen al tocarlas, sin pulsar E.
    var souls_before: int = int(game.get("souls"))
    var relic_spot: Vector2 = (game.get("relics") as Array)[1]
    game.set("player_pos", relic_spot + Vector2(0, 6))
    game.call("_update_play", 1.0 / 60.0)
    if not bool((game.get("collected") as Array)[1]) or int(game.get("souls")) != souls_before + 7:
        _fail("Las almas no se recogen por contacto.")
        return

    game.call("_lose_run")
    if game.get("game_mode") != "dead":
        _fail("La derrota no cambia el estado de juego.")
        return
    if not (game.get("soul_fate") in ["retorno", "absorcion"]):
        _fail("Resultado de muerte invalido.")
        return
    print("OK: almas recogidas por contacto.")
    # La CI busca esta línea exacta: no cambiar su texto.
    print("OK: carga, inicio, 5 salas, sello y desenlace de muerte.")
    # Liberar la escena y sus recursos antes de cerrar la prueba headless.
    # Sin esto, Godot puede informar recursos retenidos al finalizar el proceso.
    game.free()
    game = null
    packed = null
    # Permite liberar recursos del stack de esta funcion antes de cerrar.
    call_deferred("quit", 0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
