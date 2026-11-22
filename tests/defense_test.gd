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
    mode.call("_start", 0)

    print("OK: defensa tactil, ingreso, mejoras, centinelas, reparacion, victoria y derrota.")
    mode.free()
    mode = null
    packed = null
    # Permite liberar recursos del stack de esta funcion antes de cerrar.
    call_deferred("quit", 0)

func _fail(reason: String) -> void:
    push_error(reason)
    quit(1)
