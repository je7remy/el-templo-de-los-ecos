extends SceneTree
## Prueba headless de recursos y dimensiones usada por CI con Godot 4.3.
func _initialize() -> void:
    call_deferred("_check")

func _check() -> void:
    var packed: PackedScene = load("res://scenes/main.tscn")
    if packed == null:
        _fail("No se pudo cargar la escena principal.")
        return

    var game: Node = packed.instantiate()
    root.add_child(game)
    var assets: Dictionary = game.get("art")

    var required: Array[String] = [
        "visual_hero", "room_0", "room_1", "room_2", "room_3", "room_4",
        "player", "knowledge_door", "knowledge_altar", "knowledge_book",
        "knowledge_torch", "angel_1", "angel_8", "ghoul_1", "ghoul_8",
        "wizard_1", "wizard_5", "fireball_1", "fireball_3"
    ]
    for i in range(5):
        required.append("visual_room_%d" % i)

    for key in required:
        if not assets.has(key):
            _fail("Falta el recurso: " + key)
            return
        var texture: Texture2D = assets.get(key)
        if texture == null or texture.get_width() <= 0 or texture.get_height() <= 0:
            _fail("Textura no importada o vacia: " + key)
            return

    var hero: Texture2D = assets.get("visual_hero")
    if hero.get_width() != 360 or hero.get_height() != 224:
        _fail("El spritesheet requiere 9 fotogramas x 4 direcciones (360x224).")
        return

    for i in range(5):
        var room: Texture2D = assets.get("visual_room_%d" % i)
        if room.get_width() != 960 or room.get_height() != 640:
            _fail("Dimensiones incorrectas de la sala visual %d." % i)
            return

    print("OK: recursos visuales nuevos, originales y enemigos cargados correctamente.")
    print("OK: protagonista 360x224, cinco salas 960x640, Angel, Ghoul y Wizard.")
    game.free()
    game = null
    packed = null
    call_deferred("quit", 0)

func _fail(reason: String) -> void:
    push_error(reason)
    quit(1)
