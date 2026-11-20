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

    # Capas de objetos para ordenar por profundidad (generadas por
    # herramientas/limpiar_fondos.py junto con scripts/room_props.gd).
    var room_props = load("res://scripts/room_props.gd")
    var props: Array = room_props.PROPS
    if props.size() != 5:
        _fail("scripts/room_props.gd debe describir las cinco salas.")
        return
    for i in range(5):
        var layer: Texture2D = assets.get("props_%d" % i)
        if layer == null or layer.get_width() != 960 or layer.get_height() != 640:
            _fail("Falta o tiene dimensiones incorrectas la capa de objetos %d." % i)
            return
        if (props[i] as Array).is_empty():
            _fail("La sala %d no tiene objetos para ordenar por profundidad." % i)
            return
        for prop in props[i]:
            var region: Rect2 = prop[0]
            if not Rect2(0, 0, 960, 640).encloses(region) or float(prop[1]) < region.position.y:
                _fail("Región de objeto inválida en la sala %d." % i)
                return
    var book_sheet: Texture2D = assets.get("knowledge_book_sheet")
    if book_sheet == null or book_sheet.get_width() != 8640 or book_sheet.get_height() != 64:
        _fail("La animación del libro del archivo debe tener 135 fotogramas de 64x64.")
        return

    print("OK: recursos visuales nuevos, originales y enemigos cargados correctamente.")
    print("OK: protagonista 360x224, cinco salas 960x640, Angel, Ghoul y Wizard.")
    print("OK: capas de profundidad de las cinco salas y libro animado del archivo.")
    game.free()
    game = null
    packed = null
    call_deferred("quit", 0)

func _fail(reason: String) -> void:
    push_error(reason)
    quit(1)
