extends SceneTree
## Verificacion automatica de texturas. Ejecutar en un proyecto con el parche aplicado.
func _initialize() -> void:
    call_deferred("_check")

func _check() -> void:
    var packed: PackedScene = load("res://scenes/main.tscn")
    if packed == null:
        _fail("No pudo cargar la escena principal")
        return
    var game: Node = packed.instantiate()
    root.add_child(game)
    var assets: Dictionary = game.get("art")
    var required: Array[String] = ["visual_hero", "visual_room_0", "visual_room_1", "visual_room_2", "visual_room_3", "visual_room_4", "angel_1", "ghoul_1", "wizard_1", "room_0"]
    for key in required:
        if not assets.has(key):
            _fail("Asset sin registrar: " + key)
            return
        var image: Texture2D = assets.get(key)
        if image == null or image.get_width() == 0 or image.get_height() == 0:
            _fail("Textura invalida: " + key)
            return
    print("OK: recursos visuales nuevos, originales y enemigos cargados correctamente.")
    game.free()
    game = null
    packed = null
    quit(0)

func _fail(reason: String) -> void:
    push_error(reason)
    quit(1)
