extends SceneTree
## Prueba de simulacion completa: hay al menos una estrategia jugable para sobrevivir.
## No evalua FPS, pero descubre bloqueos, precios imposibles y finales inalcanzables.

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
        _fail("Escena Vigilia no importada.")
        return
    var mode: Node = packed.instantiate()
    root.add_child(mode)
    mode.call("_start", 0)
    mode.call("_action", 0) # El jugador comienza descansando para producir ecos.
    for step in range(1400):
        if mode.get("phase") != "play":
            break
        var bank: float = float(mode.get("income"))
        var wards: int = int(mode.get("wards"))
        var bed_level: int = int(mode.get("bed_level"))
        var gate_level: int = int(mode.get("gate_level"))
        var gen: int = int(mode.get("generator_level"))
        var ward_power: int = int(mode.get("ward_power"))
        var sparks: float = float(mode.get("sparks"))
        var gate_hp: float = float(mode.get("gate_hp"))
        var gate_max: float = float(mode.get("gate_max"))
        # Estrategia sencilla con los precios reales del juego.
        if gate_hp < gate_max - 70.0 and bank >= 18.0:
            mode.call("_action", 4)
        elif wards < 3 and bank >= float(mode.call("_build_cost", "centinela")):
            mode.call("_action", 3)
        elif bed_level < 5 and bank >= float(mode.call("_bed_cost")):
            mode.call("_action", 1)
        elif wards >= 2 and bank >= 40.0:
            # Mejorar el centinela más débil.
            var structs: Dictionary = mode.get("structs")
            var low := Vector2i(-1, -1)
            for t in structs:
                if structs[t]["type"] == "centinela" and (low.x < 0 or int(structs[t]["level"]) < int(structs[low]["level"])):
                    low = t
            if low.x >= 0 and bank >= float(mode.call("_upgrade_cost", low)):
                mode.call("_upgrade", low)
        elif gate_level < 4 and bank >= float(mode.call("_door_cost")):
            mode.call("_action", 2)
        elif gen < 2 and bank >= float(mode.call("_build_cost", "generador")):
            mode.call("_action", 5)
        elif wards >= 1 and ward_power < 5 and sparks >= 6.0 * float(ward_power):
            mode.call("_action", 6)
        mode.call("_advance", 0.1)
    if mode.get("phase") != "won":
        _fail("Estrategia de supervivencia fallida: " + str({
            "estado": mode.get("phase"),
            "tiempo": mode.get("elapsed"),
            "vida_puerta": mode.get("gate_hp"),
            "torres": mode.get("wards"),
            "cama": mode.get("bed_level")
        }))
        return
    if int(mode.get("session_score")) <= 0:
        _fail("La victoria no asigna puntuacion.")
        return
    var score: int = int(mode.get("session_score"))
    mode.call("_start", 1)
    if mode.get("phase") != "play":
        _fail("No se puede repetir partida.")
        return
    # Sin descansar ni construir debe ser posible perder.
    for step in range(460):
        if mode.get("phase") == "lost":
            break
        mode.call("_advance", 0.1)
    if mode.get("phase") != "lost":
        _fail("La puerta no cae incluso sin ninguna defensa.")
        return
    print("OK: partida completa, economia equilibrada, record, reinicio y derrota sin defensas. Puntos: %d" % score)
    mode.free()
    mode = null
    packed = null
    call_deferred("quit", 0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
