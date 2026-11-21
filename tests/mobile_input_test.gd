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
    var a: PackedScene = load("res://scenes/main.tscn")
    var game: Node = a.instantiate()
    root.add_child(game)
    # Primer toque: la pantalla de inicio da paso al menú (y al acuerdo la primera vez).
    game.call("_mobile_touch", 1, Vector2(480, 300), true)
    game.call("_mobile_touch", 1, Vector2(480, 300), false)
    if game.get("game_mode") == "eula":
        game.call("_mobile_touch", 1, Vector2(300, 399), true) # ACEPTAR
        game.call("_mobile_touch", 1, Vector2(300, 399), false)
    if game.get("game_mode") != "title":
        _fail("Tocar la pantalla de inicio no lleva al menú.")
        return
    # Sin intro ni tutorial para ir directo a la campaña.
    var Ajustes = load("res://scripts/ajustes.gd")
    Ajustes.poner("intro_vista", true)
    Ajustes.poner("tutorial_hecho", true)
    # Sin personaje guardado, EXPLORAR abre la creación: nombre y luego género.
    game.set("player_name", "")
    game.call("_mobile_touch", 1, Vector2(220, 490), true)
    if game.get("game_mode") != "create":
        _fail("Explorar sin personaje no abre la creación.")
        return
    for letter in ["A", "N", "A"]:
        for key in game.call("_create_name_keys"):
            if str(key[1]) == letter:
                game.call("_mobile_touch", 1, (key[0] as Rect2).get_center(), true)
                game.call("_mobile_touch", 1, (key[0] as Rect2).get_center(), false)
    game.call("_mobile_tap", Vector2(660, 432)) # SIGUIENTE
    if int(game.get("create_step")) != 1 or str(game.get("create_buf")) != "ANA":
        _fail("El teclado en pantalla no escribe el nombre.")
        return
    game.call("_mobile_tap", Vector2(620, 300)) # tarjeta FEMENINO
    game.call("_mobile_tap", Vector2(645, 476)) # COMENZAR
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
