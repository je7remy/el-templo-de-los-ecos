extends SceneTree
## Comprueba entrada con dedos sinteticos. No sustituye una prueba de hardware real.
func _initialize() -> void:
    # Modo de prueba: archivos propios y limpios; tu partida y tus ajustes no se tocan.
    Engine.set_meta("modo_prueba", true)
    for f in ["user://prueba_progreso.json", "user://prueba_ajustes.cfg", "user://prueba_vigilia.json"]:
        if FileAccess.file_exists(f):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(f))
    call_deferred("_run")

func _run() -> void:
    # Sin pantalla la ventana mide 64 × 64: se le da el tamaño del juego para
    # que los toques caigan sobre los botones de las pantallas.
    root.size = Vector2i(960, 640)
    var a: PackedScene = load("res://scenes/main.tscn")
    var game: Node = a.instantiate()
    root.add_child(game)
    await process_frame
    # Primer toque: la pantalla de inicio (una escena con nodos de interfaz)
    # da paso al menú, y al acuerdo la primera vez.
    _tocar(Vector2(480, 300))
    if game.get("game_mode") == "eula":
        _tocar(Vector2(300, 399)) # ACEPTAR
    if game.get("game_mode") != "title":
        _fail("Tocar la pantalla de inicio no lleva al menú.")
        return
    # Sin intro ni tutorial para ir directo a la campaña.
    var Ajustes = load("res://scripts/ajustes.gd")
    Ajustes.poner("intro_vista", true)
    Ajustes.poner("tutorial_hecho", true)
    # Sin personaje guardado, EXPLORAR abre la creación: nombre y luego género.
    game.set("player_name", "")
    _tocar(Vector2(300, 470)) # botón JUGAR del menú
    if game.get("game_mode") != "floors":
        _fail("JUGAR no abre el menú de pisos.")
        return
    var card: Vector2 = (game.get_node("Pantallas/Maquina/Pisos").call("tarjeta", 0) as Control).get_global_rect().get_center()
    game.get_node("Pantallas/Maquina/Pisos").set("seleccion", 5)
    _tocar(card) # Piso I: el primer toque lo elige,
    _tocar(card) # el segundo desciende
    if game.get("game_mode") != "create":
        _fail("Explorar sin personaje no abre la creación.")
        return
    var creacion: Node = game.get_node("Pantallas/Maquina/Creacion")
    for letter in ["A", "N", "A"]:
        for key in creacion.call("teclas"):
            if str(key[1]) == letter:
                _tocar((key[0] as Rect2).get_center())
    _tocar(Vector2(660, 432)) # SIGUIENTE
    if int(game.get("create_step")) != 1 or str(game.get("create_buf")) != "ANA":
        _fail("El teclado en pantalla no escribe el nombre.")
        return
    _tocar(Vector2(620, 300)) # tarjeta FEMENINO
    _tocar(Vector2(645, 476)) # COMENZAR
    if game.get("player_name") != "ANA" or game.get("player_gender") != "femenino":
        _fail("No se guarda el personaje creado.")
        return
    if game.get("game_mode") != "play":
        _fail("Toque de inicio en la campaña no funciona.")
        return
    game.call("_mobile_touch", 2, Vector2(204, 490), true)
    if Vector2(game.get("mobile_axis")).length() <= 0.01:
        _fail("El joystick virtual no mueve su eje.")
        return
    game.call("_mobile_touch", 2, Vector2(204, 490), false)
    if Vector2(game.get("mobile_axis")).length() > 0.01:
        _fail("El joystick permanece activo despues de soltar el dedo.")
        return
    # El botón F necesita una antorcha construida y un fósforo.
    game.set("has_torch", true)
    game.set("matches", 5)
    var prev: bool = game.get("torch_on")
    game.call("_mobile_tap", (game.get("TOUCH_BUTTONS") as Dictionary)["antorcha"][0])
    if bool(game.get("torch_on")) == prev:
        _fail("No funciona el boton tactil de la linterna.")
        return
    # Un toque llega como ScreenTouch y además como clic emulado: solo debe contar una vez.
    game.set("game_mode", "play")
    var t := InputEventScreenTouch.new()
    t.index = 3
    t.pressed = true
    t.position = Vector2(150, 50) # retrato: abre el perfil
    game._input(t)
    var m := InputEventMouseButton.new()
    m.device = InputEvent.DEVICE_ID_EMULATION
    m.button_index = MOUSE_BUTTON_LEFT
    m.pressed = true
    m.position = Vector2(150, 50)
    game._input(m)
    if str(game.get("game_mode")) != "inventory":
        _fail("Tocar el retrato abre y cierra el perfil a la vez (toque doble).")
        return
    game.set("game_mode", "play")
    t.position = (game.get("MINIMAP_RECT") as Rect2).get_center()
    m.position = t.position
    game._input(t)
    game._input(m)
    if str(game.get("game_mode")) != "map":
        _fail("Tocar el minimapa abre y cierra el mapa a la vez (toque doble).")
        return
    game.set("game_mode", "play")
    # Teclado en pantalla: cada letra una sola vez, y el campo nativo del móvil filtra igual.
    game.set("touch_enabled", true)
    game.call("_start_creation", "title")
    game.set("create_buf", "")
    var keys: Array = game.get_node("Pantallas/Maquina/Creacion").call("teclas")
    _tocar((keys[0][0] as Rect2).get_center()) # toque + clic emulado, como en un móvil
    if (game.get("create_buf") as String).length() != 1:
        _fail("El teclado en pantalla escribe la letra dos veces.")
        return
    game.call("_on_name_edit_changed", "ana1  b")
    if str(game.get("create_buf")) != "ANA B":
        _fail("El teclado del móvil no filtra el nombre como el del juego.")
        return
    game.call("_create_back")
    game.set("touch_enabled", false)
    game.free()
    game = null
    a = null

    var b: PackedScene = load("res://scenes/defense.tscn")
    var guard: Node = b.instantiate()
    root.add_child(guard)
    var touch := InputEventScreenTouch.new()
    touch.pressed = true
    touch.index = 1
    touch.position = Vector2(480, 385)
    guard.call("_input", touch)
    if guard.get("phase") != "play":
        _fail("La seleccion tactil de una camara no funciona.")
        return
    touch.position = Vector2(100, 585)
    guard.call("_input", touch)
    if not bool(guard.get("sleeping")):
        _fail("El boton tactil DESCANSAR no funciona.")
        return
    print("OK: toques de inicio, joystick, linterna, refugio y descanso.")
    guard.free()
    guard = null
    b = null
    # Permite liberar recursos del stack de esta funcion antes de cerrar.
    call_deferred("quit", 0)

func _fail(reason: String) -> void:
    push_error(reason)
    quit(1)


## Un dedo en la pantalla, como en un móvil: el toque (lo usa el juego) y el
## clic que Godot emula a partir de él (lo usan los botones de interfaz).
func _tocar(at: Vector2) -> void:
    for pressed in [true, false]:
        var t := InputEventScreenTouch.new()
        t.index = 0
        t.position = at
        t.pressed = pressed
        root.push_input(t)
        var m := InputEventMouseButton.new()
        m.device = InputEvent.DEVICE_ID_EMULATION
        m.button_index = MOUSE_BUTTON_LEFT
        m.position = at
        m.global_position = at
        m.pressed = pressed
        m.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
        root.push_input(m)
