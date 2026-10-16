extends SceneTree
## Prueba rapida no interactiva del primer piso. No sustituye las pruebas jugables.

func _initialize() -> void:
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

    if game.get("game_mode") != "title":
        _fail("El juego no inicia en el menu.")
        return
    game.call("_new_run")
    if game.get("game_mode") != "play":
        _fail("No se pudo iniciar una partida.")
        return

    for index in range(5):
        game.set("current_room", index)
        game.call("_enter_room")
        if int(game.get("current_room")) != index:
            _fail("Fallo al acceder a la sala %d." % (index + 1))
            return

    game.set("current_room", 2)
    game.call("_enter_room")
    game.set("player_pos", Vector2(704, 343))
    game.call("_interact")
    if not bool(game.get("seal_acquired")):
        _fail("No fue posible recoger el sello de la mision.")
        return

    game.call("_lose_run")
    if game.get("game_mode") != "dead":
        _fail("La derrota no cambia el estado de juego.")
        return
    if not (game.get("soul_fate") in ["retorno", "absorcion"]):
        _fail("Resultado de muerte invalido.")
        return
    print("OK: carga, inicio, 5 salas, sello y desenlace de muerte.")
    # Liberar la escena y sus recursos antes de cerrar la prueba headless.
    # Sin esto, Godot puede informar recursos retenidos al finalizar el proceso.
    game.free()
    game = null
    packed = null
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
