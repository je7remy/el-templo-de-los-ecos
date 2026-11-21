extends SceneTree
## Prueba rapida no interactiva del primer piso. No sustituye las pruebas jugables.

func _initialize() -> void:
    # Modo de prueba: archivos propios y limpios; tu partida y tus ajustes no se tocan.
    Engine.set_meta("modo_prueba", true)
    for f in ["user://prueba_progreso.json", "user://prueba_ajustes.cfg", "user://prueba_vigilia.json"]:
        if FileAccess.file_exists(f):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(f))
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
        game.call("_dialog_skip") # las conversaciones se leen con clic
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
    game.call("_dialog_skip") # las conversaciones se leen con clic
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
    game.call("_dialog_skip") # las conversaciones se leen con clic
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
    game.call("_dialog_skip") # las conversaciones se leen con clic
    game.set("player_pos", Vector2(game.get("door_pos")) + Vector2(-12, 0))
    game.call("_update_play", 1.0 / 60.0)
    if int(game.get("current_room")) != 1:
        _fail("Tocar la puerta abierta no lleva a la siguiente sala.")
        return
    game.set("current_room", 2)
    game.call("_enter_room")
    game.call("_dialog_skip") # las conversaciones se leen con clic
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
    game.call("_dialog_skip") # las conversaciones se leen con clic
    game.call("_finish_floor")
    if game.get("game_mode") != "floor_summary" or (game.get("summary") as Dictionary).get("floor", "") != "I":
        _fail("Superar el Piso I no muestra su resumen.")
        return
    game.call("_after_floor_summary")
    if int(game.get("current_floor")) != 1 or game.get("game_mode") != "floor_intro":
        _fail("Superar el Piso I no lleva a la entrada del Piso II.")
        return
    if not (game.get("ecos") as Array).has("respiracion"):
        _fail("Superar el Piso I no da el Eco de Respiración contenida.")
        return
    game.call("_enter_floor")
    game.call("_dialog_skip") # las conversaciones se leen con clic
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
    game.call("_dialog_skip") # las conversaciones se leen con clic
    game.set("pilgrim_traitor", true)
    game.set("pilgrim_state", "follow")
    var got: Array = game.get("collected")
    for k in range(got.size()):
        got[k] = true # el array tipado se modifica en su sitio
    game.call("_update_play", 1.0 / 60.0)
    if game.get("pilgrim_state") != "tell":
        _fail("El Peregrino traidor no reacciona en la Cosecha.")
        return
    if game.get("game_mode") != "dialog":
        _fail("La frase del Peregrino no se muestra en el cuadro de diálogo.")
        return
    game.call("_dialog_advance") # completa la frase
    game.call("_dialog_advance") # la cierra
    if game.get("game_mode") != "play":
        _fail("El diálogo no se cierra con clic.")
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

    # Piso III: la Cacería. Aliados, línea del Segador, enganche y huida.
    game.set("current_floor", 2)
    game.set("current_room", 0)
    game.call("_on_floor_start")
    game.call("_enter_room")
    game.call("_dialog_skip") # las conversaciones se leen con clic
    if int(game.call("_allies_alive")) != 3:
        _fail("Los tres aliados del Piso III no aparecen.")
        return
    game.set("current_room", 1)
    game.call("_enter_room")
    game.call("_dialog_skip") # las conversaciones se leen con clic
    if bool(game.call("_room_ready")):
        _fail("La puerta de la Cacería se abre con la presa viva.")
        return
    game.call("_damage_enemy", 10.0)
    if float(game.get("enemy_hp")) < float(game.get("enemy_max")):
        _fail("El Segador recibe daño mientras acecha.")
        return
    # Tensa los hilos hacia el jugador con un aliado justo detrás.
    game.set("enemy_pos", Vector2(600, 360))
    game.set("player_pos", Vector2(300, 360))
    var ally0: Dictionary = (game.get("allies") as Array)[0]
    ally0["pos"] = Vector2(250, 360)
    game.set("seg_cd", 0.0)
    game.set("damage_cd", 0.0)
    var hp_line: float = float(game.get("hp"))
    game.call("_update_segador", 1.0 / 60.0)
    if game.get("seg_state") != "tensa":
        _fail("El Segador no tensa sus hilos.")
        return
    for k in range(70):
        ally0["react"] = 9.0 # este aliado no reacciona a tiempo
        game.call("_update_segador", 1.0 / 60.0)
    if game.get("seg_state") != "engancha" or float(game.get("hp")) >= hp_line or bool(ally0["alive"]):
        _fail("El disparo del hilo no hiere a quien está en la línea.")
        return
    game.set("enemy_hp", float(game.get("enemy_max")) * 0.5 + 5.0)
    game.call("_damage_enemy", 10.0)
    if bool(game.call("_enemy_active")) or not bool(game.call("_room_ready")):
        _fail("A media vida el Segador no huye ni abre la puerta.")
        return
    game.set("current_room", 2)
    game.call("_enter_room")
    game.call("_dialog_skip") # las conversaciones se leen con clic
    if float(game.get("enemy_hp")) > float(game.get("enemy_max")) * 0.5:
        _fail("El Segador no conserva sus heridas en la sala siguiente.")
        return
    game.set("current_room", 3)
    game.call("_enter_room")
    game.call("_dialog_skip") # las conversaciones se leen con clic
    if int(game.get("souls")) <= 0:
        _fail("Sobrevivir con aliados no da recompensa.")
        return
    var eco_before: Array = (game.get("ecos") as Array).duplicate()
    (game.get("ecos") as Array).append("reflejos")
    if float(game.call("_dash_cooldown")) >= 2.65:
        _fail("El Eco Reflejos no acorta la recarga de esquivar.")
        return
    game.set("ecos", eco_before)
    print("OK: Piso III, Segador de Hilos, aliados y Reflejos.")

    # Etapa 1: esquivar quieto, regeneración, trampas, misión de sala y habilidades.
    (game.get("banished") as Dictionary).clear()
    (game.get("missions_done") as Dictionary).clear()
    game.set("current_floor", 0)
    game.set("current_room", 1)
    game.call("_enter_room")
    game.call("_dialog_skip")
    game.set("game_mode", "play")
    if bool(game.call("_room_ready")):
        _fail("La sala del Ghoul deja pasar sin cumplir su misión.")
        return
    var souls_m: int = int(game.get("souls"))
    game.call("_banish_enemy")
    if not bool(game.call("_room_ready")) or int(game.get("souls")) <= souls_m:
        _fail("Desterrar al Ghoul no cumple la misión ni da su premio.")
        return
    game.set("player_pos", Vector2(300, 470))
    game.set("player_dir", Vector2.RIGHT)
    game.set("dash_cd", 0.0)
    game.set("stamina", 100.0)
    game.set("mobile_axis", Vector2.ZERO)
    game.call("_start_dash")
    var x_before: float = Vector2(game.get("player_pos")).x
    game.call("_update_play", 0.1)
    if Vector2(game.get("player_pos")).x < x_before + 20.0:
        _fail("Esquivar sin moverse no desplaza al personaje.")
        return
    game.set("hp", 50.0)
    game.set("fear", 0.0)
    game.set("hp_prev", 50.0)
    game.set("regen_wait", 0.0)
    game.call("_update_regen", 1.0)
    if float(game.get("hp")) <= 50.0:
        _fail("La vida no se regenera.")
        return
    game.set("current_room", 4)
    game.call("_enter_room")
    game.call("_dialog_skip")
    var trap_list: Array = game.get("traps")
    if trap_list.is_empty():
        _fail("El Pórtico no tiene trampas.")
        return
    game.set("player_pos", trap_list[0]["pos"])
    game.set("room_elapsed", 2.5 - float(trap_list[0]["phase"]))
    game.set("damage_cd", 0.0)
    game.set("dash_left", 0.0)
    game.set("hp", 100.0)
    game.call("_update_traps", 0.016)
    if float(game.get("hp")) >= 100.0:
        _fail("Los pinchos levantados no hieren.")
        return
    game.set("hp", 100.0)
    game.set("damage_cd", 0.0)
    game.set("dash_left", 0.1)
    game.call("_update_traps", 0.016)
    if float(game.get("hp")) < 100.0:
        _fail("Esquivar no protege de los pinchos.")
        return
    game.set("dash_left", 0.0)
    game.set("game_mode", "play")
    game.call("_open_abilities")
    if game.get("game_mode") != "abilities" or (game.call("_ability_rows") as Array).size() < 5:
        _fail("La pantalla de habilidades no se abre.")
        return
    game.call("_close_abilities")
    print("OK: diálogos, misiones, esquivar quieto, regeneración, trampas y habilidades.")

    # Etapa 2: menú de pisos (solo se entra en pisos alcanzados) y capas de arte.
    game.set("max_floor", 1)
    game.set("game_mode", "title")
    game.call("_open_floors")
    if game.get("game_mode") != "floors":
        _fail("El menú de pisos no se abre.")
        return
    game.call("_choose_floor", 9)
    if game.get("game_mode") != "floors":
        _fail("Se puede entrar en un piso que aún no existe.")
        return
    # En la CI no hay partida guardada: sin nombre, elegir piso abre la creación.
    game.set("player_name", "")
    game.call("_choose_floor", 1)
    if game.get("game_mode") != "create" or str(game.get("create_then")) != "piso:1":
        _fail("Elegir piso sin personaje no abre la creación.")
        return
    game.set("create_buf", "PRUEBA")
    game.call("_create_finish")
    if game.get("game_mode") != "floor_intro" or int(game.get("current_floor")) != 1 or not bool(game.get("has_torch")):
        _fail("Elegir el Piso II no empieza allí con la antorcha.")
        return
    game.call("_enter_floor")
    game.call("_dialog_skip")
    game.call("_emit", Vector2(300, 300), 5, Color.WHITE, 10.0, 20.0, 0.5, 2.0)
    game.call("_update_fx", 0.1)
    if (game.get("fx_parts") as Array).is_empty() or String(game.call("_tc", "PISO II · LOS PEREGRINOS")) != "Piso II · Los Peregrinos":
        _fail("Las partículas o los rótulos góticos no funcionan.")
        return
    print("OK: menú de pisos, partículas y rótulos.")

    # Etapa 3 (del primer juego): alimañas, cuerpo de la vida anterior y sonidos con variantes.
    game.set("game_mode", "play")
    game.set("current_floor", 0)
    game.set("current_room", 4)
    game.call("_enter_room")
    game.call("_dialog_skip")
    var crs: Array = game.get("critters")
    if crs.size() != 2:
        _fail("El Pórtico no tiene sus alimañas.")
        return
    var souls_c: int = int(game.get("souls"))
    game.set("player_pos", crs[0]["pos"])
    game.set("dash_left", 0.1)
    game.call("_update_critters", 0.016)
    if bool(crs[0]["alive"]) or int(game.get("souls")) != souls_c + 1:
        _fail("Esquivar contra una alimaña no la aplasta ni da su alma.")
        return
    game.set("dash_left", 0.0)
    game.set("hp", 80.0)
    game.set("player_pos", Vector2(480, 300))
    game.call("_lose_run")
    var lc: Dictionary = game.get("life_corpse")
    if lc.is_empty() or str(lc["key"]) != "0:4":
        _fail("Al morir no queda tu cuerpo en la sala.")
        return
    game.call("_after_end")
    game.set("damage_cd", 0.0)
    game.set("player_pos", Vector2(480, 300))
    var souls_l: int = int(game.get("souls"))
    game.call("_update_life_corpse")
    if not bool((game.get("life_corpse") as Dictionary)["claimed"]) or int(game.get("souls")) <= souls_l:
        _fail("Tocar tu cuerpo anterior no devuelve almas.")
        return
    game.call("_dialog_skip")
    # En modo sin pantalla no se carga audio: se comprueba que existan las tomas.
    var groups: Dictionary = game.get("SFX_GROUPS")
    for group in groups:
        for file in groups[group]:
            if not ResourceLoader.exists("res://audio/kenney/%s.ogg" % file):
                _fail("Falta el sonido %s." % file)
                return
    print("OK: alimañas, cuerpo de la vida anterior y sonidos con variantes.")

    # Saltar diálogos con el botón y volver a la pausa desde el perfil y las habilidades.
    game.set("game_mode", "play")
    game.call("_dialog", [["PEREGRINO", "Una frase."], ["PEREGRINO", "Otra frase."]])
    game.call("_mobile_tap", (game.get("SKIP_BTN") as Rect2).get_center())
    if game.get("game_mode") != "play" or not (game.get("dialog_queue") as Array).is_empty():
        _fail("El botón SALTAR no salta la conversación.")
        return
    game.call("_open_pause")
    game.call("_open_inventory")
    game.call("_open_abilities")
    game.call("_close_abilities")
    if game.get("game_mode") != "pause":
        _fail("Cerrar las habilidades abiertas desde la pausa no vuelve a la pausa.")
        return
    game.call("_open_inventory")
    game.call("_close_inventory")
    if game.get("game_mode") != "pause":
        _fail("Cerrar el perfil abierto desde la pausa no vuelve a la pausa.")
        return
    game.set("game_mode", "play")
    game.call("_open_inventory")
    game.call("_close_inventory")
    if game.get("game_mode") != "play":
        _fail("Cerrar el perfil abierto jugando no vuelve al juego.")
        return
    print("OK: saltar diálogos y volver a la pausa.")
    game.set("current_floor", 0)

    game.set("current_room", 2)
    game.call("_enter_room")
    game.call("_dialog_skip") # las conversaciones se leen con clic
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

    # Muerte: con MUERTE_SIN_PERDIDA se reaparece en la misma sala con todo;
    # sin ella, retorno o absorción al 50 %.
    var souls_at_death: int = int(game.get("souls"))
    var floor_at_death: int = int(game.get("current_floor"))
    var room_at_death: int = int(game.get("current_room"))
    game.call("_lose_run")
    if game.get("game_mode") != "dead":
        _fail("La derrota no cambia el estado de juego.")
        return
    if bool(game.get("MUERTE_SIN_PERDIDA")):
        if game.get("soul_fate") != "persistencia":
            _fail("La muerte sin pérdida no se registra.")
            return
        game.call("_after_end")
        if game.get("game_mode") != "play" or int(game.get("souls")) != souls_at_death \
                or int(game.get("current_floor")) != floor_at_death or int(game.get("current_room")) != room_at_death \
                or not bool((game.get("collected") as Array)[1]) or float(game.get("hp")) < float(game.get("max_hp")):
            _fail("Al reaparecer se perdió progreso (almas, sala o almas recogidas).")
            return
        print("OK: la muerte no cuesta progreso (modo de pruebas).")
    elif not (game.get("soul_fate") in ["retorno", "absorcion"]):
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
