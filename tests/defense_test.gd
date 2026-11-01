extends SceneTree
## Prueba automatizada del nuevo modo de defensa sin modificar la campana.
func _initialize() -> void:
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
        _fail("No se alcanza el amanecer.")
        return
    mode.call("_start", 0)
    mode.set("gate_hp", 1.0)
    mode.set("hunter_x", 735.0)
    mode.set("hunter_cooldown", 0.0)
    mode.call("_advance", 0.1)
    if mode.get("phase") != "lost":
        _fail("La caida de la puerta no provoca derrota.")
        return

    # Los tres refugios modifican realmente la partida.
    mode.call("_start", 0)
    if float(mode.get("income_rate")) != 3.0:
        _fail("La ventaja economica del Umbral no se aplica.")
        return
    mode.call("_start", 1)
    if float(mode.get("gate_max")) != 275.0:
        _fail("La camara Claustro debe tener una puerta mas fuerte.")
        return
    mode.call("_start", 2)
    if float(mode.get("sparks")) != 8.0:
        _fail("El Archivo debe iniciar con ocho puntos de energia.")
        return
    mode.set("income", 1000.0)
    if not mode.call("_action", 5):
        _fail("No se puede instalar el generador.")
        return
    mode.call("_action", 0)
    mode.call("_advance", 6.0)
    if float(mode.get("sparks")) <= 8.0:
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
    mode.set("hunter_x", 735.0)
    mode.set("hunter_cooldown", 0.0)
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
    quit(0)

func _fail(reason: String) -> void:
    push_error(reason)
    quit(1)
