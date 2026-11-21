extends SceneTree
## Prueba headless de recursos y dimensiones usada por CI con Godot 4.3.
func _initialize() -> void:
    # Modo de prueba: archivos propios y limpios; tu partida y tus ajustes no se tocan.
    Engine.set_meta("modo_prueba", true)
    for f in ["user://prueba_progreso.json", "user://prueba_ajustes.cfg", "user://prueba_vigilia.json"]:
        if FileAccess.file_exists(f):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(f))
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

    # Salas editables (rooms/sala_N.tscn): arquitectura en TileMapLayer,
    # objetos como Sprite2D, marcadores de juego y colisiones.
    var required_markers := ["Jugador", "Salida", "Reliquia1", "Reliquia2", "Reliquia3"]
    var room_markers := [[], ["Enemigo", "Altar"], ["Enemigo", "Sello", "Ojo"], ["Enemigo", "Libro", "Lectura"], []]
    for i in range(5):
        var scene: PackedScene = load("res://rooms/sala_%d.tscn" % i)
        if scene == null:
            _fail("No se puede cargar rooms/sala_%d.tscn." % i)
            return
        var room: Node = scene.instantiate()
        var layer := room.get_node_or_null("Arquitectura") as TileMapLayer
        if layer == null or layer.get_used_cells().size() < 600:
            _fail("La sala %d no tiene la arquitectura en TileMapLayer." % i)
            room.free()
            return
        var props: Node = room.get_node_or_null("Objetos")
        if props == null or props.get_child_count() < 6:
            _fail("La sala %d perdió sus objetos (columnas, estatuas, braseros)." % i)
            room.free()
            return
        for marker in required_markers + room_markers[i]:
            if room.get_node_or_null("Marcadores/" + marker) == null:
                _fail("Falta el marcador %s en la sala %d." % [marker, i])
                room.free()
                return
        if room.find_children("*", "CollisionShape2D", true, false).size() < 2:
            _fail("La sala %d no tiene colisiones." % i)
            room.free()
            return
        # Todo objeto es sólido: tiene su colisión o lo cubre una colisión de grupo.
        var sueltas: Array = []
        var grupo: Node = room.get_node_or_null("Colisiones")
        if grupo != null:
            for forma in grupo.get_children():
                var r := (forma as CollisionShape2D).shape as RectangleShape2D
                sueltas.append(Rect2((forma as Node2D).position - r.size * 0.5, r.size))
        for sprite in props.get_children():
            if sprite.get_node_or_null("Colision") != null:
                continue
            var base: Vector2 = (sprite as Node2D).position + Vector2(0.0, -4.0)
            var cubierto := false
            for r in sueltas:
                if (r as Rect2).grow(15.5).has_point(base): # mismo margen que _is_blocked
                    cubierto = true
            if not cubierto:
                _fail("El objeto %s de la sala %d se puede atravesar." % [sprite.name, i])
                room.free()
                return
        room.free()
    var book_sheet: Texture2D = assets.get("knowledge_book_sheet")
    if book_sheet == null or book_sheet.get_width() != 8640 or book_sheet.get_height() != 64:
        _fail("La animación del libro del archivo debe tener 135 fotogramas de 64x64.")
        return

    print("OK: recursos visuales nuevos, originales y enemigos cargados correctamente.")
    print("OK: protagonista 360x224, cinco salas 960x640, Angel, Ghoul y Wizard.")
    for kind in ["testigo", "ghoul", "hechicero"]:
        var sheet: Texture2D = assets.get("enemy_" + kind)
        if sheet == null or sheet.get_height() != 256 or sheet.get_width() % 48 != 0:
            _fail("La hoja de la entidad %s debe tener 4 filas de 48x64." % kind)
            return
    print("OK: cinco salas editables (TileMapLayer, objetos, marcadores, colisiones), entidades y libro.")
    game.free()
    game = null
    packed = null
    call_deferred("quit", 0)

func _fail(reason: String) -> void:
    push_error(reason)
    quit(1)
