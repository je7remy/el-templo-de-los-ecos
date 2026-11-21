## [VISUAL UPGRADE]
extends Node2D
## Primer piso. Adaptación de los tres documentos GDD, Lore v0.2 y Reglas v0.1.
## Knowledge Temple + GothicVania reales incorporados desde los ZIP aportados.
## Mecánicas no canonizadas se indican como provisionales en docs/DECISIONES.md.

const W: float = 960.0
const H: float = 640.0
const ARENA: Rect2 = Rect2(40.0, 122.0, 880.0, 458.0)
const SAVE_PATH: String = "user://templo_personaje_v03.json"
const BRAND_ICON: Texture2D = preload("res://assets/branding/icon.svg")
const ROOM_NAMES := [
    "I · UMBRAL DEL DESPERTAR",
    "II · CLAUSTRO DE LAS OFRENDAS",
    "III · SALA DEL TESTIGO",
    "IV · ARCHIVO DE LOS AUSENTES",
    "V · PÓRTICO DEL SIGUIENTE PISO"
]
const ROOM_WHISPERS := [
    "Una inscripción dice: 'La esperanza es parte del mecanismo'.",
    "Las piedras tienen marcas de quienes estuvieron antes que tú.",
    "No todos los ojos necesitan luz para verte.",
    "Algunas cartas parecen escritas por personas que regresaron.",
    "Esto no es una salida. Es una transición."
]

const RELICS := [
    Vector2(280, 245), Vector2(500, 465), Vector2(725, 230)
]
## Objetos interactivos. Las posiciones de dibujo y de interacción comparten
## constante para que lo que se ve coincida con donde se pulsa E.
const SEAL_POS := Vector2(704, 343)
const ALTAR_POS := Vector2(488, 318) # delante de la estatua central del claustro
const BOOK_POS := Vector2(497, 310) # sobre la mesa del archivo (base del libro)
const ARCHIVE_POS := Vector2(497, 362) # frente a la mesa, donde se lee
const EYE_POS := Vector2(690, 143) # ojo tallado en el muro del fondo
const DOOR_POS := Vector2(867, 355)
## Enemigos: hojas originales de 48x64 por celda, pies en y=61.
## Filas: 0 abajo, 1 arriba, 2 derecha, 3 izquierda.
const ENEMY_CELL := Vector2(48.0, 64.0)
const ENEMY_FEET_Y := 61.0
## Salas editables: TileMapLayer + objetos + marcadores + colisiones.
## Se generaron con herramientas/construir_salas.*; desde entonces se editan en Godot.
## Inventario y habilidades: iconos originales (herramientas/generar_iconos.py).
const ICONS := {
    "madera": preload("res://assets/visual/iconos/madera.png"),
    "fosforos": preload("res://assets/visual/iconos/fosforos.png"),
    "antorcha": preload("res://assets/visual/iconos/antorcha.png"),
    "antorcha_encendida": preload("res://assets/visual/iconos/antorcha_encendida.png"),
    "llama_interior": preload("res://assets/visual/iconos/llama_interior.png"),
    "resonancia": preload("res://assets/visual/iconos/resonancia.png"),
    "golpe": preload("res://assets/visual/iconos/golpe.png"),
    "alma": preload("res://assets/visual/iconos/alma.png"),
}
## Casillas del inventario: [clave, nombre, descripción].
const INVENTORY_SLOTS := [
    ["madera", "MADERA Y TELA", "El cuerpo de una antorcha. Con fósforos se construye sola."],
    ["fosforos", "FÓSFOROS", "Encender la antorcha gasta uno. Apagarla es gratis."],
    ["antorcha", "ANTORCHA", "F enciende o apaga. Encendida ilumina, atrae miradas y permite golpear."],
    ["llama_interior", "LLAMA INTERIOR", "Habilidad del altar: enciendes la antorcha sin gastar fósforos."],
    ["golpe", "GOLPE DE ANTORCHA", "Clic o E con la antorcha encendida: daño de fuego a corta distancia."],
    ["resonancia", "RESONANCIA", "Q: una onda que daña y aturde a las entidades cercanas."],
]
## Objetos de cada sala: [clave, marcador en la escena, posición por defecto].
const ROOM_ITEMS := {
    0: [["madera", "Madera", Vector2(330, 445)], ["fosforos", "Fosforos", Vector2(600, 250)]],
    2: [["fosforos", "Fosforos", Vector2(250, 470)]],
    3: [["fosforos", "Fosforos", Vector2(230, 460)]],
}
## Cuerpos de los antiguos dueños bajo cada alma (herramientas/generar_cuerpos.py).
const CORPSES := [
    preload("res://assets/visual/cuerpos/cuerpo_1.png"),
    preload("res://assets/visual/cuerpos/cuerpo_2.png"),
    preload("res://assets/visual/cuerpos/cuerpo_3.png"),
]
const DOOR_TOUCH := 36.0 # distancia a la que tocar la puerta abierta te hace cruzarla
const MATCHES_FIRST_BOX := 5
const MATCHES_REFILL := 3
## Vida de cada entidad por sala (PROVISIONAL, ajustar en pruebas de juego).
const ENEMY_MAX_HP := [0.0, 60.0, 90.0, 70.0, 0.0]
const WIZARD_CHARGE := 1.0 # segundos de carga visibles (y vulnerables) del conjuro
const STRIKE_RANGE := 64.0
const STRIKE_DAMAGE := 18.0
const PULSE_RADIUS := 150.0
const BANISH_SOULS := 10
const ROOM_SCENES := [
    preload("res://rooms/sala_0.tscn"),
    preload("res://rooms/sala_1.tscn"),
    preload("res://rooms/sala_2.tscn"),
    preload("res://rooms/sala_3.tscn"),
    preload("res://rooms/sala_4.tscn"),
]
const WALL_COLOR := Color("#394052")
const BG := Color("#090c17")
const CREAM := Color("#d9d2ba")
const SOUL := Color("#8fc7d7")
const RED := Color("#d06470")

## Precarga estatica: Godot detecta estas rutas al importar el proyecto y al exportarlo.
## No cargar PNG mediante rutas construidas dinamicamente: pueden omitirse del import/export.
const ART_PRELOADED := {
    "visual_room_0": preload("res://assets/visual/rooms/room_0.png"),
    "visual_room_1": preload("res://assets/visual/rooms/room_1.png"),
    "visual_room_2": preload("res://assets/visual/rooms/room_2.png"),
    "visual_room_3": preload("res://assets/visual/rooms/room_3.png"),
    "visual_room_4": preload("res://assets/visual/rooms/room_4.png"),
    "visual_hero": preload("res://assets/visual/protagonist_sheet.png"),
    "knowledge_book_sheet": preload("res://assets/knowledge/magic_book_sheet.png"),
    ## Entidades originales cenitales (herramientas/generar_enemigos.py).
    "enemy_testigo": preload("res://assets/visual/enemies/testigo.png"),
    "enemy_ghoul": preload("res://assets/visual/enemies/ghoul.png"),
    "enemy_hechicero": preload("res://assets/visual/enemies/hechicero.png"),

    "room_0": preload("res://assets/knowledge/rooms/room_0.png"),
    "room_1": preload("res://assets/knowledge/rooms/room_1.png"),
    "room_2": preload("res://assets/knowledge/rooms/room_2.png"),
    "room_3": preload("res://assets/knowledge/rooms/room_3.png"),
    "room_4": preload("res://assets/knowledge/rooms/room_4.png"),
    "player": preload("res://assets/fallback/player.png"),
    "knowledge_door": preload("res://assets/knowledge/door_closed.png"),
    "knowledge_altar": preload("res://assets/knowledge/altar.png"),
    "knowledge_book": preload("res://assets/knowledge/magic_book.png"),
    "knowledge_torch": preload("res://assets/knowledge/torch_1.png"),
    "angel_1": preload("res://assets/gothic_enemies/angel_1.png"),
    "angel_2": preload("res://assets/gothic_enemies/angel_2.png"),
    "angel_3": preload("res://assets/gothic_enemies/angel_3.png"),
    "angel_4": preload("res://assets/gothic_enemies/angel_4.png"),
    "angel_5": preload("res://assets/gothic_enemies/angel_5.png"),
    "angel_6": preload("res://assets/gothic_enemies/angel_6.png"),
    "angel_7": preload("res://assets/gothic_enemies/angel_7.png"),
    "angel_8": preload("res://assets/gothic_enemies/angel_8.png"),
    "ghoul_1": preload("res://assets/gothic_enemies/ghoul_1.png"),
    "ghoul_2": preload("res://assets/gothic_enemies/ghoul_2.png"),
    "ghoul_3": preload("res://assets/gothic_enemies/ghoul_3.png"),
    "ghoul_4": preload("res://assets/gothic_enemies/ghoul_4.png"),
    "ghoul_5": preload("res://assets/gothic_enemies/ghoul_5.png"),
    "ghoul_6": preload("res://assets/gothic_enemies/ghoul_6.png"),
    "ghoul_7": preload("res://assets/gothic_enemies/ghoul_7.png"),
    "ghoul_8": preload("res://assets/gothic_enemies/ghoul_8.png"),
    "wizard_1": preload("res://assets/gothic_enemies/wizard_1.png"),
    "wizard_2": preload("res://assets/gothic_enemies/wizard_2.png"),
    "wizard_3": preload("res://assets/gothic_enemies/wizard_3.png"),
    "wizard_4": preload("res://assets/gothic_enemies/wizard_4.png"),
    "wizard_5": preload("res://assets/gothic_enemies/wizard_5.png"),
    "fireball_1": preload("res://assets/gothic_enemies/fireball_1.png"),
    "fireball_2": preload("res://assets/gothic_enemies/fireball_2.png"),
    "fireball_3": preload("res://assets/gothic_enemies/fireball_3.png"),
}

var font: Font
var game_mode: String = "title" # title, play, altar, dead, victory
var current_room: int = 0
var elapsed: float = 0.0
var room_elapsed: float = 0.0
var player_pos: Vector2 = Vector2(120, 355)
var player_dir: Vector2 = Vector2.RIGHT
var player_moving: bool = false
var hp: float = 100.0
var max_hp: float = 100.0
var fear: float = 0.0
var stamina: float = 100.0
var souls: int = 0
var torch_on: bool = false
## Inventario de la partida (se pierde al empezar otra).
var has_wood: bool = false
var has_torch: bool = false
var matches: int = 0
var has_inner_flame: bool = false # habilidad del altar; se guarda como Resonancia
var items_taken: Dictionary = {} # "sala:clave" -> true
var room_items: Array = [] # {kind, pos}
var inventory_sel: int = 0
## Combate.
var enemy_hp: float = 0.0
var enemy_max: float = 1.0
var banished: Dictionary = {} # sala -> true (desterrada en esta partida)
var enemy_hit_t: float = 0.0
var strike_cd: float = 0.0
var strike_fx: float = 0.0
var strike_dir: Vector2 = Vector2.RIGHT
var pulse_fx: float = -1.0
var float_fx: Array = [] # {pos, text, color, t}
var dissolve_fx: Array = [] # {pos, kind, facing, frame, t}
var drops: Array = [] # {pos}
var door_msg_cd: float = 0.0
var step_t: float = 0.0
var step_i: int = 0
var dash_left: float = 0.0
var dash_cd: float = 0.0
var pulse_cd: float = 0.0
var ward_left: float = 0.0
var damage_cd: float = 0.0
var enemy_stun: float = 0.0
var enemy_pos: Vector2 = Vector2(788, 370)
var enemy_home: Vector2 = Vector2(788, 370)
var enemy_alert: bool = false
## Solo visual: orientación y movimiento del enemigo para elegir la animación.
var enemy_facing: int = 0 # 0 abajo, 1 arriba, 2 derecha, 3 izquierda
var enemy_moving: bool = false
var enemy_prev_pos: Vector2 = Vector2.ZERO
var wizard_cast_cd: float = 2.6
var fireballs: Array[Dictionary] = []
var collected: Array[bool] = [false, false, false]
var obstacles: Array[Rect2] = []
## Datos leídos de la escena de la sala actual (los const son valores por defecto).
var room_node: Node2D = null
var room_props: Array = [] # {tex, rect, base, shadow, light, flip}
var relics: Array = RELICS.duplicate()
var seal_pos: Vector2 = SEAL_POS
var altar_pos: Vector2 = ALTAR_POS
var book_pos: Vector2 = BOOK_POS
var archive_pos: Vector2 = ARCHIVE_POS
var eye_pos: Vector2 = EYE_POS
var door_pos: Vector2 = DOOR_POS
var still_timer: float = 0.0
var dark_timer: float = 0.0
var letter_found: bool = false
var has_pulse: bool = false
var ability_level: int = 0
var remembered_rule: bool = false
var seal_acquired: bool = false
var observed_rule: bool = false
var watcher_open: bool = false
var soul_fate: String = ""
var identity_number: int = 1
var new_humans: int = 0
var reincarnations: int = 0
var art: Dictionary = {}
var visual_interaction_left: float = 0.0
## Solo visual: polvo a los pies al chocar con un objeto sólido.
var bump_left: float = 0.0
var bump_at: Vector2 = Vector2.ZERO
var mobile_axis: Vector2 = Vector2.ZERO
var mobile_finger: int = -1
var touch_enabled: bool = false
var toast: String = ""
var toast_left: float = 0.0
var deaths: int = 0
var cleared: int = 0
## Audio original (herramientas/generar_audio.py): ambiente + capa de tensión
## adaptativa + grupo de reproductores para efectos.
const SFX_PATHS := {
    "alma": "res://audio/sfx_alma.ogg", "dano": "res://audio/sfx_dano.ogg",
    "ojo": "res://audio/sfx_ojo.ogg", "aviso": "res://audio/sfx_aviso.ogg",
    "sello": "res://audio/sfx_sello.ogg", "puerta": "res://audio/sfx_puerta.ogg",
    "conjuro": "res://audio/sfx_conjuro.ogg", "libro": "res://audio/sfx_libro.ogg",
    "linterna": "res://audio/sfx_linterna.ogg", "muerte": "res://audio/sfx_muerte.ogg",
    "fosforo": "res://audio/sfx_fosforo.ogg", "apagar": "res://audio/sfx_apagar.ogg",
    "objeto": "res://audio/sfx_objeto.ogg", "golpe": "res://audio/sfx_golpe.ogg",
    "impacto": "res://audio/sfx_impacto.ogg", "inmune": "res://audio/sfx_inmune.ogg",
    "resonancia": "res://audio/sfx_resonancia.ogg", "destierro": "res://audio/sfx_destierro.ogg",
    "interfaz": "res://audio/sfx_interfaz.ogg", "toque": "res://audio/sfx_toque.ogg",
    "paso_1": "res://audio/sfx_paso_1.ogg", "paso_2": "res://audio/sfx_paso_2.ogg",
    "paso_3": "res://audio/sfx_paso_3.ogg",
}
var music: AudioStreamPlayer
var tension: AudioStreamPlayer
var sfx_pool: Array[AudioStreamPlayer] = []
var sfx_streams: Dictionary = {}
var tension_level: float = 0.0
## Sensación de juego (solo visual / sonoro, sin efecto en las reglas).
var shake: float = 0.0
var souls_flash: float = 0.0
var pickup_fx: Array = [] # {pos, t}
var watcher_was_open: bool = false
var watcher_warned: bool = false


func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    touch_enabled = DisplayServer.is_touchscreen_available() or OS.has_feature("mobile")
    font = ThemeDB.fallback_font
    randomize()
    _load_progress()
    _load_art()
    _load_room_scene() # sala 1 como fondo del menú
    # No iniciar AudioServer en tests sin pantalla: no hay salida de sonido.
    # En juego normal mantener audio ambiental y efectos completos.
    var audio_available: bool = DisplayServer.get_name() != "headless"
    music = AudioStreamPlayer.new()
    tension = AudioStreamPlayer.new()
    add_child(music)
    add_child(tension)
    for i in range(8):
        var player := AudioStreamPlayer.new()
        add_child(player)
        sfx_pool.append(player)
    if audio_available:
        var templo: AudioStreamOggVorbis = load("res://audio/musica_templo.ogg")
        var capa: AudioStreamOggVorbis = load("res://audio/musica_tension.ogg")
        templo.loop = true
        capa.loop = true
        music.stream = templo
        tension.stream = capa
        music.volume_db = -14.0
        tension.volume_db = -60.0
        music.play()
        tension.play() # empieza en silencio; sube con el peligro
        for key in SFX_PATHS:
            sfx_streams[key] = load(SFX_PATHS[key])
    queue_redraw()

func _load_art() -> void:
    # Preload hace que la ausencia de un asset sea un error comprobable y no invisible.
    art = ART_PRELOADED.duplicate()


func _exit_tree() -> void:
    # Evita que el servidor de audio retenga AudioStreamPlaybackWAV al
    # cambiar escenas, cerrar el juego o terminar una prueba automatizada.
    for player in [music, tension] + sfx_pool:
        if is_instance_valid(player):
            player.stop()
            player.stream = null
    sfx_streams.clear()


## Efecto con ligera variación de tono para que no suene repetitivo.
func _sfx(key: String, volume_db: float = -6.0, pitch: float = 1.0) -> void:
    if not sfx_streams.has(key):
        return
    var chosen: AudioStreamPlayer = sfx_pool[0]
    for player in sfx_pool:
        if not player.playing:
            chosen = player
            break
    chosen.stream = sfx_streams[key]
    chosen.volume_db = volume_db
    chosen.pitch_scale = pitch * randf_range(0.96, 1.04)
    chosen.play()


## La capa de tensión sube con el miedo, la persecución y el ojo abierto;
## el ambiente baja un poco para dejarle sitio.
func _update_audio(delta: float) -> void:
    if music == null or music.stream == null:
        return
    var target: float = 0.0
    if game_mode == "play":
        target = fear / 100.0 * 0.75
        if enemy_alert:
            target += 0.55
        if current_room == 2 and watcher_open and not seal_acquired:
            target += 0.25
    tension_level = move_toward(tension_level, clampf(target, 0.0, 1.0), delta * 0.4)
    tension.volume_db = linear_to_db(maxf(tension_level, 0.001)) - 7.0
    var base_db: float = -14.0 - 5.0 * tension_level
    if game_mode == "dead":
        base_db = -26.0
    music.volume_db = move_toward(music.volume_db, base_db, delta * 12.0)


func _load_progress() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var data = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
    if data is Dictionary:
        identity_number = maxi(1, int(data.get("identity_number", 1)))
        new_humans = maxi(0, int(data.get("new_humans", 0)))
        reincarnations = maxi(0, int(data.get("reincarnations", 0)))
        has_pulse = bool(data.get("has_pulse", false))
        has_inner_flame = bool(data.get("has_inner_flame", false))
        ability_level = maxi(0, int(data.get("ability_level", 0)))
        remembered_rule = bool(data.get("remembered_rule", false))
        deaths = maxi(0, int(data.get("deaths", 0)))
        cleared = maxi(0, int(data.get("cleared", 0)))

func _save_progress() -> void:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file != null:
        file.store_string(JSON.stringify({
            "identity_number": identity_number,
            "new_humans": new_humans,
            "reincarnations": reincarnations,
            "has_pulse": has_pulse,
            "has_inner_flame": has_inner_flame,
            "ability_level": ability_level,
            "remembered_rule": remembered_rule,
            "deaths": deaths,
            "cleared": cleared
        }))


func _new_run() -> void:
    current_room = 0
    souls = 0
    max_hp = 100.0
    hp = max_hp
    fear = 0.0
    stamina = 100.0
    dash_cd = 0.0
    pulse_cd = 0.0
    damage_cd = 0.0
    elapsed = 0.0
    # Se empieza a oscuras: la antorcha se construye en la primera sala.
    torch_on = false
    has_wood = false
    has_torch = false
    matches = 0
    items_taken.clear()
    banished.clear()
    strike_cd = 0.0
    seal_acquired = false
    observed_rule = remembered_rule
    game_mode = "play"
    _enter_room()
    if remembered_rule:
        _say("Recuerdas la regla del Testigo de una vida anterior.", 4.0)
    else:
        _say("No recuerdas el origen del templo. Busca respuestas.", 4.0)


func _enter_room() -> void:
    _load_room_scene()
    player_pos = _marker("Jugador", Vector2(115.0, 359.0))
    player_dir = Vector2.RIGHT
    var default_enemy := Vector2(765.0, 358.0)
    if current_room == 1:
        default_enemy = Vector2(772.0, 472.0) # Ghoul de brasas
    elif current_room == 3:
        default_enemy = Vector2(773.0, 354.0) # Hechicero
    enemy_pos = _marker("Enemigo", default_enemy)
    wizard_cast_cd = 2.4
    fireballs.clear()
    enemy_home = enemy_pos
    enemy_prev_pos = enemy_pos
    enemy_facing = 3 # empiezan mirando hacia la entrada (izquierda)
    enemy_stun = 0.0
    enemy_alert = false
    room_elapsed = 0.0
    still_timer = 0.0
    dark_timer = 0.0
    letter_found = false
    collected = [false, false, false]
    ward_left = 0.0
    # La antorcha conserva su estado al cruzar la puerta.
    room_items.clear()
    for entry in ROOM_ITEMS.get(current_room, []):
        if not items_taken.has("%d:%s" % [current_room, entry[0]]):
            room_items.append({"kind": entry[0], "pos": _marker(entry[1], entry[2])})
    enemy_max = maxf(1.0, ENEMY_MAX_HP[current_room])
    enemy_hp = enemy_max
    enemy_hit_t = 0.0
    pulse_fx = -1.0
    strike_fx = 0.0
    float_fx.clear()
    dissolve_fx.clear()
    drops.clear()
    if current_room == 0 and not has_torch:
        _say("Oscuridad. Busca madera y fósforos para hacer una antorcha.", 4.5)
    else:
        _say(ROOM_WHISPERS[current_room], 4.5)


## Instancia rooms/sala_N.tscn bajo el dibujo del juego y lee sus datos.
func _load_room_scene() -> void:
    if room_node != null:
        remove_child(room_node)
        room_node.queue_free()
    room_node = ROOM_SCENES[current_room].instantiate()
    room_node.z_index = -1 # el suelo (TileMapLayer) queda bajo todo lo demás
    add_child(room_node)
    move_child(room_node, 0)
    obstacles.clear()
    for shape in room_node.find_children("*", "CollisionShape2D", true, false):
        var rect_shape := (shape as CollisionShape2D).shape as RectangleShape2D
        if rect_shape == null or (shape as CollisionShape2D).disabled:
            continue
        var center: Vector2 = (shape as Node2D).global_position - global_position
        obstacles.append(Rect2(center - rect_shape.size * 0.5, rect_shape.size))
    # Los objetos los dibuja este script, ordenados por profundidad con los
    # personajes; en el editor se ven y se mueven como Sprite2D normales.
    room_props.clear()
    var objetos: Node = room_node.get_node_or_null("Objetos")
    if objetos != null:
        (objetos as CanvasItem).visible = false
        for child in objetos.get_children():
            var sprite := child as Sprite2D
            if sprite == null or sprite.texture == null or not sprite.visible:
                continue
            var size: Vector2 = sprite.texture.get_size() * sprite.scale.abs()
            var anchor: Vector2 = sprite.global_position - global_position
            var top_left: Vector2 = anchor + sprite.offset * sprite.scale.abs()
            if sprite.centered:
                top_left -= size * 0.5
            room_props.append({
                "tex": sprite.texture, "rect": Rect2(top_left, size), "base": anchor.y,
                "shadow": bool(sprite.get_meta("sombra", true)), "light": bool(sprite.get_meta("luz", false)),
                "flip": sprite.flip_h,
            })
    relics = [_marker("Reliquia1", RELICS[0]), _marker("Reliquia2", RELICS[1]), _marker("Reliquia3", RELICS[2])]
    seal_pos = _marker("Sello", SEAL_POS)
    altar_pos = _marker("Altar", ALTAR_POS)
    book_pos = _marker("Libro", BOOK_POS)
    archive_pos = _marker("Lectura", ARCHIVE_POS)
    eye_pos = _marker("Ojo", EYE_POS)
    door_pos = _marker("Salida", DOOR_POS)


func _marker(marker_name: String, fallback: Vector2) -> Vector2:
    if room_node == null:
        return fallback
    var marker := room_node.get_node_or_null("Marcadores/" + marker_name) as Node2D
    return fallback if marker == null else marker.global_position - global_position


func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        var point: Vector2 = make_input_local(event).position
        _mobile_touch(event.index, point, event.pressed)
        return
    elif event is InputEventScreenDrag and event.index == mobile_finger:
        _mobile_update_axis(make_input_local(event).position)
        return
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        if game_mode in ["title", "inventory", "altar"]:
            _mobile_tap(make_input_local(event).position)
            return
        if game_mode == "play" and not touch_enabled:
            if not _torch_strike():
                _say("Enciende la antorcha (F) para golpear con fuego.", 1.8)
            return
    elif event is InputEventMouseMotion and game_mode in ["inventory", "altar"]:
        var slot: int = _inventory_slot_at(make_input_local(event).position) if game_mode == "inventory" else _altar_row_at(make_input_local(event).position)
        if slot >= 0:
            inventory_sel = slot
        return
    if not (event is InputEventKey):
        return
    if not event.pressed or event.echo:
        return
    var k: Key = event.keycode
    if game_mode == "title":
        if k == KEY_ENTER or k == KEY_KP_ENTER:
            _new_run()
        elif k == KEY_H:
            _open_defense()
    elif game_mode == "dead" or game_mode == "victory":
        if k == KEY_ENTER or k == KEY_KP_ENTER:
            _new_run()
        elif k == KEY_ESCAPE:
            game_mode = "title"
    elif game_mode == "altar":
        if k == KEY_1:
            _buy_upgrade(1)
        elif k == KEY_2:
            _buy_upgrade(2)
        elif k == KEY_ESCAPE or k == KEY_E:
            game_mode = "play"
            _sfx("interfaz", -12.0, 0.9)
    elif game_mode == "inventory":
        if k in [KEY_I, KEY_TAB, KEY_ESCAPE, KEY_E]:
            _close_inventory()
        elif k in [KEY_RIGHT, KEY_D]:
            inventory_sel = (inventory_sel + 1) % INVENTORY_SLOTS.size()
        elif k in [KEY_LEFT, KEY_A]:
            inventory_sel = (inventory_sel + INVENTORY_SLOTS.size() - 1) % INVENTORY_SLOTS.size()
        elif k in [KEY_DOWN, KEY_S, KEY_UP, KEY_W]:
            inventory_sel = (inventory_sel + 3) % INVENTORY_SLOTS.size()
    elif game_mode == "play":
        if k == KEY_E:
            _interact()
        elif k == KEY_F:
            _toggle_torch()
        elif k == KEY_I or k == KEY_TAB:
            _open_inventory()
        elif k == KEY_SPACE and dash_cd <= 0.0 and stamina >= 28.0:
            dash_left = 0.19
            dash_cd = 2.65
            stamina -= 28.0
        elif k == KEY_Q:
            _use_pulse()
        elif k == KEY_ESCAPE:
            game_mode = "title"
            _say("La partida se interrumpió. No ganaste nuevas almas.", 3.0)
    queue_redraw()


func _open_defense() -> void:
    get_tree().change_scene_to_file("res://scenes/defense.tscn")

func _mobile_touch(finger: int, at: Vector2, pressed: bool) -> void:
    if not pressed:
        if finger == mobile_finger:
            mobile_finger = -1
            mobile_axis = Vector2.ZERO
        queue_redraw()
        return
    if game_mode == "play" and at.x <= 325.0 and at.y >= 367.0:
        mobile_finger = finger
        _mobile_update_axis(at)
    else:
        _mobile_tap(at)
    queue_redraw()

func _mobile_update_axis(at: Vector2) -> void:
    mobile_axis = ((at - Vector2(135.0, 480.0)) / 68.0).limit_length(1.0)
    queue_redraw()

func _mobile_tap(at: Vector2) -> void:
    if game_mode == "title":
        if at.x >= 480.0 and at.y > 415.0:
            _open_defense()
        else:
            _new_run()
        return
    if game_mode == "dead" or game_mode == "victory":
        _new_run()
        return
    if game_mode == "altar":
        var row: int = _altar_row_at(at)
        if row >= 0:
            inventory_sel = row
            _buy_upgrade(row + 1)
        else:
            game_mode = "play"
            _sfx("interfaz", -12.0, 0.9)
        return
    if game_mode == "inventory":
        var slot: int = _inventory_slot_at(at)
        if slot >= 0:
            inventory_sel = slot
        else:
            _close_inventory()
        return
    if game_mode != "play":
        return
    if at.x > 834.0 and at.y < 98.0:
        game_mode = "title"
        mobile_axis = Vector2.ZERO
        mobile_finger = -1
        return
    if at.y < 100.0 and at.x > 560.0:
        # Tocar la zona del inventario de la barra superior lo abre.
        _open_inventory()
        return
    if at.y > 365.0 and at.x > 370.0:
        if at.x < 510.0:
            _interact()
        elif at.x < 660.0:
            _toggle_torch()
        elif at.x < 790.0:
            if dash_cd <= 0.0 and stamina >= 28.0:
                dash_left = 0.19
                dash_cd = 2.65
                stamina -= 28.0
        else:
            _use_pulse()
    queue_redraw()

func _draw_mobile_controls() -> void:
    if not touch_enabled:
        return
    if game_mode != "play":
        return
    # Joystick virtual: el dedo en la izquierda define un vector en vez de
    # modificar las teclas reales de escritorio o la IA original.
    draw_circle(Vector2(135, 480), 72.0, Color(0.10, 0.20, 0.28, 0.70))
    draw_arc(Vector2(135, 480), 72.0, 0.0, TAU, 48, SOUL, 3.0)
    draw_circle(Vector2(135, 480) + mobile_axis * 48.0, 26.0, Color(0.62, 0.81, 0.83, 0.68))
    var positions := [Vector2(440, 478), Vector2(585, 478), Vector2(725, 478), Vector2(865, 478)]
    var labels := ["E", "F", "DASH", "Q"]
    var icons := ["golpe" if has_torch and torch_on else "", "antorcha_encendida" if torch_on else "antorcha", "", "resonancia"]
    for i in range(4):
        var at: Vector2 = positions[i]
        draw_circle(at, 51.0, Color(0.09, 0.21, 0.27, 0.83))
        draw_arc(at, 51.0, 0.0, TAU, 36, SOUL, 2.0)
        if icons[i] != "" and (i != 1 or has_torch) and (i != 3 or has_pulse):
            draw_texture_rect(ICONS[icons[i]], Rect2(at - Vector2(24, 30), Vector2(48, 48)), false, Color(1, 1, 1, 0.9))
            draw_string(font, at + Vector2(-47, 38), labels[i], HORIZONTAL_ALIGNMENT_CENTER, 94, 14, CREAM)
        else:
            draw_string(font, at + Vector2(-47, 8), labels[i], HORIZONTAL_ALIGNMENT_CENTER, 94, 23, CREAM)
    draw_rect(Rect2(834, 16, 112, 72), Color(0.10, 0.22, 0.28, 0.85))
    draw_string(font, Vector2(840, 56), "MENÚ", HORIZONTAL_ALIGNMENT_CENTER, 100, 15, CREAM)


func _buy_upgrade(choice: int) -> void:
    if choice == 2:
        _buy_inner_flame()
        return
    if choice != 1:
        return
    if has_pulse:
        _say("Ya adquiriste Resonancia. Nivel actual: %d." % ability_level)
        return
    # Precio y balance de esta prueba vertical: PROVISIONALES, no canon definitivo.
    var price: int = 14
    if souls < price:
        _say("Necesitas 14 fragmentos de alma.")
        return
    souls -= price
    has_pulse = true
    ability_level = 0
    _save_progress()
    _sfx("sello", -6.0, 1.25)
    _say("Adquiriste Resonancia nivel 0. Pulsa Q para utilizarla.", 4.0)


const INNER_FLAME_PRICE := 10
func _buy_inner_flame() -> void:
    if has_inner_flame:
        _say("La llama interior ya arde en ti.")
        return
    if souls < INNER_FLAME_PRICE:
        _say("Necesitas %d fragmentos de alma." % INNER_FLAME_PRICE)
        _sfx("toque", -10.0)
        return
    souls -= INNER_FLAME_PRICE
    has_inner_flame = true
    _save_progress()
    _sfx("fosforo", -6.0, 0.8)
    _say("Adquiriste LLAMA INTERIOR: enciendes la antorcha sin fósforos.", 4.0)


func _use_pulse() -> void:
    if not has_pulse:
        _say("Todavía no adquiriste Resonancia en el altar.", 2.0)
        return
    if pulse_cd > 0.0 or stamina < 24.0:
        _say("Resonancia necesita energía o tiempo de recuperación.", 2.0)
        return
    pulse_cd = 8.0
    stamina -= 24.0
    pulse_fx = 0.0
    _sfx("resonancia", -5.0)
    if _enemy_active() and player_pos.distance_to(enemy_pos) < 220.0:
        enemy_stun = 1.6 + 0.5 * float(ability_level)
        if player_pos.distance_to(enemy_pos) < PULSE_RADIUS + 12.0:
            _damage_enemy(30.0 + 10.0 * float(ability_level))
        else:
            _say("La onda la aturde, pero está lejos para dañarla.", 2.2)
    else:
        _say("Una vibración recorre la piedra.", 1.6)


## Antorcha: F la enciende (gasta un fósforo salvo con Llama interior) o la apaga.
func _toggle_torch() -> void:
    if not has_torch:
        if has_wood:
            _say("Te faltan fósforos para prender la madera.", 2.2)
        elif matches > 0:
            _say("Tienes fósforos, pero nada que arda. Busca madera.", 2.2)
        else:
            _say("No llevas luz. Busca madera y fósforos.", 2.2)
        _sfx("toque", -12.0)
        return
    if torch_on:
        torch_on = false
        _sfx("apagar", -9.0)
        _say("Antorcha apagada.", 1.2)
        return
    if has_inner_flame:
        torch_on = true
        _sfx("fosforo", -8.0, 1.3)
        _say("La llama interior prende la antorcha.", 1.6)
        return
    if matches <= 0:
        _say("No te quedan fósforos. Búscalos o compra la Llama interior.", 2.8)
        _sfx("toque", -10.0)
        return
    matches -= 1
    torch_on = true
    _sfx("fosforo", -7.0)
    _say("Antorcha encendida. Fósforos: %d." % matches, 1.8)


func _take_item(i: int) -> void:
    var item: Dictionary = room_items[i]
    var kind: String = item["kind"]
    items_taken["%d:%s" % [current_room, kind]] = true
    room_items.remove_at(i)
    var label: String = ""
    if kind == "madera":
        has_wood = true
        label = "+MADERA"
        _say("Madera seca y una tira de tela: el cuerpo de una antorcha.", 3.0)
    else:
        var amount: int = MATCHES_FIRST_BOX if matches == 0 and not has_torch else MATCHES_REFILL
        matches += amount
        label = "+%d FÓSFOROS" % amount
        _say("Caja de fósforos: +%d. Llevas %d." % [amount, matches], 3.0)
    pickup_fx.append({"pos": item["pos"], "t": 0.0, "text": label, "color": Color("#f0c98a")})
    _sfx("objeto", -6.0)
    _try_craft()


func _try_craft() -> void:
    if has_torch or not has_wood or matches <= 0:
        return
    has_wood = false
    has_torch = true
    _sfx("interfaz", -8.0, 0.8)
    _say("Construiste una ANTORCHA. Pulsa F para encenderla (gasta 1 fósforo).", 4.5)


func _open_inventory() -> void:
    if game_mode != "play":
        return
    game_mode = "inventory"
    mobile_axis = Vector2.ZERO
    mobile_finger = -1
    # Selecciona el primer objeto que se tiene.
    for i in range(INVENTORY_SLOTS.size()):
        if _slot_owned(i):
            inventory_sel = i
            break
    _sfx("interfaz", -9.0)


func _close_inventory() -> void:
    game_mode = "play"
    _sfx("interfaz", -12.0, 0.9)


func _slot_owned(i: int) -> bool:
    match INVENTORY_SLOTS[i][0]:
        "madera":
            return has_wood
        "fosforos":
            return matches > 0
        "antorcha":
            return has_torch
        "llama_interior":
            return has_inner_flame
        "golpe":
            return has_torch
        "resonancia":
            return has_pulse
    return false


func _inventory_slot_rect(i: int) -> Rect2:
    return Rect2(222.0 + float(i % 3) * 180.0, 214.0 + float(i / 3) * 120.0, 156.0, 104.0)


func _inventory_slot_at(at: Vector2) -> int:
    for i in range(INVENTORY_SLOTS.size()):
        if _inventory_slot_rect(i).has_point(at):
            return i
    return -1


func _altar_row_rect(i: int) -> Rect2:
    return Rect2(190.0, 262.0 + float(i) * 96.0, 580.0, 86.0)


func _altar_row_at(at: Vector2) -> int:
    for i in range(2):
        if _altar_row_rect(i).has_point(at):
            return i
    return -1


# ---------------------------------------------------------------- COMBATE
func _enemy_active() -> bool:
    return current_room in [1, 2, 3] and not banished.has(current_room)


func _enemy_kind() -> String:
    return "ghoul" if current_room == 1 else ("testigo" if current_room == 2 else "hechicero")


## Debilidades: el Testigo solo con el ojo cerrado; el Hechicero solo
## mientras carga el conjuro; el Ghoul siempre.
func _enemy_vulnerable() -> bool:
    match current_room:
        2:
            return not watcher_open
        3:
            return enemy_alert and wizard_cast_cd < WIZARD_CHARGE
    return true


func _damage_enemy(amount: float) -> bool:
    var head := enemy_pos + Vector2(randf_range(-6.0, 6.0) + 30.0, -48.0)
    if not _enemy_vulnerable():
        float_fx.append({"pos": head, "text": "INMUNE", "color": Color("#b4bba8"), "t": 0.0})
        _sfx("inmune", -8.0)
        if current_room == 2:
            _say("Con el ojo abierto es piedra. Golpéalo cuando lo cierre.", 2.6)
        else:
            _say("Su escudo solo cae mientras carga el conjuro.", 2.6)
        return false
    enemy_hp -= amount
    enemy_hit_t = 0.2
    float_fx.append({"pos": head, "text": "-%d" % int(amount), "color": Color("#ffd36b"), "t": 0.0})
    _sfx("impacto", -6.0)
    if enemy_hp <= 0.0:
        _banish_enemy()
    return true


## A 0 de vida la entidad se disuelve y suelta almas. Vuelve si mueres.
func _banish_enemy() -> void:
    var kind: String = _enemy_kind()
    banished[current_room] = true
    dissolve_fx.append({"pos": enemy_pos, "kind": kind, "facing": enemy_facing, "frame": _enemy_frame(kind), "t": 0.0})
    drops.append({"pos": enemy_pos})
    fireballs.clear()
    enemy_stun = 0.0
    enemy_alert = false
    shake = maxf(shake, 0.25)
    _sfx("destierro", -4.0)
    _say("Entidad DESTERRADA. Recoge sus almas. Volverá si mueres.", 3.8)


## Golpe de antorcha: arco de fuego delante del personaje.
func _torch_strike() -> bool:
    if not (has_torch and torch_on):
        return false
    if strike_cd > 0.0 or stamina < 10.0:
        return true
    strike_cd = 0.6
    stamina -= 10.0
    strike_fx = 0.25
    strike_dir = player_dir.normalized() if player_dir.length() > 0.1 else Vector2.RIGHT
    visual_interaction_left = 0.24
    _sfx("golpe", -7.0)
    if _enemy_active():
        var to := enemy_pos - player_pos
        if to.length() < STRIKE_RANGE + 10.0 and (to.length() < 24.0 or to.normalized().dot(strike_dir) > 0.25):
            if _damage_enemy(STRIKE_DAMAGE):
                enemy_stun = maxf(enemy_stun, 0.3)
                var pushed := enemy_pos + to.normalized() * 18.0
                if not _is_blocked(pushed):
                    enemy_pos = pushed
    return true


func _interact() -> void:
    visual_interaction_left = 0.24 # solo dibujo; no cambia la interacción
    if current_room == 2 and not seal_acquired and player_pos.distance_to(seal_pos) < 60.0:
        seal_acquired = true
        remembered_rule = true
        observed_rule = true
        if has_pulse:
            ability_level = maxi(ability_level, 1)
        _save_progress()
        _say("SELLO RECUPERADO. El Testigo se inmoviliza cuando tú te detienes.", 5.0)
        _sfx("sello", -4.0)
        return
    if current_room == 1 and player_pos.distance_to(altar_pos) < 64.0:
        game_mode = "altar"
        inventory_sel = 0
        _sfx("interfaz", -8.0)
        return
    if current_room == 3 and player_pos.distance_to(archive_pos) < 72.0:
        letter_found = true
        _say("Carta: 'He regresado. El cuerpo cambia, pero recuerdo sus ojos.'", 5.0)
        _sfx("libro", -5.0)
        return
    if player_pos.distance_to(door_pos) < 74.0:
        if _room_ready():
            _go_through_door()
        else:
            _say(_required_clue(), 3.2)
        return
    if _torch_strike():
        return
    _sfx("toque", -10.0)
    _say("La piedra no responde a tu tacto.", 1.3)

func _go_through_door() -> void:
    if current_room == 4:
        _win_run()
    else:
        current_room += 1
        _enter_room()
        _sfx("puerta", -6.0)


## La puerta se cruza al tocarla (sin pulsar E). Si sigue sellada, avisa.
func _check_door_touch(dt: float) -> void:
    door_msg_cd = maxf(0.0, door_msg_cd - dt)
    if player_pos.distance_to(door_pos) >= DOOR_TOUCH:
        return
    if _room_ready():
        _go_through_door()
    elif door_msg_cd <= 0.0:
        door_msg_cd = 3.0
        _say(_required_clue(), 3.0)
        _sfx("toque", -10.0)


func _room_ready() -> bool:
    # Una misión principal en el primer piso: recuperar el sello del Testigo.
    if current_room == 2 and not seal_acquired:
        return false
    return true

func _required_clue() -> String:
    if current_room == 2 and not seal_acquired:
        return "El pórtico exige el sello de la estatua. Está al fondo."
    return "La puerta todavía no te reconoce."


func _relic_count() -> int:
    var count: int = 0
    for picked in collected:
        if picked:
            count += 1
    return count


func _win_run() -> void:
    cleared += 1
    _save_progress()
    game_mode = "victory"
    _sfx("sello", -4.0, 0.8)

func _lose_run() -> void:
    deaths += 1
    souls = 0
    if randf() < 0.5:
        # Exactamente dos posibilidades equiprobables (regla canónica).
        soul_fate = "retorno"
        reincarnations += 1
        ability_level = 0
        # Conservar identidad, conocimientos y propiedad de la habilidad.
    else:
        soul_fate = "absorcion"
        new_humans += 1
        identity_number += 1
        has_pulse = false
        has_inner_flame = false
        ability_level = 0
        remembered_rule = false
        # Una persona nueva, sin la memoria de la anterior.
    _save_progress()
    game_mode = "dead"
    _sfx("muerte", -3.0)


func _say(message: String, duration: float = 2.8) -> void:
    toast = message
    toast_left = duration


func _controls_axis() -> Vector2:
    var v := Vector2.ZERO
    if Input.is_physical_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
        v.y -= 1.0
    if Input.is_physical_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
        v.y += 1.0
    if Input.is_physical_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
        v.x -= 1.0
    if Input.is_physical_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
        v.x += 1.0
    return (v + mobile_axis).limit_length(1.0)


## Choca con un objeto de la sala (no con los muros): para el polvo del impacto.
func _hits_obstacle(at: Vector2) -> bool:
    for rect in obstacles:
        if rect.grow(15.5).has_point(at):
            return true
    return false


func _is_blocked(at: Vector2) -> bool:
    if at.x < 63.0 or at.x > 895.0 or at.y < 155.0 or at.y > 552.0:
        return true
    for rect in obstacles:
        if rect.grow(15.5).has_point(at):
            return true
    return false


func _process(delta: float) -> void:
    elapsed += delta
    toast_left = maxf(0.0, toast_left - delta)
    visual_interaction_left = maxf(0.0, visual_interaction_left - delta)
    bump_left = maxf(0.0, bump_left - delta)
    souls_flash = maxf(0.0, souls_flash - delta)
    for fx in pickup_fx:
        fx["t"] = float(fx["t"]) + delta
    pickup_fx = pickup_fx.filter(func(fx): return float(fx["t"]) < 1.1)
    for fx in float_fx:
        fx["t"] = float(fx["t"]) + delta
    float_fx = float_fx.filter(func(fx): return float(fx["t"]) < 0.9)
    for fx in dissolve_fx:
        fx["t"] = float(fx["t"]) + delta
    dissolve_fx = dissolve_fx.filter(func(fx): return float(fx["t"]) < 1.4)
    enemy_hit_t = maxf(0.0, enemy_hit_t - delta)
    strike_fx = maxf(0.0, strike_fx - delta)
    if pulse_fx >= 0.0:
        pulse_fx += delta
        if pulse_fx > 0.6:
            pulse_fx = -1.0
    if game_mode == "play":
        _update_play(delta)
        _track_enemy_visual(delta)
    # Sacudida de pantalla tras un golpe (todo el lienzo; decae rápido).
    shake = maxf(0.0, shake - delta * 2.4)
    position = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake * 9.0 if shake > 0.0 else Vector2.ZERO
    _update_audio(delta)
    queue_redraw()


func _update_play(dt: float) -> void:
    room_elapsed += dt
    dash_cd = maxf(0.0, dash_cd - dt)
    pulse_cd = maxf(0.0, pulse_cd - dt)
    strike_cd = maxf(0.0, strike_cd - dt)
    damage_cd = maxf(0.0, damage_cd - dt)
    dash_left = maxf(0.0, dash_left - dt)
    enemy_stun = maxf(0.0, enemy_stun - dt)
    stamina = minf(100.0, stamina + 16.0 * dt)
    var move: Vector2 = _controls_axis()
    player_moving = move.length_squared() > 0.001
    if player_moving:
        player_dir = move
    var speed: float = 157.0 if dash_left <= 0.0 else 480.0
    if player_moving:
        var nx := Vector2(player_pos.x + move.x * speed * dt, player_pos.y)
        var blocked_x: bool = absf(move.x) > 0.3 and _hits_obstacle(nx)
        if not _is_blocked(nx):
            player_pos.x = nx.x
        var ny := Vector2(player_pos.x, player_pos.y + move.y * speed * dt)
        var blocked_y: bool = absf(move.y) > 0.3 and _hits_obstacle(ny)
        if not _is_blocked(ny):
            player_pos.y = ny.y
        if (blocked_x or blocked_y) and bump_left <= 0.0:
            bump_left = 0.35
            bump_at = player_pos + Vector2(signf(move.x) * 10.0 if blocked_x else 0.0, 2.0)
        # Pasos: tres pisadas que se alternan, más rápidas al esquivar.
        step_t -= dt
        if step_t <= 0.0:
            step_t = 0.33 if dash_left <= 0.0 else 0.12
            _sfx("paso_%d" % (step_i % 3 + 1), -17.0)
            step_i += 1
    else:
        step_t = 0.06

    # Las almas se recogen al tocarlas.
    for i in range(relics.size()):
        if not collected[i] and player_pos.distance_to(relics[i]) < 30.0:
            _collect_relic(i)
    for i in range(room_items.size() - 1, -1, -1):
        if player_pos.distance_to(room_items[i]["pos"]) < 30.0:
            _take_item(i)
    _check_door_touch(dt)
    if game_mode != "play":
        return # se ganó la partida al cruzar la última puerta
    for i in range(drops.size() - 1, -1, -1):
        if player_pos.distance_to(drops[i]["pos"]) < 32.0:
            souls += BANISH_SOULS
            souls_flash = 0.8
            pickup_fx.append({"pos": drops[i]["pos"], "t": 0.0, "text": "+%d" % BANISH_SOULS})
            drops.remove_at(i)
            _sfx("alma", -5.0)

    watcher_open = fmod(room_elapsed, 6.0) < 3.25
    if current_room == 2:
        # Aviso justo: el ojo tiembla y cruje 0,6 s antes de abrirse.
        var phase: float = fmod(room_elapsed, 6.0)
        if phase >= 5.4 and not watcher_warned:
            watcher_warned = true
            _sfx("aviso", -9.0)
        if watcher_open and not watcher_was_open:
            watcher_warned = false
            _sfx("ojo", -7.0)
        watcher_was_open = watcher_open
    if _enemy_active():
        _update_enemy(dt)
        var near: float = player_pos.distance_to(enemy_pos)
        if near < 185.0:
            fear += dt * (8.0 if watcher_open else 2.0)
    else:
        # A oscuras el miedo se va más despacio.
        fear -= (4.0 if torch_on else 1.2) * dt
    fear = clampf(fear, 0.0, 100.0)
    if fear >= 100.0:
        hp -= dt * 5.0
    if hp <= 0.0:
        _lose_run()

func _collect_relic(i: int) -> void:
    collected[i] = true
    souls += 7
    fear = maxf(0.0, fear - 8.0)
    souls_flash = 0.8
    pickup_fx.append({"pos": relics[i], "t": 0.0})
    _say("Fragmento reunido: +7 almas. Es la moneda del templo.", 2.5)
    _sfx("alma", -5.0)


## Golpe recibido: sacudida, destello y sonido. No cambia el daño.
func _on_hurt() -> void:
    shake = 0.45
    _sfx("dano", -4.0)


func _update_enemy(dt: float) -> void:
    # PROVISIONAL: only the Witness rule is part of this vertical slice.
    # Other behaviors are simple encounter prototypes, not narrative canon.
    var d: float = enemy_pos.distance_to(player_pos)
    enemy_alert = false
    if current_room == 1:
        # Fire-lit hunter: darkness breaks its pursuit in this test encounter.
        enemy_alert = torch_on and d < 350.0
        if enemy_alert and enemy_stun <= 0.0:
            var wanted := enemy_pos.move_toward(player_pos, 132.0 * dt)
            if not _is_blocked(wanted):
                enemy_pos = wanted
        elif not enemy_alert and enemy_stun <= 0.0:
            enemy_pos = enemy_pos.move_toward(enemy_home, 48.0 * dt)
    elif current_room == 2:
        # Witness: observes motion with its eyes open. Stop moving to survive.
        enemy_alert = watcher_open and player_moving and d < 490.0
        if enemy_alert and enemy_stun <= 0.0:
            var wanted := enemy_pos.move_toward(player_pos, 169.0 * dt)
            if not _is_blocked(wanted):
                enemy_pos = wanted
            if not observed_rule:
                observed_rule = true
                remembered_rule = true
                _save_progress()
                _say("Observación: al detenerte, el Testigo también se detiene.", 4.5)
    elif current_room == 3:
        # Wizard: warded while the player's torch is off. Provisional mechanic.
        enemy_alert = torch_on and d < 390.0
        wizard_cast_cd = maxf(0.0, wizard_cast_cd - dt)
        if enemy_alert and wizard_cast_cd <= 0.0 and enemy_stun <= 0.0:
            var direction := (player_pos - enemy_pos).normalized()
            fireballs.append({"pos": enemy_pos + Vector2(0.0, -20.0), "vel": direction * 215.0, "life": 2.2})
            wizard_cast_cd = 2.9
            _say("El hechicero responde a tu luz.", 1.6)
            _sfx("conjuro", -8.0)
        for i in range(fireballs.size() - 1, -1, -1):
            var ball: Dictionary = fireballs[i]
            var p: Vector2 = ball["pos"] + ball["vel"] * dt
            ball["pos"] = p
            ball["life"] = float(ball["life"]) - dt
            if p.distance_to(player_pos) < 23.0:
                if damage_cd <= 0.0:
                    hp -= 25.0
                    fear = minf(100.0, fear + 13.0)
                    damage_cd = 1.1
                    _say("El conjuro te alcanza. Busca cobertura.", 2.6)
                    _on_hurt()
                fireballs.remove_at(i)
            elif float(ball["life"]) <= 0.0 or _is_blocked(p):
                fireballs.remove_at(i)
            else:
                fireballs[i] = ball
    if current_room in [1, 2] and enemy_alert and enemy_stun <= 0.0:
        if enemy_pos.distance_to(player_pos) < 31.0 and damage_cd <= 0.0:
            hp -= 33.0 if current_room == 1 else 42.0
            fear = minf(100.0, fear + 21.0)
            damage_cd = 1.5
            var away := (player_pos - enemy_pos).normalized()
            if away == Vector2.ZERO:
                away = Vector2.LEFT
            var escape := player_pos + away * 65.0
            if not _is_blocked(escape):
                player_pos = escape
            _say("La criatura te ha herido. Descubre su regla.", 3.0)
            _on_hurt()


func _draw() -> void:
    # El fondo lo pone la escena de la sala (está por debajo).
    if room_node == null:
        draw_rect(Rect2(0, 0, W, H), BG)
    elif game_mode == "title":
        # En el menú se ve la sala completa, con sus objetos, detrás del panel.
        var objetos: Node = room_node.get_node_or_null("Objetos")
        if objetos != null:
            (objetos as CanvasItem).visible = true
    _draw_background()
    if game_mode == "title":
        _draw_title()
        return
    _draw_room()
    _draw_topbar()
    _draw_footer()
    if toast_left > 0.0:
        _draw_toast()
    if game_mode == "altar":
        _draw_altar_overlay()
    elif game_mode == "inventory":
        _draw_inventory_overlay()
    elif game_mode == "dead":
        _draw_end_overlay(false)
    elif game_mode == "victory":
        _draw_end_overlay(true)
    _draw_mobile_controls()


func _draw_background() -> void:
    for i in range(0, 14):
        var px: float = float(i * 73 + 19)
        var py: float = 54.0 + sin(float(i) * 1.67) * 24.0
        draw_circle(Vector2(px, py), 1.0 + float(i % 3), Color(0.50, 0.64, 0.72, 0.20))


func _draw_room() -> void:
    # El suelo y los muros los dibuja la escena de la sala (TileMapLayer).
    _draw_room_depth()
    _draw_prop_shadows()
    # Nuevos efectos ambientales; no forman parte de colisiones ni IA.
    _draw_visual_atmosphere()
    # Objetos a ras de suelo: siempre por debajo de personajes y estatuas.
    _draw_door()
    if current_room == 2:
        _draw_seal(seal_pos)
        _draw_watcher_eye(eye_pos)
    for i in range(relics.size()):
        _draw_corpse(relics[i], current_room * 3 + i)
    for i in range(relics.size()):
        if not collected[i]:
            _draw_relic(relics[i], i)
    for item in room_items:
        _draw_item(item)
    for i in range(drops.size()):
        _draw_relic(drops[i]["pos"], 7 + i)
    _draw_depth_sorted()
    _draw_dissolve_fx()
    if current_room == 3:
        _draw_fireballs()
    _draw_lighting()
    _draw_strike_fx()
    _draw_pulse_fx()
    _draw_pickup_fx()
    _draw_float_fx()
    if damage_cd > 0.0:
        # Destello rojo que se apaga durante la invulnerabilidad.
        draw_rect(ARENA, Color(0.75, 0.08, 0.14, 0.16 * clampf(damage_cd / 1.5, 0.0, 1.0) ** 2))
    _draw_object_labels()


## Profundidad cenital: la luz cae desde arriba. El muro del fondo muestra
## su cara (más oscura abajo) y proyecta sombra sobre el suelo; los muros
## laterales y el frontal se ven por su remate, con un borde iluminado.
const WALL_BACK := Rect2(40, 122, 880, 36) # cara visible del muro del fondo
const WALL_LEFT_X := 67.0
const WALL_RIGHT_X := 893.0
const WALL_FRONT_Y := 552.0
func _draw_room_depth() -> void:
    var shade := Color(0.01, 0.015, 0.03)
    var floor_l: float = WALL_LEFT_X
    var floor_r: float = WALL_RIGHT_X
    # Cara del muro del fondo: luz arriba, sombra al pie.
    _vgradient(Rect2(floor_l - 19.0, WALL_BACK.position.y, floor_r - floor_l + 38.0, WALL_BACK.size.y), Color(1.0, 0.95, 0.82, 0.07), Color(shade, 0.34))
    draw_rect(Rect2(floor_l - 19.0, WALL_BACK.position.y, floor_r - floor_l + 38.0, 2.0), Color(0.85, 0.86, 0.74, 0.22))
    # Sombra que el muro del fondo proyecta sobre el suelo.
    _vgradient(Rect2(floor_l, WALL_BACK.end.y, floor_r - floor_l, 30.0), Color(shade, 0.42), Color(shade, 0.0))
    # Muros laterales: remate iluminado y oclusión en la base.
    for side in [-1.0, 1.0]:
        var edge: float = floor_l if side < 0.0 else floor_r
        var x0: float = edge if side < 0.0 else edge - 16.0
        _hgradient(Rect2(x0, WALL_BACK.end.y, 16.0, WALL_FRONT_Y - WALL_BACK.end.y), Color(shade, 0.26 if side < 0.0 else 0.0), Color(shade, 0.0 if side < 0.0 else 0.26))
        draw_rect(Rect2(edge - (2.0 if side < 0.0 else 0.0), WALL_BACK.position.y, 2.0, WALL_FRONT_Y - WALL_BACK.position.y + 23.0), Color(0.80, 0.82, 0.70, 0.16))
    # Muro frontal: se ve desde arriba, así que solo su remate recibe luz.
    _vgradient(Rect2(floor_l, WALL_FRONT_Y - 12.0, floor_r - floor_l, 12.0), Color(shade, 0.0), Color(shade, 0.18))
    draw_rect(Rect2(floor_l - 19.0, WALL_FRONT_Y, floor_r - floor_l + 38.0, 2.0), Color(0.82, 0.84, 0.72, 0.24))
    draw_rect(Rect2(floor_l - 19.0, WALL_FRONT_Y + 2.0, floor_r - floor_l + 38.0, 21.0), Color(shade, 0.22))


func _vgradient(rect: Rect2, top: Color, bottom: Color) -> void:
    draw_polygon(PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]),
        PackedColorArray([top, top, bottom, bottom]))


func _hgradient(rect: Rect2, left: Color, right: Color) -> void:
    draw_polygon(PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]),
        PackedColorArray([left, right, right, left]))


## [LUZ] Penumbra con luces dinámicas. Rejilla de vértices con oscuridad
## interpolada: el personaje lleva su luz (menor con la linterna apagada);
## braseros, almas, Ghoul, conjuros y la salida abierta iluminan su entorno.
## Nunca llega al negro: la sala siempre se lee (guía de estilo).
const LIGHT_CELL := 24.0
const LIGHT_CELL_MOBILE := 32.0 # rejilla más gruesa en móvil: menos coste por fotograma
func _lights() -> Array:
    var list: Array = [] # [pos, radio, intensidad]
    # Sin antorcha encendida solo se ve un círculo corto alrededor.
    list.append([player_pos + Vector2(0.0, -20.0), 205.0 if torch_on else 110.0, 1.0 if torch_on else 0.85])
    for item in room_items:
        list.append([item["pos"], 62.0, 0.5])
    for drop in drops:
        list.append([drop["pos"], 80.0, 0.6])
    for prop in room_props:
        if prop["light"]:
            var rect: Rect2 = prop["rect"]
            var flicker: float = 0.92 + 0.08 * sin(elapsed * 9.0 + rect.position.x)
            list.append([rect.get_center(), 130.0 * flicker, 0.85])
    for i in range(relics.size()):
        if not collected[i]:
            list.append([relics[i], 70.0, 0.55])
    if _enemy_active():
        # Las amenazas siempre se distinguen (juego limpio); el Ghoul arde.
        list.append([enemy_pos + Vector2(0.0, -24.0), 120.0 if current_room == 1 else 70.0, 0.8 if current_room == 1 else 0.45])
    for ball in fireballs:
        list.append([ball["pos"], 85.0, 0.9])
    if _room_ready():
        list.append([door_pos + Vector2(20.0, 0.0), 95.0, 0.6])
    if current_room == 1:
        list.append([altar_pos, 85.0, 0.6])
    return list


func _draw_lighting() -> void:
    if torch_on:
        # Tono cálido de la linterna alrededor del personaje.
        for r in range(4, 0, -1):
            draw_circle(player_pos + Vector2(0, -20), float(r) * 34.0, Color(1.0, 0.78, 0.45, 0.018))
    var lights: Array = _lights()
    var base_dark: float = 0.50 if torch_on else 0.68
    var fear_edge: float = fear / 100.0 * 0.28
    var cell: float = LIGHT_CELL_MOBILE if touch_enabled else LIGHT_CELL
    var cols: int = int(ceil(ARENA.size.x / cell)) + 1
    var rows: int = int(ceil(ARENA.size.y / cell)) + 1
    var center: Vector2 = ARENA.get_center()
    var alpha: PackedFloat32Array = PackedFloat32Array()
    alpha.resize(cols * rows)
    for r in range(rows):
        for c in range(cols):
            var p := ARENA.position + Vector2(c, r) * cell
            var lit: float = 0.0
            for light in lights:
                var d: float = p.distance_to(light[0])
                if d < light[1]:
                    lit = maxf(lit, pow(1.0 - d / light[1], 1.4) * light[2])
            var edge: float = clampf((p - center).length() / (ARENA.size.x * 0.55) - 0.35, 0.0, 1.0)
            alpha[r * cols + c] = clampf(base_dark * (1.0 - lit) + fear_edge * edge, 0.0, 0.85)
    var tint := Color(0.01, 0.015, 0.035)
    for r in range(rows - 1):
        for c in range(cols - 1):
            var a0: float = alpha[r * cols + c]
            var a1: float = alpha[r * cols + c + 1]
            var a2: float = alpha[(r + 1) * cols + c + 1]
            var a3: float = alpha[(r + 1) * cols + c]
            if a0 + a1 + a2 + a3 < 0.01:
                continue
            var p := ARENA.position + Vector2(c, r) * cell
            draw_polygon(
                PackedVector2Array([p, p + Vector2(cell, 0), p + Vector2(cell, cell), p + Vector2(0, cell)]),
                PackedColorArray([Color(tint, a0), Color(tint, a1), Color(tint, a2), Color(tint, a3)]))


## Destello al recoger un alma: anillo que se expande y "+7" que asciende.
func _draw_pickup_fx() -> void:
    for fx in pickup_fx:
        var t: float = float(fx["t"])
        var p: Vector2 = fx["pos"]
        var a: float = clampf(1.0 - t / 1.1, 0.0, 1.0)
        draw_arc(p + Vector2(0, -8), 10.0 + t * 46.0, 0.0, TAU, 32, Color(0.75, 0.93, 1.0, a * 0.8), 2.0)
        for k in range(6):
            var ang: float = float(k) / 6.0 * TAU + t * 2.0
            draw_circle(p + Vector2(cos(ang), sin(ang) * 0.6) * (8.0 + t * 30.0) + Vector2(0, -10 - t * 14.0), 2.0 * a, Color(0.85, 0.97, 1.0, a))
        var label: String = fx.get("text", "+7")
        var tone: Color = fx.get("color", Color(0.75, 0.93, 1.0))
        draw_string(font, p + Vector2(-60, -30 - t * 26.0), label, HORIZONTAL_ALIGNMENT_CENTER, 120, 16, Color(tone.r, tone.g, tone.b, a))


## Sombras de contacto de los objetos de la sala (antes horneadas en el PNG)
## y halo vivo de los braseros.
func _draw_prop_shadows() -> void:
    for prop in room_props:
        var rect: Rect2 = prop["rect"]
        if prop["shadow"]:
            _draw_soft_shadow(Vector2(rect.get_center().x, float(prop["base"]) - 3.0), rect.size.x * 0.6, 1.1)
        if prop["light"]:
            var flicker: float = 0.5 + 0.5 * sin(elapsed * 7.0 + rect.position.x) * sin(elapsed * 2.3)
            var c := Vector2(rect.get_center().x, rect.position.y + rect.size.y * 0.35)
            for r in range(4, 0, -1):
                draw_circle(c, 10.0 + float(r) * 7.0, Color(1.0, 0.78, 0.40, 0.03 + 0.012 * flicker))


## [VISUAL UPGRADE] Ordenación por profundidad: objetos de la sala, personajes,
## altar y libro se dibujan de arriba abajo según la y de su base.
func _draw_depth_sorted() -> void:
    var items: Array = [] # [y_base, tipo, dato]
    items.append([player_pos.y, "player", null])
    if _enemy_active():
        items.append([enemy_pos.y, "enemy", null])
    if current_room == 1:
        items.append([altar_pos.y + 22.0, "altar", null])
    if current_room == 3:
        items.append([book_pos.y + 37.0, "book", null]) # justo después de la mesa
    for i in range(room_props.size()):
        items.append([float(room_props[i]["base"]), "prop", i])
    items.sort_custom(func(x, y): return x[0] < y[0])
    for item in items:
        match item[1]:
            "player":
                _draw_player()
            "enemy":
                _draw_enemy()
            "altar":
                _draw_altar(altar_pos)
            "book":
                _draw_letter(book_pos)
            "prop":
                var prop: Dictionary = room_props[item[2]]
                _draw_texture_flipped(prop["tex"], prop["rect"], prop["flip"])


func _draw_object_labels() -> void:
    # Etiquetas por encima de todo para que nunca queden tapadas.
    if current_room == 1 and player_pos.distance_to(altar_pos) < 150.0:
        _label_center("INTERCAMBIO [E]", altar_pos + Vector2(0.0, 46.0), CREAM)
    if current_room == 3 and not letter_found and player_pos.distance_to(archive_pos) < 150.0:
        _label_center("LEER CARTA [E]", archive_pos + Vector2(0.0, 30.0), CREAM)
    if current_room == 2 and not seal_acquired:
        _label_center("SELLO [E]", seal_pos + Vector2(0.0, 56.0), Color("#e2c48a"))
    if _enemy_active():
        _draw_enemy_health()


func _label_center(msg: String, at: Vector2, color: Color) -> void:
    var size: int = 12
    var width: float = font.get_string_size(msg, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
    var box := Rect2(at.x - width * 0.5 - 6.0, at.y - 12.0, width + 12.0, 17.0)
    draw_rect(box, Color(0.03, 0.05, 0.06, 0.72))
    draw_string(font, Vector2(box.position.x + 6.0, at.y), msg, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


## [VISUAL UPGRADE] Puntos luminosos ligeros: no modifican colisiones ni reglas.
func _draw_visual_atmosphere() -> void:
    var amount: int = 13
    for i in range(amount):
        var seed_value: float = float(i * 71 + current_room * 109)
        var x_pos: float = 92.0 + fmod(seed_value * 3.7, 775.0)
        var y_pos: float = 182.0 + fmod(seed_value * 1.9 + sin(elapsed * 0.4 + seed_value) * 8.0, 349.0)
        var intensity: float = 0.11 + 0.06 * sin(elapsed * 1.3 + seed_value)
        draw_circle(Vector2(x_pos, y_pos), 1.0, Color(0.85, 0.78, 0.60, intensity))


## Elipse rellena (sombras, halos de suelo): círculo aplastado en vertical.
func _draw_ellipse(center: Vector2, radius_x: float, radius_y: float, color: Color) -> void:
    draw_set_transform(center, 0.0, Vector2(1.0, radius_y / radius_x))
    draw_circle(Vector2.ZERO, radius_x, color)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Sombra de contacto suave, con la misma luz que las sombras del fondo.
func _draw_soft_shadow(at: Vector2, radius_x: float, strength: float = 1.0) -> void:
    for i in range(3):
        var k: float = 1.0 - float(i) * 0.28
        _draw_ellipse(at, radius_x * k, radius_x * k * 0.32, Color(0.0, 0.0, 0.0, 0.13 * strength))

## [VISUAL UPGRADE] Sombra leve de contacto, anclada a los pies del protagonista.
func draw_ellipse_fake_shadow(at: Vector2) -> void:
    _draw_soft_shadow(at + Vector2(0.0, 1.0), 15.0)


## Ojo del Testigo tallado en el muro del fondo: abierto (rojo) o cerrado.
func _draw_watcher_eye(at: Vector2) -> void:
    var almond := PackedVector2Array()
    for i in range(16):
        var t: float = float(i) / 16.0 * TAU
        almond.append(at + Vector2(cos(t) * 24.0, sin(t) * 10.0 * (1.0 - 0.35 * absf(cos(t)))))
    draw_colored_polygon(almond, Color("#1a1c17"))
    almond.append(almond[0])
    draw_polyline(almond, Color("#5d6450"), 2.0)
    if watcher_open:
        var pulse: float = 0.5 + 0.5 * sin(elapsed * 4.0)
        for r in range(3, 0, -1):
            draw_circle(at, 7.0 + float(r) * 4.0, Color(0.82, 0.25, 0.30, 0.07 + 0.03 * pulse))
        draw_circle(at, 7.5, Color("#c2414f"))
        draw_circle(at, 3.2, Color("#1a0d10"))
        draw_circle(at + Vector2(-2.5, -2.5), 1.4, Color(1.0, 0.85, 0.85, 0.9))
        # Mirada proyectada sobre la sala: indica que moverse ahora es peligroso.
        draw_polygon(PackedVector2Array([at + Vector2(-8, 10), at + Vector2(8, 10), at + Vector2(140, 260), at + Vector2(-140, 260)]),
            PackedColorArray([Color(0.82, 0.2, 0.25, 0.10 + 0.04 * pulse), Color(0.82, 0.2, 0.25, 0.10 + 0.04 * pulse), Color(0.82, 0.2, 0.25, 0.0), Color(0.82, 0.2, 0.25, 0.0)]))
    elif fmod(room_elapsed, 6.0) >= 5.4:
        # A punto de abrirse: el párpado tiembla y asoma una rendija roja.
        var jitter := Vector2(randf_range(-1.5, 1.5), randf_range(-1.0, 1.0))
        var open_k: float = (fmod(room_elapsed, 6.0) - 5.4) / 0.6
        draw_line(at + jitter + Vector2(-16, 0), at + jitter + Vector2(16, 0), Color(0.85, 0.25, 0.3, 0.5 + 0.5 * open_k), 2.0 + 3.0 * open_k)
        draw_circle(at + jitter, 2.0 + 3.0 * open_k, Color("#c2414f"))
    else:
        draw_arc(at + Vector2(0.0, -6.0), 22.0, 0.35, PI - 0.35, 18, Color("#72858d"), 2.0)
        for i in range(5):
            var x: float = -14.0 + float(i) * 7.0
            draw_line(at + Vector2(x, 9.0), at + Vector2(x * 1.15, 13.0), Color("#5d6450"), 1.0)


## Círculo rúnico en el suelo con el sello del Testigo.
func _draw_seal(at: Vector2) -> void:
    var ring: Color = SOUL if seal_acquired else Color("#be9b68")
    _draw_ellipse(at + Vector2(0.0, 6.0), 44.0, 20.0, Color(ring.r, ring.g, ring.b, 0.08))
    draw_set_transform(at + Vector2(0.0, 6.0), 0.0, Vector2(1.0, 0.46))
    draw_arc(Vector2.ZERO, 42.0, 0.0, TAU, 48, Color(ring.r, ring.g, ring.b, 0.75), 2.0)
    draw_arc(Vector2.ZERO, 33.0, 0.0, TAU, 40, Color(ring.r, ring.g, ring.b, 0.35), 1.0)
    for i in range(8):
        var t: float = float(i) / 8.0 * TAU + elapsed * 0.25
        draw_line(Vector2(cos(t), sin(t)) * 34.0, Vector2(cos(t), sin(t)) * 41.0, Color(ring.r, ring.g, ring.b, 0.8), 2.0)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
    if seal_acquired:
        return
    var lift: float = sin(elapsed * 2.0) * 3.0
    var c := at + Vector2(0.0, -14.0 + lift)
    for r in range(3, 0, -1):
        draw_circle(c, 8.0 + float(r) * 5.0, Color(0.95, 0.78, 0.45, 0.06))
    var hexagon := PackedVector2Array()
    for i in range(6):
        var t: float = float(i) / 6.0 * TAU + PI / 6.0
        hexagon.append(c + Vector2(cos(t), sin(t)) * 11.0)
    draw_colored_polygon(hexagon, Color("#c9a35f"))
    hexagon.append(hexagon[0])
    draw_polyline(hexagon, Color("#f2dc9f"), 1.5)
    draw_circle(c, 3.5, Color("#5a3f1d"))


## [VISUAL UPGRADE] Salida en el muro derecho vista desde arriba: losa con runas
## cuando está sellada; vano abierto con luz que entra cuando está lista.
func _draw_door() -> void:
    var ready: bool = _room_ready()
    var tone: Color = Color("#82bdaf") if ready else Color("#b04d5e")
    var gap := Rect2(door_pos.x + 28.0, door_pos.y - 36.0, 19.0, 72.0)
    var pulse: float = 0.5 + 0.5 * sin(elapsed * 2.2)
    # Luz en el umbral.
    _draw_ellipse(Vector2(gap.position.x - 30.0, door_pos.y), 34.0, 40.0, Color(tone.r, tone.g, tone.b, 0.05 + 0.03 * pulse))
    if ready:
        draw_rect(gap, Color("#05080a"))
        draw_polygon(PackedVector2Array([gap.position, gap.position + Vector2(0, gap.size.y), Vector2(gap.position.x - 60.0, gap.end.y + 18.0), Vector2(gap.position.x - 60.0, gap.position.y - 18.0)]),
            PackedColorArray([Color(tone.r, tone.g, tone.b, 0.22), Color(tone.r, tone.g, tone.b, 0.22), Color(tone.r, tone.g, tone.b, 0.0), Color(tone.r, tone.g, tone.b, 0.0)]))
        draw_rect(Rect2(gap.position.x + 4.0, gap.position.y + 4.0, 3.0, gap.size.y - 8.0), Color(tone.r, tone.g, tone.b, 0.35 + 0.2 * pulse))
    else:
        draw_rect(gap, Color("#2b3027"))
        draw_rect(Rect2(gap.position, Vector2(3.0, gap.size.y)), Color("#3d4436"))
        for i in range(4):
            var y: float = gap.position.y + 11.0 + float(i) * 16.0
            draw_line(Vector2(gap.position.x + 5.0, y), Vector2(gap.position.x + 14.0, y + 5.0), Color(tone.r, tone.g, tone.b, 0.55 + 0.35 * pulse), 2.0)
    # Jambas de piedra.
    for y in [gap.position.y - 9.0, gap.end.y]:
        draw_rect(Rect2(gap.position.x - 6.0, y, 31.0, 9.0), Color("#454c3c"))
        draw_rect(Rect2(gap.position.x - 6.0, y, 31.0, 2.0), Color("#68715a"))
        draw_rect(Rect2(gap.position.x - 6.0, y, 31.0, 9.0), Color("#15170f"), false, 1.0)
    _label_center("SALIDA" if ready else "SELLADA", Vector2(door_pos.x - 4.0, gap.position.y - 16.0), tone)


## Altar a proporción real (78x112 escalado de forma uniforme).
func _draw_altar(at: Vector2) -> void:
    var scale: float = 0.75
    var tex: Texture2D = art["knowledge_altar"]
    var size := Vector2(tex.get_width(), tex.get_height()) * scale
    # La base visible del sprite está en y=99 de 112.
    var origin := Vector2(at.x - size.x * 0.5, at.y + 22.0 - 99.0 * scale)
    _draw_soft_shadow(Vector2(at.x, at.y + 20.0), 30.0)
    # Luz cálida de ofrenda: el sprite original es muy oscuro sobre este suelo.
    var flicker: float = 0.5 + 0.5 * sin(elapsed * 3.1) * sin(elapsed * 1.3)
    _draw_ellipse(Vector2(at.x, at.y + 18.0), 48.0, 20.0, Color(0.95, 0.72, 0.38, 0.07 + 0.03 * flicker))
    for r in range(3, 0, -1):
        draw_circle(at + Vector2(0.0, -14.0), 10.0 + float(r) * 7.0, Color(0.95, 0.74, 0.42, 0.035 + 0.015 * flicker))
    draw_texture_rect(tex, Rect2(origin, size), false, Color(1.55, 1.42, 1.22))
    # Velas a los lados del altar.
    for side in [-1.0, 1.0]:
        var c := Vector2(at.x + side * 30.0, at.y + 14.0)
        draw_rect(Rect2(c.x - 2.0, c.y - 9.0, 4.0, 9.0), Color("#d8cfb4"))
        draw_circle(c + Vector2(0.0, -12.0), 2.2 + flicker * 0.6, Color(1.0, 0.78, 0.35, 0.95))
        draw_circle(c + Vector2(0.0, -12.0), 6.0, Color(1.0, 0.7, 0.3, 0.12))


## Libro del archivo sobre la mesa: cerrado hasta leerlo; después hojea páginas.
func _draw_letter(at: Vector2) -> void:
    var sheet: Texture2D = art["knowledge_book_sheet"]
    var frame: int = 0
    if letter_found:
        frame = 15 + int(elapsed * 10.0) % 86
    else:
        var glow: float = 0.08 + 0.05 * sin(elapsed * 2.4)
        draw_circle(at + Vector2(0.0, -8.0), 22.0, Color(0.59, 0.79, 0.55, glow))
    var scale: float = 1.5
    # Celda de 64x64; la base del libro está en y=45.
    # Desde y=26 de la celda: libro y páginas, sin los glifos que flotaban
    # sobre la estatua de detrás.
    var region := Rect2(float(frame * 64) + 4.0, 26.0, 56.0, 22.0)
    var dest := Rect2(at.x - 28.0 * scale, at.y - 19.0 * scale, 56.0 * scale, 22.0 * scale)
    draw_texture_rect_region(sheet, dest, region)


## Fragmento de alma: cristal flotante con halo y sombra fija en el suelo.
func _draw_relic(at: Vector2, index: int) -> void:
    var wave: float = sin(elapsed * 2.3 + float(index) * 2.5) * 4.0
    var p := at + Vector2(0, -8.0 + wave)
    _draw_soft_shadow(at + Vector2(0.0, 10.0), 9.0 - wave * 0.5, 0.8)
    for r in range(3, 0, -1):
        draw_circle(p, 6.0 + float(r) * 5.0, Color(0.43, 0.76, 0.87, 0.05))
    var top := p + Vector2(0, -14)
    var bottom := p + Vector2(0, 12)
    var left := p + Vector2(-7, -1)
    var right := p + Vector2(7, -1)
    draw_colored_polygon(PackedVector2Array([top, p + Vector2(0, -1), bottom, left]), Color("#bfe9f2"))
    draw_colored_polygon(PackedVector2Array([top, right, bottom, p + Vector2(0, -1)]), Color("#5ea7bb"))
    draw_polyline(PackedVector2Array([top, right, bottom, left, top]), Color("#e8fbff"), 1.0)
    var sparkle: float = 0.5 + 0.5 * sin(elapsed * 5.0 + float(index))
    var s := top + Vector2(3, 2)
    draw_line(s + Vector2(-3, 0), s + Vector2(3, 0), Color(1, 1, 1, sparkle), 1.0)
    draw_line(s + Vector2(0, -3), s + Vector2(0, 3), Color(1, 1, 1, sparkle), 1.0)


func _enemy_rect() -> Rect2:
    return Rect2(enemy_pos.x - 15.0, enemy_pos.y + 4.0 - 56.0, 30.0, 56.0)


func _track_enemy_visual(dt: float) -> void:
    var delta_pos: Vector2 = enemy_pos - enemy_prev_pos
    enemy_moving = dt > 0.0 and delta_pos.length() > 8.0 * dt
    # Mientras se mueve mira hacia donde va; quieto, mira al jugador.
    var look: Vector2 = delta_pos if enemy_moving else (player_pos - enemy_pos)
    if look.length() > 0.5:
        if absf(look.x) > absf(look.y):
            enemy_facing = 2 if look.x > 0.0 else 3
        else:
            enemy_facing = 0 if look.y > 0.0 else 1
    enemy_prev_pos = enemy_pos


func _enemy_frame(kind: String) -> int:
    match kind:
        "testigo":
            # La regla se lee en el sprite: columnas 0-3 ojo abierto, 4-7 cerrado.
            return (0 if watcher_open else 4) + int(elapsed * 6.0) % 4
        "ghoul":
            return 2 + int(elapsed * 9.0) % 4 if enemy_moving else int(elapsed * 2.5) % 2
        _:
            if enemy_alert and (wizard_cast_cd > 2.45 or wizard_cast_cd < WIZARD_CHARGE): # carga o acaba de lanzar
                return 6 + int(elapsed * 8.0) % 2
            return 2 + int(elapsed * 7.0) % 4 if enemy_moving else int(elapsed * 2.0) % 2


func _draw_enemy() -> void:
    var kind: String = "ghoul" if current_room == 1 else ("testigo" if current_room == 2 else "hechicero")
    var sheet: Texture2D = art["enemy_" + kind]
    var frame: int = _enemy_frame(kind)
    var region := Rect2(float(frame) * ENEMY_CELL.x, float(enemy_facing) * ENEMY_CELL.y, ENEMY_CELL.x, ENEMY_CELL.y)
    var lift: float = 0.0
    if kind == "testigo":
        lift = 8.0 + sin(elapsed * 2.6) * 2.0 # flota: la sombra se queda en el suelo
    var feet := Vector2(roundf(enemy_pos.x), roundf(enemy_pos.y + 4.0 - lift))
    var footprint: float = 17.0 if kind == "testigo" else 14.0
    _draw_soft_shadow(enemy_pos + Vector2(0.0, 3.0), footprint, 1.0 if lift == 0.0 else 0.7)
    if enemy_alert:
        var pulse: float = 0.5 + 0.5 * sin(elapsed * 8.0)
        _draw_ellipse(enemy_pos + Vector2(0.0, 3.0), footprint + 9.0, (footprint + 9.0) * 0.34, Color(0.85, 0.22, 0.28, 0.18 + 0.12 * pulse))
    if enemy_stun > 0.0:
        _draw_ellipse(enemy_pos + Vector2(0.0, 3.0), footprint + 9.0, (footprint + 9.0) * 0.34, Color(0.56, 0.78, 0.84, 0.30))
    if kind == "ghoul":
        # Las brasas iluminan el suelo a su alrededor.
        draw_circle(enemy_pos + Vector2(0.0, -30.0), 30.0, Color(1.0, 0.55, 0.2, 0.05 + 0.02 * sin(elapsed * 9.0)))
    var tint := Color(0.75, 0.85, 1.0, 1.0) if enemy_stun > 0.0 else Color.WHITE
    if enemy_hit_t > 0.0 and int(enemy_hit_t * 30.0) % 2 == 0:
        tint = Color(1.0, 0.42, 0.38, 1.0) # destello del golpe
    var dest := Rect2(feet.x - ENEMY_CELL.x * 0.5, feet.y - ENEMY_FEET_Y, ENEMY_CELL.x, ENEMY_CELL.y)
    draw_texture_rect_region(sheet, dest, region, tint)
    if kind == "hechicero" and enemy_alert and wizard_cast_cd < WIZARD_CHARGE:
        # Aviso justo: el orbe crece antes de lanzar el conjuro (y es vulnerable).
        var k: float = 1.0 - wizard_cast_cd / WIZARD_CHARGE
        # Donde el sprite sostiene el orbe: sobre la cabeza de frente, en la mano de lado.
        var hand: Vector2 = [Vector2(0, -57), Vector2(0, -57), Vector2(19, -49), Vector2(-19, -49)][enemy_facing]
        var orb := feet + hand
        draw_circle(orb, 5.0 + 9.0 * k, Color(1.0, 0.6, 0.25, 0.15 + 0.2 * k))
        draw_circle(orb, 1.5 + 3.0 * k, Color(1.0, 0.88, 0.6, 0.9))


## Barra de vida y estado de la entidad: siempre sobre la escena.
func _draw_enemy_health() -> void:
    var top: float = _enemy_rect().position.y - (8.0 if current_room == 2 else 0.0)
    var near: bool = player_pos.distance_to(enemy_pos) < 300.0
    if enemy_hp >= enemy_max and not near:
        return
    var vulnerable: bool = _enemy_vulnerable()
    var bar := Rect2(enemy_pos.x - 24.0, top - 12.0, 48.0, 6.0)
    draw_rect(bar.grow(1.0), Color(0, 0, 0, 0.7))
    draw_rect(bar, Color("#3a2328"))
    var fill: Color = Color("#d1474f") if vulnerable else Color("#7d6f73")
    draw_rect(Rect2(bar.position, Vector2(bar.size.x * clampf(enemy_hp / enemy_max, 0.0, 1.0), bar.size.y)), fill)
    var edge: Color = Color("#e3bd7b") if vulnerable else Color("#5b6266")
    if vulnerable and current_room != 1:
        edge.a = 0.6 + 0.4 * sin(elapsed * 10.0)
    draw_rect(bar.grow(1.0), edge, false, 1.0)
    var state: String = ""
    var tone: Color = CREAM
    if enemy_stun > 0.0:
        state = "ATURDIDO"
        tone = SOUL
    elif current_room != 1:
        state = "VULNERABLE" if vulnerable else "INMUNE"
        tone = Color("#e3bd7b") if vulnerable else Color("#9aa19a")
    if state != "":
        _label_center(state, Vector2(enemy_pos.x, bar.position.y - 4.0), tone)


## Entidad desterrada: el sprite se deshace hacia arriba en ceniza luminosa.
func _draw_dissolve_fx() -> void:
    for fx in dissolve_fx:
        var t: float = float(fx["t"])
        var k: float = clampf(t / 1.4, 0.0, 1.0)
        var p: Vector2 = fx["pos"]
        var sheet: Texture2D = art["enemy_" + str(fx["kind"])]
        var region := Rect2(float(fx["frame"]) * ENEMY_CELL.x, float(fx["facing"]) * ENEMY_CELL.y, ENEMY_CELL.x, ENEMY_CELL.y)
        var dest := Rect2(p.x - ENEMY_CELL.x * 0.5, p.y + 4.0 - ENEMY_FEET_Y - k * 18.0, ENEMY_CELL.x, ENEMY_CELL.y)
        draw_texture_rect_region(sheet, dest, region, Color(0.75 + k, 0.9, 1.0, (1.0 - k) * 0.9))
        for i in range(14):
            var ang: float = float(i) * 2.4
            var r: float = 6.0 + k * (22.0 + float(i % 4) * 6.0)
            var q := p + Vector2(cos(ang) * r, -28.0 - k * (30.0 + float(i % 5) * 8.0) + sin(ang) * r * 0.4)
            draw_circle(q, 2.2 * (1.0 - k) + 0.6, Color(0.75, 0.93, 1.0, (1.0 - k) * 0.9))


## Estela de fuego del golpe de antorcha.
func _draw_strike_fx() -> void:
    if strike_fx <= 0.0:
        return
    var k: float = 1.0 - strike_fx / 0.25
    var c := player_pos + Vector2(0.0, -20.0)
    var mid: float = strike_dir.angle()
    var a0: float = mid - 1.1
    var a1: float = mid - 1.1 + 2.2 * minf(1.0, k * 1.6)
    for i in range(3):
        var r: float = 34.0 + float(i) * 9.0
        var col: Color = [Color(1.0, 0.85, 0.42), Color(0.94, 0.54, 0.23), Color(0.76, 0.25, 0.18)][i]
        col.a = (1.0 - k) * 0.85
        draw_arc(c, r, a0, a1, 16, col, 5.0 - float(i))
    var tip := c + Vector2.from_angle(a1) * 44.0
    draw_circle(tip, 7.0 * (1.0 - k), Color(1.0, 0.82, 0.45, 0.7 * (1.0 - k)))


## Onda de Resonancia: anillo que se expande hasta su alcance de daño.
func _draw_pulse_fx() -> void:
    if pulse_fx < 0.0:
        return
    var k: float = clampf(pulse_fx / 0.45, 0.0, 1.0)
    var r: float = PULSE_RADIUS * (1.0 - pow(1.0 - k, 3.0))
    var a: float = 1.0 - clampf(pulse_fx / 0.6, 0.0, 1.0)
    draw_set_transform(player_pos + Vector2(0.0, -6.0), 0.0, Vector2(1.0, 0.6))
    draw_arc(Vector2.ZERO, r, 0.0, TAU, 64, Color(0.75, 0.93, 1.0, a), 4.0)
    draw_arc(Vector2.ZERO, r * 0.8, 0.0, TAU, 64, Color(0.56, 0.78, 0.84, a * 0.6), 2.0)
    draw_circle(Vector2.ZERO, r, Color(0.56, 0.78, 0.84, a * 0.08))
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_float_fx() -> void:
    for fx in float_fx:
        var t: float = float(fx["t"])
        var a: float = clampf(1.0 - t / 0.9, 0.0, 1.0)
        var col: Color = fx["color"]
        var p: Vector2 = fx["pos"] + Vector2(0.0, -t * 24.0)
        draw_string(font, p + Vector2(-50, 1), str(fx["text"]), HORIZONTAL_ALIGNMENT_CENTER, 100, 16, Color(0, 0, 0, a * 0.8))
        draw_string(font, p + Vector2(-51, 0), str(fx["text"]), HORIZONTAL_ALIGNMENT_CENTER, 100, 16, Color(col.r, col.g, col.b, a))


## Cadáver del antiguo dueño del alma: tendido en el suelo, bajo la luz de la sala.
func _draw_corpse(at: Vector2, seed_index: int) -> void:
    var tex: Texture2D = CORPSES[seed_index % CORPSES.size()]
    var size := Vector2(tex.get_width(), tex.get_height())
    var dest := Rect2(roundf(at.x - size.x * 0.5), roundf(at.y + 4.0 - size.y * 0.5), size.x, size.y)
    _draw_texture_flipped(tex, dest, seed_index % 2 == 1) # variedad: espejo


## Dibuja una textura en su rectángulo, volteada en horizontal si se pide.
## (Un Rect2 de ancho negativo no sirve: Godot lo desplaza un ancho.)
func _draw_texture_flipped(tex: Texture2D, dest: Rect2, flip: bool) -> void:
    if not flip:
        draw_texture_rect(tex, dest, false)
        return
    draw_set_transform(Vector2(dest.position.x + dest.size.x, dest.position.y), 0.0, Vector2(-1.0, 1.0))
    draw_texture_rect(tex, Rect2(Vector2.ZERO, dest.size), false)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Objeto recogible en el suelo: icono que flota sobre su sombra.
func _draw_item(item: Dictionary) -> void:
    var p: Vector2 = item["pos"]
    var wave: float = sin(elapsed * 2.6 + p.x) * 2.5
    _draw_soft_shadow(p + Vector2(0.0, 8.0), 11.0, 0.8)
    draw_circle(p + Vector2(0.0, -8.0), 18.0, Color(0.95, 0.78, 0.45, 0.06 + 0.03 * sin(elapsed * 3.0)))
    draw_texture_rect(ICONS[item["kind"]], Rect2(p + Vector2(-16.0, -26.0 + wave), Vector2(32.0, 32.0)), false)


func _draw_fireballs() -> void:
    var frame: int = 1 + (int(elapsed * 11.0) % 3)
    for ball in fireballs:
        var p: Vector2 = ball["pos"]
        draw_circle(p, 16.0, Color(1.0, 0.55, 0.2, 0.12))
        draw_texture_rect(art["fireball_%d" % frame], Rect2(p.x - 20, p.y - 20, 40, 40), false)


func _draw_player() -> void:
    ## [VISUAL UPGRADE] Spritesheet top-down, arte original y cuatro orientaciones.
    if art.has("visual_hero"):
        var direction_index: int = 0 # frente/abajo
        if absf(player_dir.x) > absf(player_dir.y):
            direction_index = 2 if player_dir.x > 0.0 else 3
        elif player_dir.y < 0.0:
            direction_index = 1 # espalda/arriba
        var frame_index: int = int(elapsed * 2.0) % 2 # Idle A/B
        if game_mode == "dead":
            frame_index = 8
        elif damage_cd > 0.0:
            frame_index = 7
        elif visual_interaction_left > 0.0:
            frame_index = 6
        elif player_moving:
            frame_index = 2 + (int(elapsed * 8.0) % 4)
        var atlas := Rect2(float(frame_index * 40), float(direction_index * 56), 40.0, 56.0)
        var location := Vector2(roundf(player_pos.x) - 20.0, roundf(player_pos.y) - 50.0)
        draw_ellipse_fake_shadow(player_pos)
        var blink: bool = damage_cd > 0.0 and int(elapsed * 14.0) % 2 == 0
        # La antorcha va en la mano; de espaldas queda detrás del cuerpo.
        var hand: Vector2 = player_pos + [Vector2(12, -18), Vector2(-12, -20), Vector2(9, -19), Vector2(-9, -19)][direction_index]
        if has_torch and direction_index == 1 and game_mode != "dead":
            _draw_hand_torch(hand)
        draw_texture_rect_region(art["visual_hero"], Rect2(location, Vector2(40.0, 56.0)), atlas, Color(1, 1, 1, 0.35 if blink else 1.0))
        if has_torch and direction_index != 1 and game_mode != "dead":
            _draw_hand_torch(hand)
        if bump_left > 0.0:
            # Polvo del choque a ambos lados de los pies: el objeto es sólido.
            var t: float = 1.0 - bump_left / 0.35
            for side in [-1.0, 1.0]:
                for i in range(3):
                    var p: Vector2 = bump_at + Vector2(side * (12.0 + t * 10.0 + float(i) * 4.0), -float(i) * 3.0 - t * 4.0)
                    draw_circle(p, 3.0 - t * 1.6 - float(i) * 0.4, Color(0.84, 0.80, 0.66, 0.65 * (1.0 - t)))
        if ward_left > 0.0:
            draw_arc(player_pos, 27.0, 0.0, TAU, 40, SOUL, 2.0)
        if damage_cd > 0.0:
            draw_arc(player_pos, 29.0, 0.0, TAU, 40, RED, 2.0)
        return
    if art.has("mark"):
        var t: Texture2D = art["mark"]
        var frame: int = 0
        if player_moving:
            var tick: int = int(elapsed * 9.0)
            if absf(player_dir.x) > absf(player_dir.y):
                frame = (10 + tick % 5) if player_dir.x > 0.0 else (19 + tick % 5)
            else:
                frame = (6 + tick % 4) if player_dir.y > 0.0 else (16 + tick % 4)
        draw_texture_rect_region(t, Rect2(player_pos.x - 15, player_pos.y - 54, 30, 57), Rect2(frame * 24, 0, 24, 70))
        return
    if art.has("player"):
        draw_texture_rect(art["player"], Rect2(player_pos.x - 20, player_pos.y - 42, 40, 48), false)
        return
    var p := player_pos
    draw_circle(p + Vector2(0, 18), 14.0, Color(0, 0, 0, 0.4))
    draw_colored_polygon(PackedVector2Array([
        p + Vector2(0, -19), p + Vector2(17, -4),
        p + Vector2(17, 20), p + Vector2(-16, 20), p + Vector2(-17, -3)
    ]), Color("#b9b8b3"))
    draw_circle(p + Vector2(0, -11), 11.5, Color("#d0cac0"))
    draw_line(p + Vector2(-3, -12), p + Vector2(3, -12), Color("#26272d"), 2)
    draw_line(p + Vector2(2, -1), p + Vector2(16, 8), Color("#a53e56"), 4.0)
    draw_line(p + Vector2(9, 5), p + Vector2(24, 15), Color("#a53e56"), 3.0)
    draw_line(p + Vector2(0, 0), p + player_dir * 20.0, Color("#e9ddab"), 2.0)
    if ward_left > 0:
        draw_arc(p, 27.0, 0.0, TAU, 48, SOUL, 2.0)
    if damage_cd > 0:
        draw_arc(p, 29.0, 0.0, TAU, 28, RED, 2.0)


func _draw_hand_torch(hand: Vector2) -> void:
    var tip := hand + Vector2(0.0, -14.0)
    draw_line(hand + Vector2(0.0, 4.0), tip, Color("#5c3a22"), 3.0)
    draw_line(hand + Vector2(-1.0, 3.0), tip + Vector2(-1.0, 1.0), Color("#8a5a35"), 1.0)
    draw_rect(Rect2(tip.x - 3.0, tip.y - 1.0, 6.0, 4.0), Color("#d9cfb0"))
    if not torch_on:
        draw_rect(Rect2(tip.x - 2.0, tip.y - 3.0, 4.0, 2.0), Color("#3a2f2a"))
        return
    var f: float = sin(elapsed * 17.0) * 1.2
    draw_circle(tip + Vector2(0.0, -10.0), 16.0, Color(1.0, 0.7, 0.3, 0.10))
    draw_colored_polygon(PackedVector2Array([tip + Vector2(-5, -1), tip + Vector2(5, -1), tip + Vector2(2, -9), tip + Vector2(f, -15), tip + Vector2(-3, -8)]), Color("#c2412f"))
    draw_colored_polygon(PackedVector2Array([tip + Vector2(-3, -1), tip + Vector2(3, -1), tip + Vector2(f * 0.6, -11)]), Color("#f08a3a"))
    draw_colored_polygon(PackedVector2Array([tip + Vector2(-1.5, -1), tip + Vector2(1.5, -1), tip + Vector2(0, -6)]), Color("#ffd36b"))


func _draw_topbar() -> void:
    ## [VISUAL UPGRADE] HUD gótico: zonas despejadas y jerarquía legible.
    draw_rect(Rect2(0, 0, W, 103), Color("#0d1219"))
    draw_rect(Rect2(0, 100, W, 2), Color("#6f6552"))
    draw_rect(Rect2(25, 14, 3, 69), Color("#bb9e6d"))
    _text("EL TEMPLO DE LOS ECOS", Vector2(40, 34), 18, CREAM)
    _text(ROOM_NAMES[current_room], Vector2(40, 66), 13, Color("#a0b6b2"))
    _text("PISO I  /  TEMPLO CONSERVADO", Vector2(40, 85), 10, Color("#978d77"))
    _text("VIDA", Vector2(317, 27), 11, CREAM)
    _text("VIGOR", Vector2(309, 54), 11, CREAM)
    _text("MIEDO", Vector2(310, 82), 11, CREAM)
    _bar(Rect2(361, 15, 169, 13), hp / max_hp, Color("#bd6b70"))
    _bar(Rect2(361, 42, 169, 11), stamina / 100.0, Color("#84b3a0"))
    _bar(Rect2(361, 70, 169, 10), fear / 100.0, Color("#c5a06e"))
    draw_rect(Rect2(566, 20, 1, 66), Color("#444a4d"))
    _text("SALA %02d / 05" % (current_room + 1), Vector2(590, 43), 16, CREAM)
    var soul_color: Color = SOUL.lerp(Color.WHITE, clampf(souls_flash / 0.8, 0.0, 1.0))
    _text("ALMAS  %03d" % souls, Vector2(590, 70), 17 + int(round(souls_flash * 4.0)), soul_color)
    _text("IDENTIDAD %03d" % identity_number, Vector2(781, 30), 12, Color("#a0b6b2"))
    # Inventario rápido: antorcha (o madera), fósforos y llama interior.
    var torch_icon: String = ("antorcha_encendida" if torch_on else "antorcha") if has_torch else "madera"
    var slots := [[torch_icon, has_torch or has_wood, ""], ["fosforos", matches > 0 or has_torch, "%d" % matches], ["llama_interior", has_inner_flame, ""]]
    for i in range(slots.size()):
        var box := Rect2(781.0 + float(i) * 46.0, 40.0, 40.0, 40.0)
        draw_rect(box, Color("#151c25"))
        draw_rect(box, Color("#5b5444"), false, 1.0)
        var owned: bool = slots[i][1]
        draw_texture_rect(ICONS[slots[i][0]], Rect2(box.position + Vector2(4, 4), Vector2(32, 32)), false, Color(1, 1, 1, 1.0) if owned else Color(0.3, 0.3, 0.3, 0.45))
        if owned and slots[i][2] != "":
            draw_string(font, box.position + Vector2(2, 38), slots[i][2], HORIZONTAL_ALIGNMENT_RIGHT, 36, 13, CREAM if matches > 0 else RED)
    _text("I  inventario", Vector2(781, 95), 10, Color("#978d77"))


func _bar(rect: Rect2, fraction: float, color: Color) -> void:
    draw_rect(rect, Color("#30353d"))
    draw_rect(Rect2(rect.position, Vector2(rect.size.x * clampf(fraction, 0.0, 1.0), rect.size.y)), color)
    draw_rect(rect, Color("#666a75"), false, 1.0)


func _draw_footer() -> void:
    ## [VISUAL UPGRADE] Fila 1: objetivo de la sala. Fila 2: controles.
    ## La misión ya no flota sobre el muro ni los mensajes tapan los controles.
    draw_rect(Rect2(0, 575, W, 65), Color("#101720"))
    draw_rect(Rect2(0, 575, W, 2), Color("#8b795c"))
    var task: String = "MISIÓN: Recuperar el sello del Testigo"
    if current_room == 0 and not has_torch:
        task = "OSCURIDAD: busca madera y fósforos"
    elif current_room == 0 and not torch_on:
        task = "PULSA F PARA ENCENDER LA ANTORCHA"
    elif current_room == 1:
        task = "BRASAS: tu luz puede atraer algo"
    elif current_room == 3:
        task = "ARCHIVO: lee la carta, evita los conjuros"
    if current_room == 2:
        task = "OJO ABIERTO: INMÓVIL" if watcher_open else "OJO CERRADO: AVANZA"
        if seal_acquired:
            task = "SELLO RECUPERADO · VE A LA PUERTA"
    var task_color: Color = SOUL if _room_ready() else CREAM
    if current_room == 2 and watcher_open and not seal_acquired:
        task_color = RED
    draw_colored_polygon(PackedVector2Array([Vector2(26, 594), Vector2(31, 589), Vector2(36, 594), Vector2(31, 599)]), Color("#bb9e6d"))
    _text(task, Vector2(44, 600), 14, task_color)
    # Habilidades con icono y recuperación (sombra que baja).
    _draw_ability_icon(Rect2(846, 581, 34, 34), "golpe", has_torch and torch_on, strike_cd / 0.6, "E")
    _draw_ability_icon(Rect2(890, 581, 34, 34), "resonancia", has_pulse, pulse_cd / 8.0, "Q")
    _text("WASD mover  ·  E / CLIC interactuar o golpear  ·  F antorcha  ·  ESPACIO esquivar  ·  Q resonancia  ·  I inventario  ·  ESC menú", Vector2(26, 630), 11, Color("#a9a48f"))


func _draw_ability_icon(box: Rect2, key: String, ready_to_use: bool, cooldown: float, hotkey: String) -> void:
    draw_rect(box, Color("#151c25"))
    draw_texture_rect(ICONS[key], box.grow(-1.0), false, Color.WHITE if ready_to_use else Color(0.35, 0.35, 0.35, 0.6))
    if ready_to_use and cooldown > 0.0:
        var h: float = box.size.y * clampf(cooldown, 0.0, 1.0)
        draw_rect(Rect2(box.position.x, box.end.y - h, box.size.x, h), Color(0.02, 0.03, 0.05, 0.7))
    draw_rect(box, Color("#c6aa6e") if ready_to_use and cooldown <= 0.0 else Color("#4d4a42"), false, 1.0)
    draw_rect(Rect2(box.end.x - 11.0, box.end.y - 12.0, 11.0, 12.0), Color(0.03, 0.04, 0.06, 0.85))
    draw_string(font, Vector2(box.end.x - 11.0, box.end.y - 2.0), hotkey, HORIZONTAL_ALIGNMENT_CENTER, 11, 10, CREAM)


func _draw_toast() -> void:
    ## Mensaje flotante bajo la barra superior, centrado y con desvanecimiento.
    var alpha: float = clampf(toast_left * 3.0, 0.0, 1.0)
    var size: int = 14
    var width: float = minf(font.get_string_size(toast, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x + 36.0, W - 40.0)
    var box := Rect2((W - width) * 0.5, 104.0, width, 27.0)
    draw_rect(box, Color(0.035, 0.05, 0.065, 0.92 * alpha))
    draw_rect(Rect2(box.position.x, box.end.y - 1.0, box.size.x, 1.0), Color(0.73, 0.62, 0.43, 0.8 * alpha))
    draw_string(font, Vector2(box.position.x, box.position.y + 19.0), toast, HORIZONTAL_ALIGNMENT_CENTER, box.size.x, size, Color(CREAM.r, CREAM.g, CREAM.b, alpha))


func _draw_title() -> void:
    ## [VISUAL UPGRADE] Panel ceremonial: temple still visible behind the title.
    # La sala actual (escena) queda detrás; solo se oscurece.
    draw_rect(Rect2(0, 0, W, H), Color(0.018, 0.027, 0.032, 0.60))
    draw_rect(Rect2(149, 166, 662, 386), Color(0.055, 0.076, 0.086, 0.94))
    draw_rect(Rect2(149, 166, 662, 386), Color("#8d7957"), false, 2.0)
    draw_rect(Rect2(160, 178, 640, 362), Color("#455452"), false, 1.0)
    draw_line(Vector2(300, 228), Vector2(660, 228), Color("#8d7957"), 1.0)
    draw_texture_rect(BRAND_ICON, Rect2(443, 184, 74, 74), false)
    ## Botones: misma zona táctil que antes (izquierda explorar, derecha vigilia).
    var explore := Rect2(203, 446, 257, 58)
    var vigil := Rect2(500, 446, 257, 58)
    draw_rect(explore, Color(0.06, 0.22, 0.25, 0.90))
    draw_rect(vigil, Color(0.25, 0.19, 0.10, 0.90))
    draw_rect(explore, SOUL, false, 2.0)
    draw_rect(vigil, Color("#c6aa6e"), false, 2.0)
    _center("EL TEMPLO", 289, 40, CREAM)
    _center("DE LOS ECOS", 339, 43, SOUL)
    _center("UN LUGAR SAGRADO. UN CICLO QUE SE ALIMENTA DE TI.", 376, 15, CREAM)
    draw_line(Vector2(318, 392), Vector2(642, 392), Color("#736851"), 1.0)
    _center("PISO I  •  5 SALAS  •  REGLAS POR DESCUBRIR", 413, 12, SOUL)
    _center("No conoces las reglas. Aún.", 434, 16, CREAM)
    draw_string(font, Vector2(explore.position.x, explore.position.y + 37.0), "EXPLORAR", HORIZONTAL_ALIGNMENT_CENTER, explore.size.x, 21, CREAM)
    draw_string(font, Vector2(vigil.position.x, vigil.position.y + 37.0), "VIGILIA", HORIZONTAL_ALIGNMENT_CENTER, vigil.size.x, 21, CREAM)
    _center("ENTER  explorar      ·      H  vigilia", 528, 12, Color("#9fb3b3"))
    _center("IDENTIDAD %03d   |   RETORNOS %d   |   ABSORCIONES %d" % [identity_number, reincarnations, new_humans], 567, 12, CREAM)
    if toast_left > 0:
        _draw_toast()


func _draw_altar_overlay() -> void:
    _overlay()
    draw_rect(Rect2(164, 155, 632, 357), Color("#19202b"))
    draw_rect(Rect2(164, 155, 632, 357), Color("#8c8088"), false, 2)
    _center("EL MERCADER SILENCIOSO", 200, 26, CREAM)
    _center("'Todo préstamo tiene un dueño que no conoces.'", 232, 15, SOUL)
    var offers := [
        ["resonancia", "[1] RESONANCIA", "Onda (Q) que daña y aturde a las entidades cercanas.", 14, has_pulse, "NIVEL %d" % ability_level],
        ["llama_interior", "[2] LLAMA INTERIOR", "Enciendes la antorcha sin gastar fósforos.", INNER_FLAME_PRICE, has_inner_flame, "ADQUIRIDA"],
    ]
    for i in range(offers.size()):
        var row: Rect2 = _altar_row_rect(i)
        var o: Array = offers[i]
        var hover: bool = inventory_sel == i
        draw_rect(row, Color("#202a36") if hover else Color("#1a222d"))
        draw_rect(row, Color("#c6aa6e") if hover else Color("#4d4a42"), false, 1.0)
        draw_texture_rect(ICONS[o[0]], Rect2(row.position + Vector2(12, 11), Vector2(64, 64)), false)
        _text(o[1], row.position + Vector2(92, 32), 18, CREAM)
        _text(o[2], row.position + Vector2(92, 60), 13, Color("#b9b29b"))
        var right: String = o[5] if o[4] else "%d ALMAS" % o[3]
        var tone: Color = SOUL if o[4] else (CREAM if souls >= o[3] else RED)
        draw_string(font, row.position + Vector2(0, 32), right, HORIZONTAL_ALIGNMENT_RIGHT, row.size.x - 14.0, 15, tone)
    draw_texture_rect(ICONS["alma"], Rect2(196, 464, 26, 26), false)
    _text("ALMAS: %d" % souls, Vector2(228, 484), 16, SOUL)
    _text("E / ESC: salir", Vector2(640, 484), 14, CREAM)


func _draw_inventory_overlay() -> void:
    _overlay()
    draw_rect(Rect2(196, 140, 568, 400), Color("#19202b"))
    draw_rect(Rect2(196, 140, 568, 400), Color("#8c8088"), false, 2)
    _center("INVENTARIO", 184, 24, CREAM)
    for i in range(INVENTORY_SLOTS.size()):
        var box: Rect2 = _inventory_slot_rect(i)
        var owned: bool = _slot_owned(i)
        var sel: bool = inventory_sel == i
        draw_rect(box, Color("#222c39") if sel else Color("#151c25"))
        draw_rect(box, Color("#c6aa6e") if sel else Color("#3f4448"), false, 2.0 if sel else 1.0)
        var key: String = INVENTORY_SLOTS[i][0]
        if key == "antorcha" and torch_on:
            key = "antorcha_encendida"
        draw_texture_rect(ICONS[key], Rect2(box.position + Vector2(46, 8), Vector2(64, 64)), false, Color.WHITE if owned else Color(0.12, 0.12, 0.14, 0.9))
        var title: String = INVENTORY_SLOTS[i][1] if owned else "???"
        if INVENTORY_SLOTS[i][0] == "fosforos" and owned:
            title = "FÓSFOROS x%d" % matches
        draw_string(font, box.position + Vector2(0, 92), title, HORIZONTAL_ALIGNMENT_CENTER, box.size.x, 12, CREAM if owned else Color("#6d6a60"))
    # Descripción de la casilla señalada (cursor, flechas o toque).
    var desc: String = INVENTORY_SLOTS[inventory_sel][2] if _slot_owned(inventory_sel) else "Aún no lo tienes. Explora el templo."
    draw_rect(Rect2(222, 458, 516, 40), Color("#101720"))
    draw_string(font, Vector2(222, 483), desc, HORIZONTAL_ALIGNMENT_CENTER, 516, 13, SOUL if _slot_owned(inventory_sel) else Color("#8a8778"))
    _center("I / ESC: cerrar", 524, 12, Color("#978d77"))

func _draw_end_overlay(win: bool) -> void:
    _overlay()
    if win:
        _center("PISO 1 SUPERADO", 230, 33, SOUL)
        _center("No has escapado. El siguiente nivel sigue oculto.", 280, 18, CREAM)
        _center("El templo conserva su apariencia. Nada es lo que parece.", 318, 16, CREAM)
        _center("ENTER: repetir prueba  ·  ESC: menú", 418, 18, CREAM)
    elif soul_fate == "retorno":
        _center("TU ALMA HA REGRESADO", 230, 30, SOUL)
        _center("Resultado aleatorio de la muerte: reencarnación (50 %).", 278, 18, CREAM)
        _center("Eres la misma persona. Conservas memoria y habilidades.", 318, 17, CREAM)
        _center("Los niveles de habilidad regresaron a cero.", 352, 17, CREAM)
        _center("ENTER: reaparecer al inicio  ·  ESC: menú", 418, 18, CREAM)
    else:
        _center("ALMA ABSORBIDA", 230, 32, RED)
        _center("Resultado aleatorio: absorción definitiva (50 %).", 278, 18, CREAM)
        _center("La persona anterior ha dejado de existir.", 318, 17, CREAM)
        _center("Un nuevo humano ocupará el lugar, sin sus recuerdos.", 352, 17, CREAM)
        _center("ENTER: iniciar nueva identidad  ·  ESC: menú", 418, 18, CREAM)


func _overlay() -> void:
    draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, 0.75))


func _text(msg: String, at: Vector2, size: int = 16, color: Color = CREAM) -> void:
    draw_string(font, at, msg, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, color)


func _center(msg: String, y: float, size: int = 16, color: Color = CREAM) -> void:
    draw_string(font, Vector2(40, y), msg, HORIZONTAL_ALIGNMENT_CENTER, 880.0, size, color)
