extends SceneTree
## Arquitectura por escenas (fase 3): el jugador y las entidades como escenas
## con su máquina de estados. Fase 3a: el jugador (Quieto, Camina, Esquiva).
## Fase 3b: su salud (Vivo, Herido, Muerto) con las señales herido y muerto.
## Fase 3c: la entidad de la sala; Ghoul, Testigo, Hechicero, Segador y
## Tejedora con su máquina de estados. Fase 3c-3: alimañas, mastines y arietes
## (una máquina de estados compartida por cada manada). Fase 3c-4: el Coloso y el
## Hermano Mayor (scenes/entidades/jefes.tscn). Fase 3c-5: la Vigía y el
## Peregrino.


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

    # --- Fase 3b: salud del jugador ------------------------------------------------
    game.set("mobile_axis", Vector2.ZERO)
    game.call("_new_run")
    game.call("_dialog_skip")
    game.set("game_mode", "play")
    for estado in ["Vivo", "Herido", "Muerto"]:
        if not bool(jugador.get_node("Salud").call("tiene", StringName(estado))):
            _fail("La salud del jugador no tiene el estado %s." % estado)
            return
    if float(game.get("hp")) != float(jugador.get("vida")) or float(game.get("stamina")) != float(jugador.get("vigor")):
        _fail("La vida y el vigor de la campaña no son los del jugador.")
        return
    var golpes: Array = []
    jugador.herido.connect(func(c): golpes.append(c))
    var vida0: float = float(game.get("hp"))
    game.set("fear", 0.0)
    game.call("_hurt", 20.0, 10.0, 1.0)
    if golpes != [20.0] or float(game.get("hp")) != vida0 - 20.0 or float(game.get("fear")) != 10.0:
        _fail("herir() no aplica el golpe o no avisa con «herido».")
        return
    if String(jugador.call("estado_salud")) != "Herido" or float(game.get("shake")) <= 0.0:
        _fail("Tras un golpe el jugador no pasa a Herido o no tiembla la pantalla.")
        return
    for i in range(70):
        game.call("_update_play", dt)
    if String(jugador.call("estado_salud")) != "Vivo" or float(game.get("damage_cd")) > 0.0:
        _fail("Al pasar la invulnerabilidad el jugador no vuelve a Vivo.")
        return
    # Sin vida: «muerto», pantalla de muerte y estado Muerto.
    var muertes: Array = []
    jugador.muerto.connect(func(): muertes.append(true))
    game.set("hp", 1.0)
    game.call("_hurt", 5.0, 0.0, 1.0)
    game.call("_update_play", dt)
    if muertes.size() != 1 or game.get("game_mode") != "dead" or String(jugador.call("estado_salud")) != "Muerto":
        _fail("Sin vida el jugador no muere (señal «muerto» y pantalla de muerte).")
        return
    game.call("_new_run")
    game.call("_dialog_skip")
    game.set("game_mode", "play")
    game.call("_update_play", dt)
    if String(jugador.call("estado_salud")) != "Vivo":
        _fail("Al empezar otra partida el jugador no vuelve a Vivo.")
        return
    print("OK: salud del jugador (vivo, herido, muerto) con las señales herido y muerto.")

    # --- Fase 3c: la entidad de la sala ----------------------------------------------
    var entidad: Node2D = game.get_node_or_null("Entidad")
    if entidad == null:
        _fail("Falta la escena de la entidad.")
        return
    for par in [["Ghoul", ["Reposo", "Caza", "Aturdida"]], ["Testigo", ["Vigila", "Caza", "Aturdida"]], ["Hechicero", ["Reposo", "Conjura", "Aturdida"]]]:
        var m: Node = entidad.get_node_or_null(String(par[0]))
        if m == null:
            _fail("La entidad no tiene la máquina del %s." % par[0])
            return
        for e in par[1]:
            if not bool(m.call("tiene", StringName(e))):
                _fail("La máquina del %s no tiene el estado %s." % [par[0], e])
                return
    # Ghoul (Piso I, sala 2): con la antorcha encendida cerca, Caza; a oscuras,
    # Reposo y vuelve a su sitio; aturdido, Aturdida y no se mueve.
    _sala(game, 0, 1)
    if game.call("_enemy_kind") != "ghoul" or (game.get("enemy_pos") as Vector2) != entidad.position:
        _fail("enemy_pos de la campaña no es la posición de la entidad.")
        return
    game.set("has_torch", true)
    game.set("torch_on", true)
    game.set("player_pos", entidad.position + Vector2(-200, 0))
    var e0: Vector2 = entidad.position
    for i in range(10):
        game.call("_update_play", dt)
    if String(entidad.call("estado")) != "Caza" or entidad.position.distance_to(e0) < 15.0 or not bool(game.get("enemy_alert")):
        _fail("El Ghoul no caza la luz (%s)." % entidad.call("estado"))
        return
    game.set("torch_on", false)
    var lejos: float = entidad.position.distance_to(entidad.get("hogar"))
    for i in range(10):
        game.call("_update_play", dt)
    if String(entidad.call("estado")) != "Reposo" or entidad.position.distance_to(entidad.get("hogar")) >= lejos:
        _fail("A oscuras el Ghoul no vuelve a su sitio.")
        return
    game.set("torch_on", true)
    game.set("enemy_stun", 1.0)
    var quieto_en: Vector2 = entidad.position
    game.call("_update_play", dt)
    if String(entidad.call("estado")) != "Aturdida" or entidad.position != quieto_en:
        _fail("Aturdido, el Ghoul debe quedarse quieto en Aturdida.")
        return
    # Desterrar: sin vida avisa con «desterrada» y la sala queda libre.
    var desterradas := [0]
    entidad.desterrada.connect(func(): desterradas[0] += 1)
    game.set("enemy_hp", 1.0)
    game.call("_damage_enemy", 5.0)
    if desterradas[0] != 1 or bool(game.call("_enemy_active")):
        _fail("Sin vida la entidad no se destierra (señal «desterrada»).")
        return
    # Testigo (Piso I, sala 3): con el ojo abierto persigue lo que se mueve.
    _sala(game, 0, 2)
    game.set("player_pos", entidad.position + Vector2(-200, 0))
    game.set("room_elapsed", 0.5) # ojo abierto
    game.set("mobile_axis", Vector2.UP)
    for i in range(6):
        game.call("_update_play", dt)
    if String(entidad.call("estado")) != "Caza":
        _fail("El Testigo no persigue al que se mueve con el ojo abierto (%s)." % entidad.call("estado"))
        return
    game.set("mobile_axis", Vector2.ZERO)
    for i in range(30):
        game.call("_update_play", dt)
    if String(entidad.call("estado")) != "Vigila":
        _fail("Quieto ante el Testigo, debe volver a Vigila.")
        return
    # Hechicero (Piso I, sala 4): responde a tu luz con un conjuro.
    _sala(game, 0, 3)
    game.set("has_torch", true)
    game.set("torch_on", true)
    game.set("player_pos", entidad.position + Vector2(-200, 0))
    game.set("wizard_cast_cd", 0.0)
    var conjuros := [0]
    entidad.conjuro.connect(func(_a, _b): conjuros[0] += 1)
    game.call("_update_play", dt)
    if String(entidad.call("estado")) != "Conjura" or conjuros[0] != 1 or (game.get("fireballs") as Array).size() != 1:
        _fail("El Hechicero no lanza su conjuro (señal «conjuro» y bola de fuego).")
        return
    print("OK: entidad de la sala como escena; Ghoul, Testigo y Hechicero con su máquina de estados.")

    # --- Fase 3c-2: Segador y Tejedora --------------------------------------------
    for par in [["Segador", ["Acecho", "Tensa", "Engancha"]], ["Tejedora", ["Anda", "Alza", "Zarpa"]]]:
        var mq: Node = entidad.get_node_or_null(String(par[0]))
        if mq == null:
            _fail("La entidad no tiene la máquina del %s." % par[0])
            return
        for e in par[1]:
            if not bool(mq.call("tiene", StringName(e))):
                _fail("La máquina %s no tiene el estado %s." % [par[0], e])
                return
    # Segador (Piso III, sala 2): Acecho → Tensa → Engancha (vulnerable) → Acecho.
    _sala(game, 2, 1)
    var vistos: Array = []
    entidad.get_node("Segador").estado_cambiado.connect(func(_a, b): vistos.append(String(b)))
    game.set("enemy_pos", Vector2(600, 360))
    game.set("player_pos", Vector2(300, 360))
    game.set("seg_cd", 0.0)
    game.call("_update_play", dt)
    if game.get("seg_state") != "tensa":
        _fail("El Segador no tensa sus hilos (%s)." % game.get("seg_state"))
        return
    if bool(game.call("_enemy_vulnerable")):
        _fail("El Segador no debe ser vulnerable mientras tensa.")
        return
    for i in range(60):
        game.call("_update_play", dt)
        game.set("hp", 100.0)
        if game.get("seg_state") == "engancha":
            break
    if game.get("seg_state") != "engancha" or not bool(game.call("_enemy_vulnerable")):
        _fail("Al disparar, el Segador no queda Enganchado y vulnerable.")
        return
    for i in range(120):
        game.call("_update_play", dt)
        game.set("hp", 100.0)
        if game.get("seg_state") == "acecho":
            break
    if vistos.slice(-3) != ["Tensa", "Engancha", "Acecho"]:
        _fail("Orden de estados del Segador inesperado: %s." % [vistos])
        return
    # Aturdirlo mientras tensa le corta los hilos.
    var cortes := [0]
    entidad.hilos_cortados.connect(func(): cortes[0] += 1)
    game.set("seg_state", "tensa")
    game.set("seg_t", 0.5)
    game.set("enemy_stun", 0.5)
    game.call("_update_play", dt)
    if game.get("seg_state") != "acecho" or cortes[0] != 1:
        _fail("Aturdido mientras tensa, el Segador no pierde sus hilos.")
        return
    # Tejedora (Piso IV, sala 2): Anda → Alza → Zarpa (te alcanza) → Anda.
    _sala(game, 3, 1)
    game.set("player_pos", entidad.position + Vector2(-40, 0))
    var vida_t: float = float(game.get("hp"))
    var golpeada := [false]
    entidad.zarpazo.connect(func(alcanza): golpeada[0] = alcanza)
    game.call("_update_play", dt)
    if game.get("teje_state") != "alza":
        _fail("A tu alcance la Tejedora no alza la zarpa (%s)." % game.get("teje_state"))
        return
    for i in range(60):
        game.set("player_pos", entidad.position + Vector2(-40, 0))
        game.call("_update_play", dt)
        if game.get("teje_state") == "zarpa":
            break
    if game.get("teje_state") != "zarpa" or not golpeada[0] or float(game.get("hp")) >= vida_t:
        _fail("El zarpazo de la Tejedora no alcanza a quien está a su lado.")
        return
    game.set("enemy_stun", 0.5)
    game.call("_update_play", dt)
    if game.get("teje_state") != "anda":
        _fail("Aturdida, la Tejedora debe volver a Anda.")
        return
    print("OK: Segador y Tejedora con su máquina de estados en la escena de la entidad.")

    # --- Fase 3c-3: manadas (alimañas, mastines, arietes) ---------------------------
    var manadas := {"Alimanas": ["Patrulla", "Persigue", "Muerta"], "Mastines": ["Vaga", "Ronda", "Carga", "Huye"],
        "Arietes": ["Quieto", "Apunta", "Embiste", "Aturdido"]}
    for nombre in manadas:
        var mn: Node = game.get_node_or_null("Criaturas/" + nombre)
        if mn == null:
            _fail("Falta la manada %s en scenes/entidades/criaturas.tscn." % nombre)
            return
        for e in manadas[nombre]:
            if not bool(mn.call("tiene", StringName(e))):
                _fail("La manada %s no tiene el estado %s." % [nombre, e])
                return
    _sala(game, 0, 0)
    var yo := Vector2(200, 360)
    game.set("player_pos", yo)
    # Alimaña: patrulla lejos; huele la sangre de cerca y se lanza; esquivando
    # se aplasta (Muerta) y suelta un alma.
    var rata := {"pos": yo + Vector2(300, 0), "a": yo + Vector2(250, 0), "b": yo + Vector2(350, 0), "to_b": true, "alive": true,
        "dead_t": 0.0, "respawn": false, "flip": false, "bite_cd": 0.0, "kind": "rata"}
    game.set("critters", [rata])
    game.call("_update_critters", dt)
    if str(rata.get("estado", "")) != "Patrulla":
        _fail("Lejos, la alimaña no patrulla (%s)." % rata.get("estado", ""))
        return
    rata["pos"] = yo + Vector2(60, 0)
    var antes_r: Vector2 = rata["pos"]
    game.call("_update_critters", dt)
    if str(rata["estado"]) != "Persigue" or Vector2(rata["pos"]).distance_to(yo) >= antes_r.distance_to(yo):
        _fail("De cerca, la alimaña no se lanza hacia ti.")
        return
    var almas0: int = int(game.get("souls"))
    rata["pos"] = yo + Vector2(10, 0)
    game.set("dash_left", 0.1)
    game.call("_update_critters", dt)
    game.set("dash_left", 0.0)
    game.call("_update_critters", dt)
    if bool(rata["alive"]) or str(rata["estado"]) != "Muerta" or int(game.get("souls")) != almas0 + 1:
        _fail("Esquivando, la alimaña no se aplasta (Muerta y un alma).")
        return
    # Mastín: con la antorcha ronda y guarda distancia; a oscuras carga y
    # muerde, y después huye un instante.
    var perro := {"pos": yo + Vector2(150, 0), "prev": yo + Vector2(150, 0), "home": yo + Vector2(150, 0), "wander": yo + Vector2(150, 0),
        "wander_t": 1.0, "flee": 0.0, "bite_cd": 0.0, "bite_t": 0.0, "facing": 0, "moving": false, "growl_t": 2.0, "detour": Vector2.ZERO, "detour_t": 0.0}
    game.set("hounds", [perro])
    game.set("torch_on", true)
    game.call("_update_hounds", dt)
    if str(perro.get("estado", "")) != "Ronda":
        _fail("Con la antorcha encendida el mastín no ronda (%s)." % perro.get("estado", ""))
        return
    game.set("torch_on", false)
    perro["pos"] = yo + Vector2(20, 0)
    game.set("damage_cd", 0.0)
    var vida_m: float = float(game.get("hp"))
    game.call("_update_hounds", dt)
    if str(perro["estado"]) != "Carga" or float(game.get("hp")) >= vida_m:
        _fail("A oscuras el mastín no carga y muerde.")
        return
    game.call("_update_hounds", dt)
    if str(perro["estado"]) != "Huye":
        _fail("Tras morder el mastín no se aparta (Huye).")
        return
    # Ariete: alineado contigo apunta, embiste, choca contra el muro y queda
    # aturdido; luego vuelve a rondar.
    game.set("player_pos", Vector2(150, 360))
    var ariete := {"pos": Vector2(260, 360), "prev": Vector2(260, 360), "home": Vector2(260, 360), "state": "idle", "t": 1.0,
        "dir": Vector2.ZERO, "hp": 70.0, "max": 70.0, "facing": 3, "cd": 0.0, "id": 0, "wander": Vector2(260, 360)}
    game.set("rams", [ariete])
    var visto: Array = []
    for i in range(400):
        game.set("damage_cd", 1.0) # que no empuje al jugador
        game.call("_update_rams", dt)
        if visto.is_empty() or visto[-1] != str(ariete["state"]):
            visto.append(str(ariete["state"]))
        if visto.size() >= 4:
            break
    if visto != ["aim", "charge", "stun", "idle"]:
        _fail("Orden de estados del ariete inesperado: %s." % [visto])
        return
    print("OK: alimañas, mastines y arietes con su máquina de estados (manadas).")

    # --- Fase 3c-4: jefes ---------------------------------------------------------
    var coloso: Node2D = game.get_node_or_null("Jefes/Coloso")
    var hermano: Node2D = game.get_node_or_null("Jefes/HermanoMayor")
    if coloso == null or hermano == null:
        _fail("Faltan el Coloso o el Hermano Mayor en scenes/entidades/jefes.tscn.")
        return
    # Coloso (Piso IX, sala 3): se acerca, alza el pie, pisa y vuelve a andar;
    # si le cae una columna queda aturdido.
    _sala(game, 8, 2)
    if not bool(game.get("colossus_active")) or (game.get("colossus_pos") as Vector2) != coloso.position:
        _fail("colossus_pos de la campaña no es la posición del Coloso.")
        return
    game.set("player_pos", coloso.position + Vector2(-60, 0))
    game.set("colossus_cd", 0.0)
    var pasos_c: Array = []
    for i in range(240):
        game.set("player_pos", coloso.position + Vector2(-60, 0))
        game.set("damage_cd", 0.0)
        game.set("hp", 100.0)
        game.call("_update_play", dt)
        var e: String = str(game.get("colossus_state"))
        if pasos_c.is_empty() or pasos_c[-1] != e:
            pasos_c.append(e)
        if pasos_c.size() >= 3:
            break
    if pasos_c != ["raise", "stomp", "walk"]:
        _fail("Orden de estados del Coloso inesperado: %s." % [pasos_c])
        return
    var pilar: Dictionary = (game.get("pillars") as Array)[0]
    game.call("_pillar_fall", pilar)
    if game.get("colossus_state") != "stun" or int(coloso.get("golpes")) != 1:
        _fail("Al caerle una columna, el Coloso no queda aturdido.")
        return
    # Hermano Mayor (Piso X, sala 4): habla, traiciona y lucha por reglas
    # (hilos, rugido, mirada).
    _sala(game, 9, 3)
    if not bool(game.get("elder_active")) or game.get("elder_state") != "talk":
        _fail("El Hermano Mayor no empieza hablando.")
        return
    var reglas: Array = []
    hermano.regla.connect(func(r): reglas.append(r))
    var vistos_h: Dictionary = {}
    for i in range(1500):
        game.set("hp", 100.0)
        game.call("_update_play", dt)
        vistos_h[str(game.get("elder_state"))] = true
        if reglas.size() >= 3 and vistos_h.has("tired") and vistos_h.has("threads"):
            break
    if reglas.slice(0, 3) != ["hilos", "rugido", "mirada"]:
        _fail("El Hermano Mayor no usa sus reglas en orden: %s." % [reglas])
        return
    for e in ["walk", "threads_aim", "threads", "roar", "tired", "gaze"]:
        if not vistos_h.has(e):
            _fail("El Hermano Mayor no pasa por el estado %s." % e)
            return
    print("OK: Coloso y Hermano Mayor con su máquina de estados (jefes).")

    # --- Fase 3c-5: la Vigía y el Peregrino -----------------------------------------
    var vigia: Node2D = game.get_node_or_null("Jefes/Vigia")
    var peregrino: Node2D = game.get_node_or_null("Peregrino")
    if vigia == null or peregrino == null:
        _fail("Faltan la Vigía (jefes.tscn) o el Peregrino (peregrino.tscn).")
        return
    # Vigía (Piso VII, sala 2): darle la espalda la provoca: Aviso → Golpe →
    # Mira; sostenerle la mirada lo bastante la vence.
    _sala(game, 6, 1)
    if not bool(game.get("gaze_active")) or game.get("gaze_state") != "mira" or (game.get("gaze_pos") as Vector2) != vigia.position:
        _fail("La Vigía no empieza mirando o gaze_pos no es su posición.")
        return
    var vistos_v: Array = []
    for i in range(240):
        game.set("player_dir", (game.get("player_pos") as Vector2 - vigia.position).normalized()) # de espaldas
        game.set("hp", 100.0)
        game.call("_update_play", dt)
        var ev: String = str(game.get("gaze_state"))
        if vistos_v.is_empty() or vistos_v[-1] != ev:
            vistos_v.append(ev)
        if vistos_v.size() >= 4:
            break
    if vistos_v != ["mira", "aviso", "golpe", "mira"]:
        _fail("Darle la espalda a la Vigía no sigue Aviso → Golpe → Mira: %s." % [vistos_v])
        return
    game.set("gaze_state_t", 0.0)
    game.set("gaze_t", float(game.get("gaze_need")))
    game.set("player_dir", (vigia.position - (game.get("player_pos") as Vector2)).normalized())
    game.call("_update_play", dt)
    if game.get("gaze_state") != "vencida":
        _fail("Sosteniéndole la mirada, la Vigía no queda vencida.")
        return
    # Peregrino (Piso II): te sigue; si es traidor, desenvaina, ataca con aviso
    # y, sin vida, muere.
    game.call("_new_run")
    game.call("_dialog_skip")
    game.set("current_floor", 1)
    game.set("current_room", 0)
    game.call("_pilgrim_reset")
    game.set("pilgrim_traitor", true)
    game.call("_enter_room")
    game.call("_dialog_skip")
    game.set("game_mode", "play")
    game.call("_update_play", dt)
    if game.get("pilgrim_state") != "follow" or String(peregrino.get_node("Maquina").call("nombre_actual")) != "Sigue":
        _fail("El Peregrino no te sigue al aparecer (%s)." % game.get("pilgrim_state"))
        return
    if (game.get("pilgrim_pos") as Vector2) != peregrino.position:
        _fail("pilgrim_pos de la campaña no es la posición del Peregrino.")
        return
    game.set("pilgrim_state", "tell")
    game.set("pilgrim_timer", 0.05)
    var tajos: Array = []
    peregrino.tajo.connect(func(a): tajos.append(a))
    for i in range(10):
        game.call("_update_play", dt)
    if game.get("pilgrim_state") != "hostile":
        _fail("Tras desenvainar, el Peregrino no pasa a Hostil.")
        return
    for i in range(240):
        game.set("pilgrim_pos", (game.get("player_pos") as Vector2) + Vector2(20, 0))
        game.set("damage_cd", 0.0)
        game.set("hp", 100.0)
        game.call("_update_play", dt)
        if not tajos.is_empty():
            break
    if tajos != [true]:
        _fail("El Peregrino hostil no tira el tajo con aviso (%s)." % [tajos])
        return
    game.call("_damage_pilgrim", 999.0)
    if game.get("pilgrim_state") != "dead":
        _fail("Sin vida el Peregrino no muere.")
        return
    print("OK: la Vigía y el Peregrino con su máquina de estados.")
    game.queue_free()
    await process_frame
    call_deferred("quit", 0)


func _sala(game: Node, piso: int, sala: int) -> void:
    game.call("_new_run")
    game.call("_dialog_skip")
    game.set("current_floor", piso)
    game.set("current_room", sala)
    game.call("_enter_room")
    game.call("_dialog_skip")
    game.set("game_mode", "play")
    game.set("mobile_axis", Vector2.ZERO)


func _fail(reason: String) -> void:
    push_error(reason)
    quit(1)
