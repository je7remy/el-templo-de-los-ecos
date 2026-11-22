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

    # Piso IV: enredaderas que arden, raíces de la puerta y la Tejedora de Raíz.
    game.set("current_floor", 3)
    game.set("current_room", 0)
    game.call("_on_floor_start")
    game.call("_enter_room")
    game.call("_dialog_skip")
    game.set("game_mode", "play")
    if (game.get("vines") as Dictionary).is_empty() or int(game.call("_door_roots_left")) <= 0 or bool(game.call("_room_ready")):
        _fail("El Atrio de las Raíces no tiene enredaderas o la puerta no está tapada.")
        return
    game.set("has_inner_flame", false)
    game.set("matches", 3)
    game.call("_try_ignite", Vector2(200, 470))
    if int(game.get("matches")) != 2:
        _fail("Prender una enredadera seca no gasta un fósforo.")
        return
    game.set("player_pos", Vector2(150, 250))
    for k in range(60 * 25):
        game.call("_update_fire", 1.0 / 60.0)
    if int(game.call("_door_roots_left")) != 0:
        _fail("El fuego no llega a las raíces de la puerta.")
        return
    game.set("current_room", 1)
    game.call("_enter_room")
    game.call("_dialog_skip")
    game.set("game_mode", "play")
    var hp_t: float = float(game.get("enemy_hp"))
    game.call("_damage_enemy", 18.0)
    if hp_t - float(game.get("enemy_hp")) > 5.0:
        _fail("La Tejedora recibe el golpe entero: su corteza debería resistir.")
        return
    var cells: Dictionary = game.get("vines")
    var first: Vector2i = cells.keys()[0]
    game.call("_ignite", first)
    game.set("enemy_pos", game.call("_cell_center", first))
    game.set("player_pos", Vector2(480, 200))
    var hp_before: float = float(game.get("enemy_hp"))
    for k in range(30):
        game.call("_update_tejedora", 1.0 / 30.0)
    if float(game.get("enemy_hp")) > hp_before - 20.0:
        _fail("El fuego no quema a la Tejedora.")
        return
    (game.get("ecos") as Array).append("piel")
    game.set("hp", 100.0)
    game.set("hp_prev", 100.0)
    game.set("hp", 80.0)
    game.call("_update_regen", 0.0)
    if absf(float(game.get("hp")) - 85.0) > 0.01:
        _fail("Piel curtida no reduce el daño.")
        return
    (game.get("ecos") as Array).erase("piel")
    print("OK: Piso IV, fuego, raíces y Tejedora de Raíz.")

    # Piso V: mastines que temen al fuego, antorcha que se consume, rescate y Máscara.
    game.set("current_floor", 4)
    game.set("current_room", 0)
    game.call("_on_floor_start")
    game.set("has_torch", true)
    game.set("has_inner_flame", false)
    game.set("matches", 3)
    game.set("torch_on", false)
    game.call("_enter_room")
    game.call("_dialog_skip")
    game.set("game_mode", "play")
    var hs: Array = game.get("hounds")
    if hs.size() != 2 or (game.get("maze_walls") as Array).is_empty():
        _fail("El Corredor de los Relicarios no tiene mastines o muros.")
        return
    game.set("player_pos", Vector2(480, 300))
    hs[0]["pos"] = Vector2(480, 230)
    hs[1]["pos"] = Vector2(720, 200)
    game.call("_toggle_torch")
    var d0: float = Vector2(hs[0]["pos"]).distance_to(Vector2(480, 300))
    for k in range(60):
        game.call("_update_hounds", 1.0 / 60.0)
    if Vector2(hs[0]["pos"]).distance_to(Vector2(480, 300)) < d0:
        _fail("Con la antorcha encendida el mastín se acerca.")
        return
    game.set("torch_fuel", 0.01)
    game.call("_update_labyrinth", 0.05)
    if bool(game.get("torch_on")):
        _fail("La antorcha no se consume en el Piso V.")
        return
    game.set("hp", 100.0)
    game.set("damage_cd", 0.0)
    game.set("dash_left", 0.0)
    hs[0]["flee"] = 0.0
    hs[0]["bite_cd"] = 0.0
    hs[0]["pos"] = Vector2(480, 285)
    for k in range(30):
        game.call("_update_hounds", 1.0 / 60.0)
    if float(game.get("hp")) >= 100.0:
        _fail("A oscuras el mastín no muerde.")
        return
    game.set("current_room", 1)
    game.call("_enter_room")
    game.call("_dialog_skip")
    game.set("game_mode", "play")
    game.set("torch_on", true)
    game.set("stamina", 100.0)
    game.set("strike_cd", 0.0)
    game.set("player_pos", Vector2(660, 470))
    game.set("player_dir", Vector2.RIGHT)
    game.call("_torch_strike")
    game.call("_dialog_skip")
    if game.get("rescue_state") != "libre" or not (game.get("rescued") as Array).has("SAÚL"):
        _fail("Golpear la reja no libera al peregrino atrapado.")
        return
    game.set("current_room", 3)
    game.call("_enter_room")
    game.call("_dialog_skip")
    game.set("game_mode", "play")
    game.set("has_mask", false)
    if bool(game.call("_room_ready")):
        _fail("Los Canales de Almas abren la puerta sin la Máscara.")
        return
    game.set("player_pos", (game.call("_room") as Dictionary)["mask"])
    game.call("_update_labyrinth", 0.016)
    game.call("_dialog_skip")
    if not bool(game.get("has_mask")) or float(game.call("_pulse_radius")) <= 150.0 or not bool(game.call("_room_ready")):
        _fail("La Máscara de Porcelana no se recoge o no amplía la Resonancia.")
        return
    # Volver al piso con la máscara ya puesta: reaparece y abre la puerta.
    (game.get("missions_done") as Dictionary).erase(game.call("_room_key"))
    game.set("player_pos", Vector2(480, 470))
    game.call("_update_labyrinth", 0.016)
    if bool(game.call("_room_ready")) or not bool(game.call("_mask_on_pedestal")):
        _fail("Al volver al Piso V la máscara no reaparece.")
        return
    game.set("player_pos", (game.call("_room") as Dictionary)["mask"])
    game.call("_update_labyrinth", 0.016)
    game.call("_dialog_skip")
    if not bool(game.call("_room_ready")):
        _fail("Con la máscara ya conseguida antes, la puerta de los Canales queda cerrada.")
        return
    game.set("has_mask", false)
    print("OK: Piso V, mastines, antorcha que se consume, rescate y Máscara.")
    game.set("current_floor", 0)

    # Mando (Xbox 360 y similares): los botones hacen lo mismo que las teclas.
    game.set("current_room", 0)
    game.call("_enter_room")
    game.call("_dialog_skip")
    game.set("game_mode", "play")
    game.set("has_torch", true)
    game.set("torch_on", false)
    game.set("matches", 3)
    _pad(game, JOY_BUTTON_X)
    if not bool(game.get("torch_on")) or game.call("_key_label", "antorcha") != "X":
        _fail("El botón X del mando no enciende la antorcha.")
        return
    _pad(game, JOY_BUTTON_START)
    _pad(game, JOY_BUTTON_DPAD_DOWN)
    if game.get("game_mode") != "pause" or int(game.get("pause_sel")) != 1:
        _fail("START no pausa o la cruceta no mueve el menú de pausa.")
        return
    _pad(game, JOY_BUTTON_B)
    _pad(game, JOY_BUTTON_LEFT_SHOULDER)
    if game.get("game_mode") != "inventory":
        _fail("B no cierra la pausa o LB no abre el perfil.")
        return
    _pad(game, JOY_BUTTON_B)
    _pad(game, JOY_BUTTON_RIGHT_SHOULDER)
    if game.get("game_mode") != "abilities":
        _fail("RB no abre las habilidades.")
        return
    _pad(game, JOY_BUTTON_B)
    game.set("stamina", 100.0)
    _pad_axis(game, JOY_AXIS_TRIGGER_LEFT, 1.0)
    _pad_axis(game, JOY_AXIS_TRIGGER_LEFT, 0.0)
    if game.get("game_mode") != "play" or float(game.get("dash_left")) <= 0.0:
        _fail("LT no esquiva.")
        return
    game.call("_start_creation", "title")
    game.set("create_buf", "")
    _pad(game, JOY_BUTTON_Y)
    var pad_name: String = str(game.get("create_buf"))
    _pad(game, JOY_BUTTON_X)
    _pad(game, JOY_BUTTON_DPAD_RIGHT)
    _pad(game, JOY_BUTTON_A)
    if pad_name == "" or str(game.get("create_buf")).length() != pad_name.length() or not str(game.get("create_buf")).ends_with("B"):
        _fail("El teclado en pantalla no responde al mando.")
        return
    _pad(game, JOY_BUTTON_START)
    var gender_before: int = int(game.get("create_gender"))
    _pad(game, JOY_BUTTON_DPAD_RIGHT)
    if int(game.get("create_step")) != 1 or int(game.get("create_gender")) == gender_before:
        _fail("START no pasa al género o la cruceta no lo cambia.")
        return
    _pad(game, JOY_BUTTON_B)
    _pad(game, JOY_BUTTON_BACK)
    _pad(game, JOY_BUTTON_BACK)
    if game.get("game_mode") != "settings":
        _fail("SELECT no abre la configuración desde el menú.")
        return
    _pad_axis(game, JOY_AXIS_LEFT_Y, 1.0)
    _pad_axis(game, JOY_AXIS_LEFT_Y, 0.0)
    if int(game.get("settings_sel")) != 1:
        _fail("El stick no recorre los menús.")
        return
    _pad(game, JOY_BUTTON_B)
    game.set("pad_active", false)
    game.set("torch_on", false)
    game.set("game_mode", "play")
    print("OK: mando de Xbox y similares en el juego y los menús.")

    # Piso VI: grupo que pide guía, Mercader (se paga primero, no se toca el manto) y Huesos firmes.
    game.set("current_floor", 5)
    game.set("current_room", 0)
    game.call("_on_floor_start")
    game.call("_enter_room")
    game.call("_dialog_skip")
    game.set("game_mode", "play")
    var group: Array = game.get("allies")
    if group.size() != 4 or not bool(group[0]["waiting"]):
        _fail("El grupo del Piso VI no espera (con Saúl, rescatado en el Piso V).")
        return
    game.set("player_pos", Vector2(group[0]["pos"]) + Vector2(40, 0))
    game.call("_interact")
    game.call("_dialog_skip")
    if not bool(game.get("guiding")) or bool(group[0]["waiting"]):
        _fail("Hablar con el grupo no lo convierte en tus guiados.")
        return
    game.set("current_room", 1)
    game.call("_enter_room")
    game.call("_dialog_skip")
    game.set("game_mode", "play")
    var teo_maimed := false
    for a in group:
        if str(a["name"]) == "TEO":
            teo_maimed = bool(a["maimed"])
    if not teo_maimed:
        _fail("Teo no paga la regla del manto al entrar con el grupo.")
        return
    if int(game.get("karma")) < 2:
        _fail("Liberar a Saúl y guiar al grupo no dan la bendición.")
        return
    game.set("karma", 0) # precios sin marca para comprobar las cuentas
    game.set("souls", 30)
    var merchant: Vector2 = (game.call("_room") as Dictionary)["merchant"]
    game.set("player_pos", merchant + Vector2(0, 44))
    game.call("_interact")
    if game.get("game_mode") != "shop":
        _fail("El cuenco no abre el puesto del Mercader.")
        return
    game.call("_shop_key", KEY_DOWN)
    game.call("_shop_key", KEY_DOWN)
    game.call("_shop_key", KEY_ENTER)
    if not (game.get("trinkets") as Array).has("brazalete") or int(game.get("souls")) != 18 \
            or float(game.call("_strike_damage")) <= 18.0:
        _fail("El Brazalete de bronce no se compra o no se cobra primero.")
        return
    # Comprarlo otra vez lo mejora: nivel 2 por el doble de almas.
    var dmg_b1: float = float(game.call("_strike_damage"))
    game.set("souls", 24)
    if not bool(game.call("_shop_buy", 2)) or int(game.call("_trinket_level", "brazalete")) != 2 \
            or int(game.get("souls")) != 0 or float(game.call("_strike_damage")) <= dmg_b1:
        _fail("El Brazalete no sube de nivel al comprarlo otra vez.")
        return
    game.call("_shop_key", KEY_ESCAPE)
    var mh0: float = float(game.get("max_hp"))
    game.set("player_pos", game.call("_merchant_hem"))
    game.call("_interact")
    game.call("_dialog_skip")
    game.set("game_mode", "play")
    if not bool(game.get("hand_lost")) or float(game.get("max_hp")) != mh0 - 25.0:
        _fail("Meter la mano bajo el manto no cuesta vida máxima.")
        return
    (game.get("bag") as Dictionary).clear()
    game.set("souls", 6)
    game.call("_shop_buy", 0)
    if int((game.get("bag") as Dictionary).get("pan", 0)) != 1:
        _fail("El pan del Mercader no va a la bolsa.")
        return
    game.set("hp", float(game.get("max_hp")) - 5.0)
    game.call("_use_bag_item", "pan")
    if float(game.get("max_hp")) != mh0 - 15.0 or float(game.get("hp")) <= float(game.get("max_hp")):
        _fail("El pan no devuelve vida máxima o no deja vida extra por encima del máximo.")
        return
    (game.get("ecos") as Array).append("huesos")
    game.set("hp", -5.0)
    game.call("_update_play", 0.016)
    if float(game.get("hp")) <= 0.0 or not bool(game.get("bones_used")) or game.get("game_mode") == "dead":
        _fail("Huesos firmes no aguanta el golpe mortal.")
        return
    game.set("current_room", 3)
    game.call("_enter_room")
    game.call("_dialog_skip")
    if (game.get("guided") as Array).size() != 4:
        _fail("Los guiados no quedan guardados al llegar a la escalera.")
        return
    (game.get("ecos") as Array).erase("huesos")
    (game.get("trinkets") as Array).clear()
    (game.get("guided") as Array).clear()
    game.set("hand_lost", false)
    game.set("max_hp", game.call("_base_max_hp"))
    game.set("hp", game.get("max_hp"))
    game.call("_on_floor_start")
    game.set("current_floor", 0)
    game.set("game_mode", "play")
    print("OK: Piso VI, guiar al grupo, Mercader, regla del manto y Huesos firmes.")

    # Niveles: la experiencia sube de nivel y mejora las estadísticas.
    game.set("player_level", 1)
    game.set("xp", 0)
    game.set("max_hp", game.call("_base_max_hp"))
    game.set("hp", 10.0)
    var dmg1: float = float(game.call("_strike_damage"))
    var hp1: float = float(game.get("max_hp"))
    game.call("_gain_xp", int(game.call("_xp_needed", 1)) + 5)
    if int(game.get("player_level")) != 2 or int(game.get("xp")) != 5 or float(game.get("max_hp")) <= hp1 \
            or float(game.call("_strike_damage")) <= dmg1 or float(game.get("hp")) != float(game.get("max_hp")):
        _fail("Subir de nivel no mejora vida, daño o no cura.")
        return
    print("OK: niveles, experiencia y estadísticas.")

    # Piso VII: la mirada. Darle la espalda la provoca; aguantarla abre la puerta.
    game.set("guided", ["IRENE", "BAS"])
    game.set("current_floor", 6)
    game.set("current_room", 0)
    game.call("_on_floor_start")
    game.call("_enter_room")
    game.call("_dialog_skip")
    if (game.get("allies") as Array).size() != 2 or not bool(game.get("guiding")):
        _fail("Los peregrinos guiados en el Piso VI no bajan contigo al VII.")
        return
    game.set("current_room", 1)
    game.call("_enter_room")
    game.call("_dialog_skip")
    game.set("game_mode", "play")
    if not bool(game.get("gaze_active")) or bool(game.call("_room_ready")):
        _fail("La Sala de la Mirada no tiene a la Vigía o abre sin aguantar su mirada.")
        return
    game.set("player_pos", Vector2(480, 470))
    game.set("dash_left", 0.0)
    game.set("player_dir", (Vector2(game.get("gaze_pos")) - Vector2(480, 470)).normalized())
    for k in range(50):
        game.set("player_dir", (Vector2(game.get("gaze_pos")) - Vector2(480, 470)).normalized())
        game.call("_update_gaze", 0.1)
    if float(game.get("gaze_t")) < 4.0 or game.get("gaze_state") != "mira":
        _fail("Mirarla no cuenta tiempo o la provoca sin motivo.")
        return
    for k in range(10):
        game.set("player_dir", -(Vector2(game.get("gaze_pos")) - Vector2(480, 470)).normalized())
        game.call("_update_gaze", 0.1)
    if not (game.get("gaze_state") in ["aviso", "golpe"]):
        _fail("Darle la espalda no la provoca.")
        return
    game.set("gaze_state", "mira")
    game.set("gaze_away_t", 0.0)
    game.set("gaze_t", float(game.get("gaze_need")) * 0.5)
    game.set("gaze_panic_done", false)
    game.set("player_dir", (Vector2(game.get("gaze_pos")) - Vector2(480, 470)).normalized())
    game.call("_update_gaze", 0.01)
    var panicked: Dictionary = {}
    for a in game.get("allies"):
        if float(a["panic"]) > 0.0:
            panicked = a
    if panicked.is_empty():
        _fail("Ningún peregrino entra en pánico durante la mirada.")
        return
    game.set("player_pos", Vector2(panicked["pos"]) + Vector2(30, 0))
    game.call("_interact")
    if float(panicked["panic"]) > 0.0:
        _fail("No se puede calmar al peregrino en pánico.")
        return
    game.set("gaze_t", float(game.get("gaze_need")) - 0.01)
    game.set("player_pos", Vector2(480, 470))
    game.set("player_dir", (Vector2(game.get("gaze_pos")) - Vector2(480, 470)).normalized())
    game.call("_update_gaze", 0.1)
    if game.get("gaze_state") != "vencida" or not bool(game.call("_room_ready")):
        _fail("Aguantar su mirada no abre la puerta.")
        return
    game.set("current_room", 3)
    game.call("_enter_room")
    game.call("_dialog_skip")
    if (game.get("guided") as Array).size() != 2:
        _fail("Los supervivientes del Piso VII no quedan guardados.")
        return
    (game.get("ecos") as Array).append("serena")
    game.set("game_mode", "play")
    game.set("fear", 100.0)
    game.set("hp", 50.0)
    game.call("_update_play", 0.1)
    (game.get("ecos") as Array).erase("serena")
    if float(game.get("hp")) < 50.0:
        _fail("Con Mente serena el miedo al máximo sigue haciendo daño.")
        return
    (game.get("guided") as Array).clear()
    game.call("_on_floor_start")
    game.set("current_floor", 0)
    game.set("game_mode", "play")
    print("OK: Piso VII, la mirada, provocar, calmar a los guiados y Mente serena.")

    # Piso VIII: las salas del Piso I cambiadas.
    game.set("current_floor", 7)
    game.set("current_room", 0)
    game.call("_on_floor_start")
    game.call("_enter_room")
    game.call("_dialog_skip")
    var flipped := false
    for prop in game.get("room_props"):
        if bool(prop["flip"]):
            flipped = true
    if not flipped:
        _fail("En el Piso VIII las estatuas no miran al otro lado.")
        return
    game.set("current_room", 1)
    game.call("_enter_room")
    game.call("_dialog_skip")
    game.set("game_mode", "play")
    game.set("watcher_open", true)
    game.set("enemy_stun", 0.0)
    game.set("player_pos", Vector2(300, 470))
    game.set("player_moving", false)
    game.call("_update_enemy", 0.05)
    var chases_still: bool = bool(game.get("enemy_alert"))
    game.set("player_moving", true)
    game.call("_update_enemy", 0.05)
    if not chases_still or bool(game.get("enemy_alert")):
        _fail("El Testigo del Piso VIII no invierte su regla.")
        return
    game.set("current_room", 2)
    game.call("_enter_room")
    game.call("_dialog_skip")
    game.set("game_mode", "play")
    game.set("seal_acquired", false)
    if bool(game.call("_room_ready")):
        _fail("El Archivo del Piso VIII abre sin el sello.")
        return
    game.set("player_pos", game.get("seal_pos"))
    game.call("_interact")
    if not bool(game.get("seal_acquired")) or not bool(game.call("_room_ready")):
        _fail("El sello del Piso VIII no está en el Archivo o no abre la puerta.")
        return
    game.set("seal_acquired", false)
    (game.get("ecos") as Array).append("memoria")
    game.set("player_pos", Vector2(400, 470))
    game.call("_mark_death")
    if (game.call("_room_death_marks") as Array).is_empty():
        _fail("Memoria de eco no recuerda dónde moriste.")
        return
    (game.get("ecos") as Array).erase("memoria")
    (game.get("death_marks") as Dictionary).clear()
    game.call("_on_floor_start")
    game.set("current_floor", 0)
    game.set("game_mode", "play")
    print("OK: Piso VIII, salas cambiadas, Testigo invertido, sello movido y Memoria de eco.")

    # Más abajo, más fuertes: el Ghoul del Piso VIII tiene más vida que el del Piso I.
    game.set("current_floor", 7)
    game.set("current_room", 2)
    game.call("_enter_room")
    game.call("_dialog_skip")
    var deep_hp: float = float(game.get("enemy_max"))
    game.set("current_floor", 0)
    game.set("current_room", 1)
    game.call("_enter_room")
    game.call("_dialog_skip")
    if deep_hp <= float(game.get("enemy_max")):
        _fail("Las entidades no son más fuertes en los pisos profundos.")
        return
    # Piso IX: Arietes de Piedra y el Coloso.
    game.set("current_floor", 8)
    game.set("current_room", 0)
    game.call("_on_floor_start")
    game.call("_enter_room")
    game.call("_dialog_skip")
    game.set("game_mode", "play")
    game.set("has_torch", true)
    game.set("torch_on", true)
    var rs: Array = game.get("rams")
    if rs.size() != 2:
        _fail("La Nave de los Arietes no tiene sus dos Arietes.")
        return
    game.set("player_pos", Vector2(rs[0]["pos"]) + Vector2(-200, 0))
    rs[0]["cd"] = 0.0
    game.call("_update_rams", 0.016)
    if str(rs[0]["state"]) != "aim":
        _fail("El Ariete no se prepara al alinearte con él.")
        return
    rs[0]["state"] = "stun"
    rs[0]["t"] = 2.0
    rs[0]["hp"] = 1.0
    game.set("player_pos", Vector2(rs[0]["pos"]) + Vector2(-40, 0))
    game.set("player_dir", Vector2.RIGHT)
    game.set("strike_cd", 0.0)
    game.set("stamina", 100.0)
    game.call("_torch_strike")
    if (game.get("rams") as Array).size() != 1:
        _fail("El Ariete aturdido no se rompe con el golpe.")
        return
    game.set("current_room", 2)
    game.call("_enter_room")
    game.call("_dialog_skip")
    game.set("game_mode", "play")
    game.set("torch_on", true)
    if not bool(game.get("colossus_active")) or bool(game.call("_room_ready")):
        _fail("El Pórtico del Coloso no tiene al Coloso o abre sin derribarlo.")
        return
    var cols: Array = game.get("pillars")
    game.set("colossus_pos", Vector2(480, 470))
    game.set("player_pos", Vector2(cols[0]["pos"]) + Vector2(30, 0))
    game.set("player_dir", Vector2.LEFT)
    game.set("strike_cd", 0.0)
    game.call("_torch_strike")
    if bool(cols[0]["fallen"]):
        _fail("La columna cae aunque el Coloso esté lejos.")
        return
    for k in range(3):
        game.set("colossus_pos", Vector2(cols[k]["pos"]) + Vector2(60, 0))
        game.set("player_pos", Vector2(cols[k]["pos"]) + Vector2(-30, 0))
        game.set("player_dir", Vector2.RIGHT)
        game.set("strike_cd", 0.0)
        game.set("stamina", 100.0)
        game.call("_torch_strike")
    if bool(game.get("colossus_active")) or not bool(game.call("_room_ready")):
        _fail("Tres columnas no derriban al Coloso o la puerta no se abre.")
        return
    var base_dmg: float = float(game.call("_strike_damage"))
    game.set("ecos", ["fuerza", "piel", "paso"])
    if float(game.call("_strike_damage")) <= base_dmg:
        _fail("Fuerza acumulada no aumenta el golpe.")
        return
    game.set("ecos", [])
    game.set("torch_on", false)
    game.call("_on_floor_start")
    game.set("current_floor", 0)
    game.set("game_mode", "play")
    print("OK: Piso IX, Arietes, Coloso, columnas y enemigos más fuertes en lo profundo.")

    # Piso X: la Cosecha (braseros) y la traición del Hermano Mayor.
    game.set("current_floor", 9)
    game.set("current_room", 1)
    game.call("_on_floor_start")
    game.call("_enter_room")
    game.call("_dialog_skip")
    game.set("game_mode", "play")
    game.set("has_torch", true)
    game.set("torch_on", true)
    var brs: Array = game.get("braziers")
    if brs.size() != 2 or bool(game.call("_room_ready")):
        _fail("La Galería de los Braseros no tiene dos braseros o abre sin encenderlos.")
        return
    for b in brs:
        game.set("player_pos", Vector2(b["pos"]) + Vector2(-40, 0))
        game.call("_interact")
    if not bool(game.call("_room_ready")):
        _fail("Encender los braseros no cumple la misión.")
        return
    game.set("current_room", 3)
    game.call("_enter_room")
    game.call("_dialog_skip")
    game.set("game_mode", "play")
    game.set("torch_on", true)
    if not bool(game.get("elder_active")) or bool(game.call("_room_ready")):
        _fail("La Puerta de la Cosecha no tiene al Hermano Mayor o abre sin vencerlo.")
        return
    game.set("karma", 5)
    game.call("_update_harvest", 2.0)
    if str(game.get("elder_state")) == "talk":
        _fail("El Hermano Mayor no traiciona tras la conversación.")
        return
    # Mirada: alejarse mientras te mira hace daño; quedarse quieto, no.
    game.set("elder_state", "gaze")
    game.set("elder_t", 3.0)
    game.set("elder_tick", 0.0)
    game.set("hp", 100.0)
    game.set("player_pos", Vector2(300, 400))
    game.set("elder_last_player", Vector2(300, 400))
    game.call("_update_harvest", 0.1)
    if float(game.get("hp")) < 100.0:
        _fail("La mirada daña aunque estés quieto.")
        return
    game.set("player_pos", Vector2(280, 400)) # alejarse de él: darle la espalda
    game.call("_update_harvest", 0.1)
    if float(game.get("hp")) >= 100.0:
        _fail("La mirada no castiga darle la espalda.")
        return
    # Agotado tras el rugido: recibe el doble de daño.
    game.set("elder_state", "tired")
    game.set("elder_t", 2.0)
    var ehp: float = float(game.get("elder_hp"))
    game.call("_damage_elder", 10.0)
    if ehp - float(game.get("elder_hp")) < 19.0:
        _fail("Agotado no recibe el doble de daño.")
        return
    game.call("_damage_elder", 99999.0)
    if bool(game.get("elder_active")) or not bool(game.call("_room_ready")):
        _fail("Vencer al Hermano Mayor no abre la Puerta.")
        return
    game.call("_finish_floor")
    game.call("_after_floor_summary")
    if str(game.get("game_mode")) != "victory":
        _fail("Superar el Piso X no lleva al final del arco.")
        return
    game.set("karma", 0)
    game.set("torch_on", false)
    game.call("_on_floor_start")
    game.set("current_floor", 0)
    game.set("game_mode", "play")
    print("OK: Piso X, braseros, Hermano Mayor y final del arco.")

    # Habilidades: por muchas que haya, nunca se salen del cuadro (páginas).
    game.set("ecos", (game.get("ECOS") as Dictionary).keys())
    game.set("game_mode", "play")
    game.call("_open_abilities")
    var pages: int = int(game.call("_abil_pages"))
    var per_e: int = int(game.call("_eco_per_page"))
    if float(game.get("ABIL_TOP")) + float(per_e) * float(game.get("ECO_ROW_H")) > 560.0 or float(game.get("ABIL_TOP")) + float(game.call("_abil_per_page")) * float(game.get("ABIL_ROW_H")) > 560.0:
        _fail("Las filas de habilidades se salen del cuadro.")
        return
    if pages * per_e < (game.get("ECOS") as Dictionary).size() or pages < 2:
        _fail("Las páginas de habilidades no cubren todos los Ecos.")
        return
    game.call("_mobile_tap", (game.get("ABIL_NEXT_BTN") as Rect2).get_center())
    if int(game.get("abil_page")) != 1 or str(game.get("game_mode")) != "abilities":
        _fail("La flecha no pasa de página en Habilidades.")
        return
    game.call("_mobile_tap", Vector2(480, 300))
    if str(game.get("game_mode")) == "abilities":
        _fail("Tocar fuera no cierra Habilidades.")
        return
    game.set("ecos", [])
    game.set("game_mode", "play")
    print("OK: habilidades por páginas, sin salirse del cuadro.")

    # Pisos: se desbloquean uno a uno al superar el anterior.
    game.set("ecos", [])
    game.set("max_floor", 0)
    if int(game.call("_floors_unlocked")) != 0:
        _fail("Sin progreso hay pisos desbloqueados además del I.")
        return
    game.set("current_floor", 0)
    game.set("current_room", 0)
    game.call("_finish_floor")
    game.call("_after_floor_summary")
    if int(game.call("_floors_unlocked")) != 1:
        _fail("Superar el Piso I no desbloquea solo el II.")
        return
    game.call("_choose_floor", 3)
    if int(game.get("current_floor")) == 3:
        _fail("Se puede entrar en un piso bloqueado.")
        return
    # Resonancia -90 % y esquivar con recarga propia (+50 %).
    game.set("ability_level", 0)
    game.set("player_level", 1)
    if float(game.call("_pulse_damage")) > 3.5:
        _fail("La Resonancia sigue haciendo demasiado daño.")
        return
    game.set("game_mode", "play")
    game.set("ecos", [])
    game.set("dash_cd", 0.0)
    game.set("stamina", 100.0)
    game.call("_start_dash")
    var cd: float = float(game.get("dash_cd"))
    if absf(cd - 1.5 * float(game.call("_dash_cost")) / float(game.call("_stamina_regen"))) > 0.01:
        _fail("Esquivar no tiene su recarga del 50 % más.")
        return
    game.set("dash_left", 0.0)
    game.call("_start_dash")
    if float(game.get("dash_left")) > 0.0:
        _fail("Se puede esquivar otra vez durante la recarga.")
        return
    game.set("dash_cd", 0.0)
    print("OK: pisos por orden, Resonancia y esquivar ajustados.")

    var Ajustes = load("res://scripts/ajustes.gd")
    # Borrar perfil: todo el progreso fuera y vuelta a empezar (intro, tutorial, personaje).
    game.set("player_name", "SELENE")
    game.set("max_floor", 4)
    game.set("souls", 99)
    game.call("_save_progress")
    var vig := FileAccess.open("user://prueba_vigilia.json", FileAccess.WRITE)
    vig.store_string("{\"best_stage\": 7}")
    vig = null
    Ajustes.poner("tutorial_hecho", true)
    Ajustes.poner("intro_vista", true)
    game.call("_wipe_everything")
    if str(game.get("player_name")) != "" or int(game.get("max_floor")) != 0 or int(game.get("souls")) != 0:
        _fail("Borrar el perfil no vacía el progreso.")
        return
    if FileAccess.file_exists("user://prueba_progreso.json") or FileAccess.file_exists("user://prueba_vigilia.json"):
        _fail("Borrar el perfil deja archivos de progreso.")
        return
    if bool(Ajustes.obtener("tutorial_hecho")) or bool(Ajustes.obtener("intro_vista")):
        _fail("Tras borrar el perfil no vuelven la intro y el tutorial.")
        return
    Ajustes.poner("intro_vista", true)
    game.call("_start_explore")
    if not bool(game.get("in_tutorial")):
        _fail("Tras borrar el perfil no empieza por el tutorial.")
        return
    game.call("_end_tutorial")
    if str(game.get("game_mode")) != "create":
        _fail("Al terminar el tutorial sin personaje no se abre la creación.")
        return
    game.set("game_mode", "title")
    Ajustes.poner("tutorial_hecho", true)
    print("OK: borrar perfil reinicia todo: tutorial y creación del personaje.")

    # Cerrar el juego pregunta antes (autoload ConfirmarSalida) y pausa mientras tanto.
    var confirm: Node = root.get_node_or_null("ConfirmarSalida")
    if confirm == null:
        _fail("Falta el autoload ConfirmarSalida.")
        return
    game.call("_ask_quit")
    if not bool(confirm.call("abierta")) or not paused:
        _fail("Salir no pide confirmación.")
        return
    confirm.call("_responder", false)
    if bool(confirm.call("abierta")) or paused:
        _fail("Responder NO no vuelve al juego.")
        return
    print("OK: confirmación al salir.")

    # Relicario de vida en las salas sin entidad: cura y deja vida extra; una vez por partida.
    game.set("current_floor", 0)
    game.set("current_room", 4)
    game.call("_enter_room")
    game.call("_dialog_skip")
    game.set("game_mode", "play")
    if not bool(game.call("_fountain_here")):
        _fail("El Pórtico (sala sin entidad) no tiene relicario de vida.")
        return
    game.set("hp", float(game.get("max_hp")) - 10.0)
    game.set("player_pos", Vector2(game.get("FOUNTAIN_POS")) + Vector2(40, 0))
    game.call("_interact")
    var over: float = float(game.get("hp"))
    if over <= float(game.get("max_hp")):
        _fail("El relicario no cura por encima del máximo.")
        return
    game.set("regen_wait", 0.0)
    game.call("_update_regen", 1.0)
    if float(game.get("hp")) < over:
        _fail("La regeneración borra la vida extra.")
        return
    game.call("_interact")
    if float(game.get("hp")) > over + 0.01:
        _fail("El relicario cura dos veces en la misma partida.")
        return
    # Objetos en el perfil: la pestaña OBJETOS muestra lo equipado y deja usar el pan.
    game.set("bag", {"pan": 2})
    game.set("trinkets", ["brazalete"])
    game.call("_open_inventory")
    game.call("_profile_switch_tab")
    var slots: Array = game.call("_object_slots")
    var pan_i: int = -1
    var has_brazalete := false
    for i in range(slots.size()):
        if slots[i][5] == "pan":
            pan_i = i
        if slots[i][0] == "brazalete":
            has_brazalete = true
    if pan_i < 0 or not has_brazalete:
        _fail("La pestaña OBJETOS no muestra el pan o el brazalete equipado.")
        return
    game.set("inventory_sel", pan_i)
    game.call("_profile_use_selected")
    if int((game.get("bag") as Dictionary).get("pan", 0)) != 1:
        _fail("No se puede usar el pan desde el perfil.")
        return
    # Botín de la Vigilia en la bolsa: vial (vida extra) y bolsa de almas.
    game.set("bag", {"vial": 1, "bolsa_almas": 1})
    game.set("hp", float(game.get("max_hp")))
    var souls_v: int = int(game.get("souls"))
    game.call("_use_bag_item", "vial")
    game.call("_use_bag_item", "bolsa_almas")
    if float(game.get("hp")) <= float(game.get("max_hp")) or int(game.get("souls")) != souls_v + 25:
        _fail("El vial o la bolsa de almas de la Vigilia no funcionan en la campaña.")
        return
    game.call("_close_inventory")
    # Mejorar la Resonancia en el altar con almas.
    game.set("has_pulse", true)
    game.set("ability_level", 1)
    game.set("souls", 100)
    game.call("_buy_upgrade", 1)
    if int(game.get("ability_level")) != 2 or int(game.get("souls")) != 100 - 18:
        _fail("El altar no mejora la Resonancia con almas.")
        return
    # Maldición: el Mercader cobra más y el grupo del Piso VI no te sigue.
    game.set("karma", -3)
    var cursed_price: int = int(game.call("_shop_price", 1))
    game.set("current_floor", 5)
    game.set("current_room", 0)
    game.call("_on_floor_start")
    game.call("_enter_room")
    game.call("_dialog_skip")
    game.call("_accept_guides")
    game.call("_dialog_skip")
    if bool(game.get("guiding")) or cursed_price <= 5:
        _fail("Con la maldición el grupo te sigue igual o el Mercader no cobra más.")
        return
    game.set("karma", 0)
    game.set("bag", {})
    game.set("trinkets", [])
    game.set("ability_level", 0)
    game.set("has_pulse", false)
    game.call("_on_floor_start")
    game.set("current_floor", 0)
    game.set("game_mode", "play")
    print("OK: relicario de vida, vida extra, objetos, mejoras con almas y bendición/maldición.")

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


func _pad(game: Node, button: int) -> void:
    var e := InputEventJoypadButton.new()
    e.button_index = button
    e.pressed = true
    game.call("_input", e)


func _pad_axis(game: Node, axis: int, value: float) -> void:
    var e := InputEventJoypadMotion.new()
    e.axis = axis
    e.axis_value = value
    game.call("_input", e)
