extends SceneTree
## Prueba automatizada del nuevo modo de defensa sin modificar la campana.
func _initialize() -> void:
    # Modo de prueba: archivos propios y limpios; tu partida y tus ajustes no se tocan.
    Engine.set_meta("modo_prueba", true)
    for f in ["user://prueba_progreso.json", "user://prueba_ajustes.cfg", "user://prueba_vigilia.json"]:
        if FileAccess.file_exists(f):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(f))
    call_deferred("_run")

func _run() -> void:
    var packed: PackedScene = load("res://scenes/defense.tscn")
    if packed == null:
        _fail("No se pudo importar la escena de defensa.")
        return
    var mode: Node = packed.instantiate()
    root.add_child(mode)
    if mode.get("phase") != "selection":
        _fail("El modo defensa no inicia en seleccion.")
        return
    mode.call("_start", 1)
    if mode.get("phase") != "play":
        _fail("No se inicio la vigilia.")
        return
    if mode.call("_action", 0) != true:
        _fail("No se puede descansar.")
        return
    mode.call("_advance", 3.0)
    if float(mode.get("income")) <= 30.0:
        _fail("La cama no produce recursos.")
        return
    mode.set("income", 1000.0)
    for i in [1, 2, 3]:
        if not mode.call("_action", i):
            _fail("No se pudo mejorar lecho, puerta o centinela.")
            return
    if int(mode.get("wards")) != 1:
        _fail("No se construyo la defensa.")
        return
    mode.set("gate_hp", 40.0)
    if not mode.call("_action", 4):
        _fail("No se reparo la puerta.")
        return
    if float(mode.get("gate_hp")) <= 40.0:
        _fail("No se recupero la salud de la puerta.")
        return
    mode.call("_advance", 136.0)
    if mode.get("phase") != "won":
        _fail("No se supera la fase.")
        return
    # Botín: la fase da un objeto que se guarda en el progreso de la campaña.
    var rewards: Array = mode.get("rewards")
    var saved = JSON.parse_string(FileAccess.get_file_as_string("user://prueba_progreso.json")) if FileAccess.file_exists("user://prueba_progreso.json") else null
    if rewards.size() != 1 or not (saved is Dictionary):
        _fail("Superar la fase no da botín para la campaña.")
        return
    # Fases sin fin: la siguiente es más dura (más vida en las entidades).
    var hp1: float = float((mode.get("hunters") as Array)[0]["max"]) if not (mode.get("hunters") as Array).is_empty() else 84.0
    mode.call("_next_stage")
    if mode.get("phase") != "play" or int(mode.get("stage")) != 2 or float((mode.get("hunters") as Array)[0]["max"]) <= hp1:
        _fail("La fase 2 no empieza o no es más difícil.")
        return
    # Fase de jefe (cada 5): sale un jefe y da dos objetos de mejor nivel.
    mode.set("stage", 5)
    mode.call("_begin_stage")
    if not bool((mode.get("hunters") as Array)[0]["boss"]):
        _fail("La fase 5 no trae jefe.")
        return
    mode.call("_advance", 91.0)
    if (mode.get("rewards") as Array).size() != 2:
        _fail("La fase de jefe no da dos objetos.")
        return
    var botin = load("res://scripts/botin.gd")
    if int(botin.nivel(9)) <= int(botin.nivel(1)):
        _fail("El botín no mejora con la fase.")
        return
    mode.call("_start", 0)
    mode.set("gate_hp", 1.0)
    mode.call("_debug_hunter_at_door")
    mode.call("_advance", 0.1)
    if mode.get("phase") != "lost":
        _fail("La caida de la puerta no provoca derrota.")
        return

    # Un solo modo: cualquier llamada antigua a _start(n) da la misma partida.
    for legacy in [0, 1, 2]:
        mode.call("_start", legacy)
        if float(mode.get("income_rate")) != 2.5 or float(mode.get("gate_max")) != 210.0 or float(mode.get("sparks")) != 4.0:
            _fail("La Vigilia debe tener una sola configuracion fusionada.")
            return
    mode.set("income", 1000.0)
    if not mode.call("_action", 5):
        _fail("No se puede instalar el generador.")
        return
    mode.call("_action", 0)
    mode.call("_advance", 6.0)
    if float(mode.get("sparks")) <= 4.0:
        _fail("El generador no produce energia mientras se descansa.")
        return
    if not mode.call("_action", 3):
        _fail("No se puede crear un centinela.")
        return
    if not mode.call("_action", 6):
        _fail("No se puede potenciar un centinela.")
        return
    mode.set("sparks", 100.0)
    if not mode.call("_action", 7):
        _fail("No se puede activar el escudo.")
        return
    var preserved_hp: float = mode.get("gate_hp")
    mode.call("_debug_hunter_at_door")
    mode.call("_advance", 0.1)
    if float(mode.get("gate_hp")) < preserved_hp:
        _fail("El escudo no protege la puerta.")
        return
    if not mode.call("_action", 8) or not bool(mode.get("paused")):
        _fail("No se puede pausar la Vigilia.")
        return
    if mode.call("_action", 5):
        _fail("Se permite construir con la partida pausada.")
        return
    mode.call("_action", 8)

    # Vigilia v3: se construye en cualquier baldosa libre y todo se mejora tocándolo.
    mode.call("_start", 0)
    mode.set("income", 5000.0)
    if mode.call("_build", "centinela", Vector2i(1, 3)):
        _fail("Se permite construir encima del lecho.")
        return
    var tiles := [Vector2i(0, 0), Vector2i(10, 6), Vector2i(5, 1), Vector2i(3, 5)]
    for t in tiles:
        if not mode.call("_build", "centinela", t):
            _fail("No se puede construir en la baldosa %s." % str(t))
            return
    if mode.call("_build", "generador", Vector2i(0, 0)):
        _fail("Se permite construir sobre otra estructura.")
        return
    if int(mode.get("wards")) != 4 or int(mode.call("_build_cost", "centinela")) <= 20:
        _fail("El precio de cada centinela extra no sube.")
        return
    # Menú contextual: baldosa libre -> construir; estructura -> mejorar o vender.
    mode.call("_tap", mode.call("_tile_center", Vector2i(7, 2)))
    var popup: Dictionary = mode.get("popup")
    if popup.is_empty() or (popup["options"] as Array).size() != 3:
        _fail("Tocar una baldosa libre no abre el menu de construir.")
        return
    mode.call("_tap", mode.call("_popup_option_rect", 2).get_center())
    if not (mode.get("structs") as Dictionary).has(Vector2i(7, 2)) or mode.get("structs")[Vector2i(7, 2)]["type"] != "campana":
        _fail("El menu no construye la campana.")
        return
    if float(mode.call("_slow_factor")) >= 1.0:
        _fail("La campana no frena a las entidades.")
        return
    mode.set("income", 1.0e6)
    mode.call("_open_popup_for", Vector2i(0, 0))
    for i in range(20):
        mode.call("_popup_choose", 0)
    if int(mode.get("structs")[Vector2i(0, 0)]["level"]) != int(mode.get("STRUCT_MAX")):
        _fail("La estructura no sube hasta el nivel maximo.")
        return
    var bank: float = float(mode.get("income"))
    mode.call("_open_popup_for", Vector2i(10, 6))
    mode.call("_popup_choose", 1)
    if (mode.get("structs") as Dictionary).has(Vector2i(10, 6)) or float(mode.get("income")) <= bank:
        _fail("Vender no quita la estructura ni devuelve ecos.")
        return
    # Lecho y puerta tienen muchos niveles.
    mode.set("income", 1.0e7)
    for i in range(40):
        mode.call("_action", 1)
        mode.call("_action", 2)
    if int(mode.get("bed_level")) != int(mode.get("BED_MAX")) or int(mode.get("gate_level")) != int(mode.get("DOOR_MAX")) or int(mode.get("BED_MAX")) < 20:
        _fail("Lecho o puerta no llegan a sus nuevos niveles maximos.")
        return
    # Entidades más resistentes que antes (fase 1, oleada 1: más de 120 de vida).
    mode.call("_start", 0)
    if float((mode.get("hunters") as Array)[0]["max"]) < 120.0:
        _fail("Las entidades siguen teniendo poca vida.")
        return
    mode.call("_start", 0)

    # Tutorial guiado: la primera vez, EMPEZAR lo lanza; se completa paso a paso.
    mode.set("tutorial_done", false)
    mode.set("phase", "selection")
    mode.call("_choose_start")
    if int(mode.get("tut_step")) != 0:
        _fail("La primera Vigilia no empieza con el tutorial.")
        return
    var steps: int = (mode.get("TUT_STEPS") as Array).size()
    if steps < 10:
        _fail("El tutorial tiene menos de 10 pasos.")
        return
    mode.call("_tut_tap", (mode.get("TUT_CARD") as Rect2).get_center())
    mode.call("_tap", (mode.get("BED") as Rect2).get_center())
    mode.call("_popup_choose", 0) # dormir
    mode.call("_advance", 0.1)
    if int(mode.get("tut_step")) != 2:
        _fail("El paso de dormir no avanza.")
        return
    for i in range(200):
        mode.call("_advance", 0.1)
        if int(mode.get("tut_step")) >= 3:
            break
    mode.call("_build", "centinela", Vector2i(9, 3))
    for i in range(200):
        mode.call("_advance", 0.1)
        if int(mode.get("tut_step")) >= 5:
            break
    if int(mode.get("tut_step")) != 5 or float(mode.get("elapsed")) > 0.0:
        _fail("El tutorial no avanza al derrotar a la entidad o corre el reloj de la fase.")
        return
    mode.call("_upgrade", Vector2i(9, 3)); mode.call("_advance", 0.1)
    mode.call("_build", "generador", Vector2i(8, 3)); mode.call("_advance", 0.1)
    mode.call("_action", 6); mode.call("_advance", 0.1)
    mode.call("_build", "campana", Vector2i(8, 2)); mode.call("_advance", 0.1)
    mode.call("_action", 2); mode.call("_advance", 0.1)
    mode.call("_action", 4); mode.call("_advance", 0.1)
    mode.call("_action", 7); mode.call("_advance", 0.1)
    mode.call("_action", 1); mode.call("_advance", 0.1)
    mode.call("_sell", Vector2i(8, 2)); mode.call("_advance", 0.1)
    if int(mode.get("tut_step")) != steps - 1:
        _fail("El tutorial se atasca en el paso %d." % int(mode.get("tut_step")))
        return
    mode.call("_tut_tap", (mode.get("TUT_CARD") as Rect2).get_center())
    if int(mode.get("tut_step")) != -1 or not bool(mode.get("tutorial_done")) or int(mode.get("stage")) != 1 or (mode.get("structs") as Dictionary).size() != 0:
        _fail("Al terminar el tutorial no empieza una Vigilia limpia.")
        return
    mode.call("_start", 0)
    # El menú abierto se actualiza solo cuando los ecos alcanzan el precio.
    mode.set("income", 0.0)
    mode.call("_build", "centinela", Vector2i(5, 3))
    mode.set("income", 0.0)
    var free_t: Vector2i = mode.call("_free_tile")
    mode.call("_open_popup_for", free_t)
    if bool((mode.get("popup")["options"] as Array)[0]["enabled"]):
        _fail("Se puede construir sin ecos.")
        return
    mode.set("income", 9999.0)
    mode.call("_process", 0.016)
    if not bool((mode.get("popup")["options"] as Array)[0]["enabled"]):
        _fail("El menú no se actualiza al llegar los ecos al precio.")
        return
    mode.set("popup", {})
    # Salir guarda la fase; volver la continúa; perder la borra.
    mode.set("stage", 4)
    mode.set("phase", "play")
    mode.set("tut_step", -1)
    mode.call("_build", "generador", Vector2i(1, 1))
    mode.call("_save_records")
    mode.set("saved_run", {})
    mode.call("_load_records")
    mode.set("phase", "selection")
    if not bool(mode.call("_has_saved_run")):
        _fail("Salir de la Vigilia no guarda la fase.")
        return
    mode.call("_choose_start")
    if int(mode.get("stage")) != 4 or not (mode.get("structs") as Dictionary).has(Vector2i(1, 1)):
        _fail("Volver a la Vigilia no continúa la fase guardada.")
        return
    mode.set("gate_hp", 0.0)
    mode.call("_advance", 0.1)
    mode.call("_load_records")
    if bool(mode.call("_has_saved_run")):
        _fail("Perder no borra la vigilia guardada.")
        return
    mode.call("_start", 0)
    print("OK: defensa tactil, ingreso, mejoras, centinelas, reparacion, victoria y derrota.")
    # Fase 5a: portada, fase superada, puerta cedida y pausa son escenas.
    var pantallas: Node = mode.get("pantallas")
    if pantallas == null or not pantallas.has_method("mostrar"):
        _fail("La Vigilia no tiene sus escenas de pantalla.")
        return
    var esperadas := {"selection": &"Portada", "won": &"FaseSuperada", "lost": &"PuertaCedida", "play": &""}
    for fase in esperadas:
        mode.set("phase", fase)
        mode.set("paused", false)
        mode.call("_sync_pantallas")
        if pantallas.call("activa") != esperadas[fase]:
            _fail("La Vigilia en «%s» no muestra su pantalla." % fase)
            return
    mode.set("paused", true)
    mode.call("_sync_pantallas")
    if pantallas.call("activa") != &"Pausa":
        _fail("La pausa de la Vigilia no se ve.")
        return
    mode.set("paused", false)
    mode.set("phase", "won")
    mode.set("rewards", ["reliquia"])
    mode.call("_sync_pantallas")
    var botin_visto: Array = pantallas.call("pantalla", &"FaseSuperada").get("datos")["botin"]
    if botin_visto.size() != 1 or int(botin_visto[0][2]) != 4:
        _fail("La pantalla de fase superada no recibe el botín.")
        return
    print("OK: las pantallas de la Vigilia son escenas (portada, fase superada, puerta cedida y pausa).")
    # Fase 5b: barras, aviso, tutorial y menú de la baldosa son escenas del HUD.
    var hud: Node = mode.get("hud")
    if hud == null or hud.call("pieza", &"BarraSuperior") == null:
        _fail("La Vigilia no tiene su HUD como escena.")
        return
    mode.call("_start", 0)
    mode.set("info_time", 0.0)
    mode.call("_open_popup_for", Vector2i(6, 3))
    mode.call("_sync_pantallas")
    var menu: Control = hud.call("pieza", &"MenuBaldosa")
    if not menu.visible or str(menu.get("datos")["titulo"]) != "CONSTRUIR" or (hud.call("pieza", &"Aviso") as Control).visible:
        _fail("El menú de la baldosa o el aviso del HUD no responden a la partida.")
        return
    if not mode.call("_popup_rect").is_equal_approx(menu.call("caja", 3, mode.get("popup")["anchor"])):
        _fail("El menú del HUD y los toques de la Vigilia no coinciden.")
        return
    mode.set("popup", {})
    mode.call("_start_tutorial")
    mode.call("_sync_pantallas")
    if not (hud.call("pieza", &"Tutorial") as Control).visible or menu.visible:
        _fail("La tarjeta del tutorial no se ve en el HUD.")
        return
    mode.set("tut_step", -1)
    mode.set("phase", "selection")
    mode.call("_sync_pantallas")
    if not (hud.call("pieza", &"BarraSuperior") as Control).visible or (hud.call("pieza", &"Tutorial") as Control).visible:
        _fail("Las barras de la Vigilia no se ven en la portada.")
        return
    print("OK: HUD de la Vigilia (barras, aviso, tutorial y menú de la baldosa) como escena.")
    mode.free()
    mode = null
    packed = null
    # Permite liberar recursos del stack de esta funcion antes de cerrar.
    call_deferred("quit", 0)

func _fail(reason: String) -> void:
    push_error(reason)
    quit(1)
