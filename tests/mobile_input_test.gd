extends SceneTree
## Comprueba entrada con dedos sinteticos. No sustituye una prueba de hardware real.
func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var a: PackedScene = load("res://scenes/main.tscn")
    var game: Node = a.instantiate()
    root.add_child(game)
    game.call("_mobile_touch", 1, Vector2(220, 490), true)
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
    var prev: bool = game.get("torch_on")
    game.call("_mobile_tap", Vector2(585, 478))
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
    quit(0)

func _fail(reason: String) -> void:
    push_error(reason)
    quit(1)
