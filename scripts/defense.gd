extends Node2D
## Modo alternativo: Vigilia del Claustro. Defensa de una celda del templo,
## por fases sin fin. Duermes en el lecho para ganar ecos y **construyes en
## cualquier baldosa libre**: centinelas (disparan), generadores (energía) y
## campanas (frenan a las entidades). Todo se toca para mejorarlo: cada
## estructura, el lecho y la puerta tienen muchos niveles. Cada fase superada
## da un objeto al azar para la campaña (scripts/botin.gd); cada fase es más
## difícil y su botín, mejor.
## Inspirado en el género de defensa de habitación (tipo Haunted Dorm), con
## arte, código e interfaz propios.
const W := 960.0
const H := 640.0
const PHASE_LENGTH := 90.0 # segundos por fase
const LENGTH := PHASE_LENGTH # nombre antiguo, por compatibilidad
const DEFENSE_SAVE := "user://vigilia_claustro_records.json"
const DEFENSE_SAVE_TEST := "user://prueba_vigilia.json" # pruebas automáticas
const Botin := preload("res://scripts/botin.gd")
const Ajustes := preload("res://scripts/ajustes.gd")
const PIXEL_FONT := preload("res://assets/fonts/PixelifySans.ttf")
const TITLE_FONT := preload("res://assets/fonts/Jacquard24-Regular.ttf")
const HERO := preload("res://assets/visual/protagonist_sheet.png")
const CREAM := Color("#d9d2ba")
const SOUL := Color("#8fc7d7")
const GOLD := Color("#b8955a")
const GOLD_HI := Color("#e3bd7b")
const CRIMSON := Color("#d1474f")
const VIOLET := Color("#3b2550")
const EDGE := Color("#2f2a35")
## Celda en rejilla de 11 x 7 baldosas de 56 px. El lecho ocupa 2 x 3.
const TILE := 56.0
const COLS := 11
const ROWS := 7
const ROOM := Rect2(40, 88, 616, 392)
const BED_TILES := Rect2i(1, 2, 2, 3)
const BED := Rect2(96, 200, 112, 168)
const DOOR := Rect2(650, 228, 24, 112)
const DOOR_X := 700.0 # donde se paran las entidades a golpear
const SPAWN_X := 990.0
const EXIT_RECT := Rect2(888, 8, 56, 48)
const PAUSE_RECT := Rect2(826, 8, 56, 48)
## Niveles máximos (muchos: la Vigilia no se acaba).
const BED_MAX := 20
const DOOR_MAX := 20
const STRUCT_MAX := 15
const POWER_MAX := 15
## Estructuras: [nombre, icono, descripción, coste base, factor por cada una más, coste de mejora base].
const STRUCTS := {
    "centinela": ["CENTINELA", "centinela", "Dispara a la entidad más cercana a la puerta.", 20.0, 1.3, 15.0],
    "generador": ["GENERADOR", "generador", "Energía mientras duermes (para potenciar y escudo).", 30.0, 1.35, 20.0],
    "campana": ["CAMPANA", "campana", "Su tañido frena a las entidades del pasillo.", 40.0, 1.5, 25.0],
}
const MONSTER_SHEETS := {
    "ghoul": preload("res://assets/visual/enemies/ghoul.png"),
    "wizard": preload("res://assets/visual/enemies/hechicero.png"),
    "angel": preload("res://assets/visual/enemies/testigo.png"),
    "mastin": preload("res://assets/visual/enemies/mastin.png"),
    "segador": preload("res://assets/visual/enemies/segador.png"),
    "tejedora": preload("res://assets/visual/enemies/tejedora.png"),
    "ariete": preload("res://assets/visual/enemies/ariete.png"),
}
const STAGE_KINDS := ["ghoul", "wizard", "angel", "mastin", "segador", "ariete", "ghoul", "tejedora", "mastin", "ariete"]
const BOSS_KINDS := ["tejedora", "segador", "ariete", "angel"]
const ICONS := {
    "descansar": preload("res://assets/visual/iconos/descansar.png"),
    "levantar": preload("res://assets/visual/iconos/levantar.png"),
    "lecho": preload("res://assets/visual/iconos/lecho.png"),
    "puerta": preload("res://assets/visual/iconos/puerta.png"),
    "centinela": preload("res://assets/visual/iconos/centinela.png"),
    "reparar": preload("res://assets/visual/iconos/reparar.png"),
    "generador": preload("res://assets/visual/iconos/generador.png"),
    "potenciar": preload("res://assets/visual/iconos/potenciar.png"),
    "escudo": preload("res://assets/visual/iconos/escudo.png"),
    "pausa": preload("res://assets/visual/iconos/pausa.png"),
    "reanudar": preload("res://assets/visual/iconos/reanudar.png"),
    "salir": preload("res://assets/visual/iconos/salir.png"),
    "alma": preload("res://assets/visual/iconos/alma.png"),
    "campana": preload("res://assets/visual/iconos/campana.png"),
    "vender": preload("res://assets/visual/iconos/vender.png"),
    "pan": preload("res://assets/visual/iconos/pan.png"),
    "fosforos": preload("res://assets/visual/iconos/fosforos.png"),
    "vial": preload("res://assets/visual/iconos/vial.png"),
    "incienso": preload("res://assets/visual/iconos/incienso.png"),
    "bolsa_almas": preload("res://assets/visual/iconos/bolsa_almas.png"),
    "brazalete": preload("res://assets/visual/iconos/brazalete.png"),
    "amuleto": preload("res://assets/visual/iconos/amuleto.png"),
    "resonancia": preload("res://assets/visual/iconos/resonancia.png"),
    "reliquia": preload("res://assets/visual/iconos/reliquia.png"),
}

var phase: String = "selection" # selection (portada), play, won (fase superada), lost
var chamber: int = 0 # compatibilidad: hay un solo modo
var stage: int = 1
var hover_pos: Vector2 = Vector2(-100, -100)
var elapsed: float = 0.0
var total_time: float = 0.0
var income: float = 22.0
var income_rate: float = 2.0
var sleeping: bool = false
var bed_level: int = 1
var gate_level: int = 1
var gate_max: float = 150.0
var gate_hp: float = 150.0
var gate_flash: float = 0.0
## Estructuras construidas: Vector2i (baldosa) -> {type, level, cd}.
var structs: Dictionary = {}
var wards: int = 0 # cuántos centinelas hay (se recalcula)
var generator_level: int = 0 # suma de niveles de generadores (se recalcula)
var ward_power: int = 1 # poder global de los centinelas (con energía)
var waves: int = 1
var hunters: Array = []
var spawn_t: float = 0.0
var slain: int = 0
var slain_in_stage: int = 0
var shots: Array = []
var info: String = ""
var info_time: float = 0.0
var font: Font
var title_font: Font
var tick: float = 0.0
var sparks: float = 0.0
var shield_left: float = 0.0
var paused: bool = false
var high_score: int = 0
var best_time: float = 0.0
var best_stage: int = 0
var session_score: int = 0
var rewards: Array = []
var rng := RandomNumberGenerator.new()
## Menú contextual al tocar una baldosa, una estructura, el lecho o la puerta.
var popup: Dictionary = {} # {title, anchor, options: [{id, label, sub, icon, enabled}], tile}
var popup_sel: int = 0
var cursor: Vector2i = Vector2i(5, 3) # baldosa señalada con teclado o mando
var cursor_visible: bool = false
var music: AudioStreamPlayer
var tension: AudioStreamPlayer
var sfx_pool: Array[AudioStreamPlayer] = []
var sfx_streams: Dictionary = {}
var tension_level: float = 0.0
var pad_stick: Vector2i = Vector2i.ZERO
## Tutorial guiado: -1 = apagado; si no, el paso actual de TUT_STEPS.
var tut_step: int = -1
var tutorial_done: bool = false
var tut_flash: float = 0.0 # destello al completar un paso
var tut_sold: int = 0
var tut_repaired: int = 0
const TUT_CARD := Rect2(726, 72, 226, 156)
const TUT_SKIP := Rect2(822, 192, 122, 28)
const START_BTN := Rect2(260, 380, 260, 48)
const TUT_BTN := Rect2(540, 380, 160, 48)
## [título, texto]. Cada paso espera a que hagas lo que pide (ver _tut_done).
const TUT_STEPS := [
    ["BIENVENIDA", "Defiende tu celda: las entidades llegan por el pasillo y golpean la puerta. Toca aquí para seguir."],
    ["1 · DUERME", "Toca el LECHO y elige DORMIR. Mientras duermes ganas ecos, la moneda de la Vigilia."],
    ["2 · AHORRA", "Los ecos suben solos mientras duermes (arriba). Espera a tener 20."],
    ["3 · CONSTRUYE", "Toca la baldosa marcada, junto a la puerta, y construye un CENTINELA."],
    ["4 · DEFIENDE", "¡Llega una entidad! Tu centinela dispara solo a la más cercana a la puerta."],
    ["5 · MEJORA", "Toca tu centinela y elige MEJORAR: dispara más fuerte."],
    ["6 · ENERGÍA", "Toca una baldosa libre y construye un GENERADOR: da energía mientras duermes."],
    ["7 · POTENCIA", "Con energía, toca POTENCIAR (abajo): todos los centinelas suben de poder."],
    ["8 · FRENA", "Construye una CAMPANA: su tañido frena a las entidades del pasillo."],
    ["9 · REFUERZA", "Toca la PUERTA y elige REFORZAR: más vida máxima."],
    ["10 · REPARA", "La puerta está dañada. Toca REPARAR PUERTA (abajo) o tócala a ella."],
    ["11 · ESCUDO", "Toca ESCUDO (abajo): 8 s sin daño en la puerta. Guárdalo para los jefes."],
    ["12 · LECHO", "Toca el LECHO y elige MEJORAR: ganarás más ecos por segundo."],
    ["13 · VENDE", "¿Algo mal puesto? Tócalo y elige VENDER: recuperas la mitad."],
    ["¡LISTO!", "Fases de 90 s, cada una más dura; jefe cada 5. Cada fase da botín para la campaña. Toca aquí para empezar."],
]


func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    font = PIXEL_FONT
    title_font = TITLE_FONT
    for f in [font, title_font]:
        if f is FontFile:
            (f as FontFile).antialiasing = TextServer.FONT_ANTIALIASING_NONE
            (f as FontFile).hinting = TextServer.HINTING_NONE
            (f as FontFile).subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
    rng.randomize()
    _setup_fullscreen()
    _load_records()
    music = AudioStreamPlayer.new()
    tension = AudioStreamPlayer.new()
    add_child(music)
    add_child(tension)
    for i in range(4):
        var player := AudioStreamPlayer.new()
        player.bus = "Efectos"
        add_child(player)
        sfx_pool.append(player)
    Ajustes.preparar_buses()
    music.bus = "Musica"
    tension.bus = "Musica"
    if DisplayServer.get_name() != "headless":
        var templo: AudioStreamOggVorbis = load("res://audio/musica_templo.ogg")
        var capa: AudioStreamOggVorbis = load("res://audio/musica_tension.ogg")
        templo.loop = true
        capa.loop = true
        music.stream = templo
        tension.stream = capa
        music.volume_db = -15.0
        tension.volume_db = -60.0
        music.play()
        tension.play()
        for key in ["alma", "dano", "sello", "puerta", "linterna", "muerte", "interfaz", "toque", "golpe"]:
            sfx_streams[key] = load("res://audio/sfx_%s.ogg" % key)
    queue_redraw()


func _exit_tree() -> void:
    for player in [music, tension] + sfx_pool:
        if is_instance_valid(player):
            player.stop()
            player.stream = null
    sfx_streams.clear()


func _sfx(key: String, volume_db: float = -8.0, pitch: float = 1.0) -> void:
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


# ------------------------------------------------------------ PARTIDA Y FASES
func _start(_choice: int = 0) -> void:
    chamber = 0
    phase = "play"
    stage = 1
    elapsed = 0.0
    total_time = 0.0
    income = 30.0
    income_rate = 2.5
    sparks = 4.0
    ward_power = 1
    shield_left = 0.0
    paused = false
    session_score = 0
    sleeping = false
    bed_level = 1
    gate_level = 1
    gate_max = 210.0
    gate_hp = gate_max
    structs.clear()
    _recount()
    waves = 1
    slain = 0
    rewards.clear()
    popup = {}
    tut_step = -1
    _begin_stage()
    _say("Toca el lecho para dormir y una baldosa libre para construir.")
    queue_redraw()


func _begin_stage() -> void:
    slain_in_stage = 0
    hunters.clear()
    shots.clear()
    elapsed = 0.0
    waves = 1
    spawn_t = 0.0
    _spawn_hunter()


func _next_stage() -> void:
    if phase != "won":
        return
    stage += 1
    phase = "play"
    gate_hp = minf(gate_max, gate_hp + gate_max * 0.25)
    rewards.clear()
    _begin_stage()
    _say("FASE %d. Más fuertes, más rápidas.%s" % [stage, " ¡Viene un JEFE!" if _is_boss_stage() else ""])
    _sfx("sello", -8.0, 0.7)


func _is_boss_stage() -> bool:
    return stage % 5 == 0


## Dificultad: crece cada vez más rápido, sin techo.
func _stage_mult() -> float:
    var n: float = float(stage - 1)
    return 1.0 + 0.7 * n + 0.16 * n * n


func _max_hunters() -> int:
    return mini(6, 1 + stage / 2)


func _spawn_hunter() -> void:
    var boss: bool = _is_boss_stage() and slain_in_stage == 0 and not hunters.any(func(h): return bool(h["boss"]))
    var kind: String
    if boss:
        kind = BOSS_KINDS[(stage / 5 - 1) % BOSS_KINDS.size()]
    elif stage == 1:
        kind = ["ghoul", "wizard", "angel"][(waves - 1) % 3]
    else:
        kind = STAGE_KINDS[(stage + waves + hunters.size()) % STAGE_KINDS.size()]
    var hp: float = (52.0 + float(waves) * 32.0) * 1.6 * (1.25 if kind == "angel" else 1.0) * _stage_mult() * (5.0 if boss else 1.0)
    hunters.append({"x": SPAWN_X + float(hunters.size()) * 40.0, "hp": hp, "max": hp, "kind": kind, "cooldown": 1.0,
        "boss": boss, "hit": 0.0, "lane": rng.randf_range(-40.0, 40.0)})
    if boss:
        _say("¡JEFE! %s se acerca por el pasillo." % _kind_name(kind))
        _sfx("muerte", -10.0, 0.6)


func _kind_name(kind: String) -> String:
    return {"ghoul": "El Ghoul", "wizard": "El Hechicero", "angel": "El Testigo", "mastin": "El Mastín",
        "segador": "El Segador", "tejedora": "La Tejedora", "ariete": "El Ariete"}.get(kind, kind)


func _load_records() -> void:
    if not FileAccess.file_exists(_defense_path()):
        return
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(_defense_path()))
    if parsed is Dictionary:
        high_score = maxi(0, int(parsed.get("high_score", 0)))
        best_time = maxf(0.0, float(parsed.get("best_time", 0.0)))
        best_stage = maxi(0, int(parsed.get("best_stage", 0)))
        tutorial_done = bool(parsed.get("tutorial_done", false))


func _save_records() -> void:
    var file := FileAccess.open(_defense_path(), FileAccess.WRITE)
    if file != null:
        file.store_string(JSON.stringify({"high_score": high_score, "best_time": best_time, "best_stage": best_stage, "tutorial_done": tutorial_done, "version": 3}))


func _record_end(win: bool) -> void:
    var built: int = 0
    for t in structs:
        built += int(structs[t]["level"])
    session_score = slain * 50 + int(total_time) * 3 + (gate_level + bed_level + built + ward_power) * 10 + (300 * stage if win else 0)
    high_score = maxi(high_score, session_score)
    best_time = maxf(best_time, total_time)
    best_stage = maxi(best_stage, stage if win else stage - 1)
    _save_records()


func _say(message: String) -> void:
    info = message
    info_time = 3.5


func _win_stage() -> void:
    phase = "won"
    sleeping = false
    popup = {}
    hunters.clear()
    shots.clear()
    rewards.clear()
    for i in range(2 if _is_boss_stage() else 1):
        var key: String = Botin.sortear(stage, rng)
        Botin.aplicar(key)
        rewards.append(key)
    _record_end(true)
    _sfx("sello", -4.0, 0.8)


# ------------------------------------------------------------ TUTORIAL GUIADO
func _start_tutorial() -> void:
    _start()
    tut_step = 0
    tut_sold = 0
    tut_repaired = 0
    income = 6.0
    sparks = 0.0
    hunters.clear()
    _say("Tutorial: sigue las indicaciones de la derecha.")


## Termina el tutorial y empieza la Vigilia de verdad, desde cero.
func _end_tutorial() -> void:
    tut_step = -1
    tutorial_done = true
    _save_records()
    _start()
    _say("¡Empieza la vigilia! Duerme y construye.")


## Lo que hay que señalar en cada paso (en coordenadas de pantalla).
func _tut_target() -> Rect2:
    match tut_step:
        1, 12:
            return BED.grow(8.0)
        2:
            return Rect2(506, 12, 150, 40)
        3:
            return _tile_rect(Vector2i(9, 3))
        5:
            for t in structs:
                if structs[t]["type"] == "centinela":
                    return _tile_rect(t)
        6, 8:
            var ft: Vector2i = _tut_free_tile()
            return _tile_rect(ft) if ft.x >= 0 else Rect2()
        7:
            return _bottom_rect(2)
        9:
            return DOOR.grow(10.0)
        10:
            return _bottom_rect(1)
        11:
            return _bottom_rect(3)
        13:
            for t in structs:
                return _tile_rect(t)
    return Rect2()


## Una baldosa libre cerca de la puerta para los pasos de construir.
func _tut_free_tile() -> Vector2i:
    for t in [Vector2i(8, 3), Vector2i(9, 2), Vector2i(9, 4), Vector2i(8, 2), Vector2i(8, 4), Vector2i(7, 3)]:
        if not structs.has(t):
            return t
    return _free_tile()


## ¿Se cumplió el paso actual?
func _tut_done() -> bool:
    match tut_step:
        1:
            return sleeping
        2:
            return income >= 20.0
        3:
            return _count("centinela") >= 1
        4:
            return slain >= 1
        5:
            for t in structs:
                if structs[t]["type"] == "centinela" and int(structs[t]["level"]) >= 2:
                    return true
            return false
        6:
            return _count("generador") >= 1
        7:
            return ward_power >= 2
        8:
            return _count("campana") >= 1
        9:
            return gate_level >= 2
        10:
            return tut_repaired > 0 or gate_hp >= gate_max
        11:
            return shield_left > 0.0
        12:
            return bed_level >= 2
        13:
            return tut_sold > 0
    return false


## Al entrar en un paso: lo necesario para poder hacerlo (sin quedarse atascado).
func _tut_enter(step: int) -> void:
    tut_step = step
    tut_flash = 1.0
    popup = {}
    _sfx("sello", -10.0, 1.4)
    match step:
        3:
            income = maxf(income, float(_build_cost("centinela")) + 2.0)
        4:
            hunters.clear()
            _spawn_hunter()
            hunters[0]["hp"] = 60.0
            hunters[0]["max"] = 60.0
            hunters[0]["x"] = 900.0
        5:
            var up: int = 15
            for t in structs:
                if structs[t]["type"] == "centinela":
                    up = _upgrade_cost(t)
            income = maxf(income, float(up) + 2.0)
        6:
            income = maxf(income, float(_build_cost("generador")) + 2.0)
        7:
            sparks = maxf(sparks, _power_cost() + 1.0)
        8:
            income = maxf(income, float(_build_cost("campana")) + 2.0)
        9:
            income = maxf(income, float(_door_cost()) + 2.0)
        10:
            gate_hp = gate_max * 0.55
            gate_flash = 1.0
            income = maxf(income, float(_repair_cost()) + 2.0)
        11:
            sparks = maxf(sparks, 15.0)
        12:
            income = maxf(income, float(_bed_cost()) + 2.0)


func _tut_update(dt: float) -> void:
    tut_flash = maxf(0.0, tut_flash - dt * 2.0)
    if tut_step in [0, TUT_STEPS.size() - 1]:
        return
    if _tut_done():
        _tut_enter(tut_step + 1)


## Toque durante el tutorial: la tarjeta avanza los pasos de leer; SALTAR termina.
func _tut_tap(at: Vector2) -> bool:
    if TUT_SKIP.has_point(at):
        _end_tutorial()
        return true
    if TUT_CARD.has_point(at):
        if tut_step == 0:
            _tut_enter(1)
        elif tut_step == TUT_STEPS.size() - 1:
            _end_tutorial()
        return true
    return false


# ------------------------------------------------------------ CONSTRUCCIÓN
func _tile_rect(t: Vector2i) -> Rect2:
    return Rect2(ROOM.position + Vector2(t) * TILE, Vector2(TILE, TILE))


func _tile_center(t: Vector2i) -> Vector2:
    return _tile_rect(t).get_center()


func _tile_at(at: Vector2) -> Vector2i:
    if not ROOM.has_point(at):
        return Vector2i(-1, -1)
    return Vector2i(int((at.x - ROOM.position.x) / TILE), int((at.y - ROOM.position.y) / TILE))


func _is_bed_tile(t: Vector2i) -> bool:
    return BED_TILES.has_point(t)


func _count(type: String) -> int:
    var n: int = 0
    for t in structs:
        if structs[t]["type"] == type:
            n += 1
    return n


func _recount() -> void:
    wards = _count("centinela")
    generator_level = 0
    for t in structs:
        if structs[t]["type"] == "generador":
            generator_level += int(structs[t]["level"])


func _build_cost(type: String) -> int:
    var s: Array = STRUCTS[type]
    return int(round(float(s[3]) * pow(float(s[4]), float(_count(type)))))


func _upgrade_cost(t: Vector2i) -> int:
    var st: Dictionary = structs[t]
    return int(round(float(STRUCTS[st["type"]][5]) * pow(1.55, float(int(st["level"]) - 1))))


func _bed_cost() -> int:
    return int(round(18.0 * pow(1.35, float(bed_level - 1))))


func _door_cost() -> int:
    return int(round(25.0 * pow(1.35, float(gate_level - 1))))


## Reparar sale más caro cuanto más reforzada está la puerta.
func _repair_cost() -> int:
    return 10 + 8 * gate_level


func _free_tile() -> Vector2i:
    # La baldosa libre más cercana a la puerta (para los atajos de teclado).
    for x in range(COLS - 1, -1, -1):
        for y in [3, 2, 4, 1, 5, 0, 6]:
            var t := Vector2i(x, y)
            if not structs.has(t) and not _is_bed_tile(t):
                return t
    return Vector2i(-1, -1)


func _build(type: String, t: Vector2i) -> bool:
    if phase != "play" or paused or t.x < 0 or structs.has(t) or _is_bed_tile(t):
        return false
    var cost: int = _build_cost(type)
    if income < float(cost):
        _say("Necesitas %d ecos para un %s." % [cost, str(STRUCTS[type][0]).to_lower()])
        _sfx("toque", -10.0, 0.8)
        return false
    income -= float(cost)
    structs[t] = {"type": type, "level": 1, "cd": 0.3}
    _recount()
    _say("%s construido." % _cap(STRUCTS[type][0]))
    _sfx("sello", -10.0, 1.3)
    return true


func _upgrade(t: Vector2i) -> bool:
    if phase != "play" or paused or not structs.has(t):
        return false
    var st: Dictionary = structs[t]
    if int(st["level"]) >= STRUCT_MAX:
        _say("Ya está al nivel máximo (%d)." % STRUCT_MAX)
        return false
    var cost: int = _upgrade_cost(t)
    if income < float(cost):
        _say("Mejorar cuesta %d ecos." % cost)
        _sfx("toque", -10.0, 0.8)
        return false
    income -= float(cost)
    st["level"] = int(st["level"]) + 1
    _recount()
    _say("%s nivel %d." % [_cap(STRUCTS[st["type"]][0]), int(st["level"])])
    _sfx("interfaz", -8.0, 1.2)
    return true


func _sell(t: Vector2i) -> bool:
    if not structs.has(t):
        return false
    var st: Dictionary = structs[t]
    var spent: float = float(STRUCTS[st["type"]][3])
    for l in range(1, int(st["level"])):
        spent += float(STRUCTS[st["type"]][5]) * pow(1.55, float(l - 1))
    income += roundf(spent * 0.5)
    tut_sold += 1
    structs.erase(t)
    _recount()
    _say("Vendido: +%d ecos." % int(roundf(spent * 0.5)))
    _sfx("alma", -9.0, 0.8)
    return true


func _cap(text_value: String) -> String:
    return text_value.substr(0, 1) + text_value.substr(1).to_lower()


## Acciones sueltas (teclas 1-8, botones de abajo y pruebas automáticas).
## 0 dormir · 1 lecho · 2 puerta · 3 centinela · 4 reparar · 5 generador ·
## 6 potenciar · 7 escudo · 8 pausa
func _action(choice: int) -> bool:
    if phase != "play":
        return false
    if choice == 8:
        paused = not paused
        popup = {}
        _say("Vigilia en pausa." if paused else "La vigilia continúa.")
        return true
    if paused:
        return false
    match choice:
        0:
            sleeping = not sleeping
            _say("Duermes: el lecho genera ecos." if sleeping else "Te levantas. Sin ingresos.")
        1:
            var cost: int = _bed_cost()
            if income < float(cost) or bed_level >= BED_MAX:
                _say("Ecos insuficientes o lecho al máximo.")
                return false
            income -= float(cost)
            bed_level += 1
            income_rate = 1.5 + float(bed_level)
            _say("Lecho nivel %d: +%d ecos/s." % [bed_level, int(income_rate)])
        2:
            var cost2: int = _door_cost()
            if income < float(cost2) or gate_level >= DOOR_MAX:
                _say("Faltan ecos para reforzar la puerta.")
                return false
            income -= float(cost2)
            gate_level += 1
            gate_max += 95.0
            gate_hp = minf(gate_max, gate_hp + 120.0)
            _say("Puerta nivel %d." % gate_level)
        3:
            return _build("centinela", _free_tile())
        4:
            if income < float(_repair_cost()) or gate_hp >= gate_max:
                _say("Reparación innecesaria o faltan ecos.")
                return false
            income -= float(_repair_cost())
            tut_repaired += 1
            gate_hp = minf(gate_max, gate_hp + maxf(85.0, gate_max * 0.2))
            _say("La puerta ha sido reparada.")
        5:
            return _build("generador", _free_tile())
        6:
            var cost6: float = _power_cost()
            if sparks < cost6 or wards < 1 or ward_power >= POWER_MAX:
                _say("Necesitas %d de energía y algún centinela." % int(cost6))
                return false
            sparks -= cost6
            ward_power += 1
            _say("Todos los centinelas: poder %d." % ward_power)
        7:
            if sparks < 14.0 or shield_left > 0.0:
                _say("Necesitas 14 de energía y el escudo inactivo.")
                return false
            sparks -= 14.0
            shield_left = 8.0
            _say("Escudo: 8 segundos sin daño en la puerta.")
        _:
            return false
    _sfx("interfaz", -10.0, 1.0)
    return true


# ------------------------------------------------------------ MENÚ CONTEXTUAL
func _open_popup_for(t: Vector2i) -> void:
    cursor = t
    if t.x < 0:
        popup = {}
        return
    if t.x >= COLS:
        _open_door_popup()
        return
    var opts: Array = []
    var title: String
    if _is_bed_tile(t):
        title = "LECHO · NV %d/%d" % [bed_level, BED_MAX]
        opts.append({"id": "dormir", "label": "LEVANTARSE" if sleeping else "DORMIR", "sub": "+%d ecos/s" % int(income_rate), "icon": "levantar" if sleeping else "descansar", "enabled": true})
        opts.append({"id": "lecho", "label": "MEJORAR", "sub": "MÁXIMO" if bed_level >= BED_MAX else "%d ecos" % _bed_cost(), "icon": "lecho", "enabled": bed_level < BED_MAX and income >= float(_bed_cost())})
    elif structs.has(t):
        var st: Dictionary = structs[t]
        var s: Array = STRUCTS[st["type"]]
        title = "%s · NV %d/%d" % [s[0], int(st["level"]), STRUCT_MAX]
        var maxed: bool = int(st["level"]) >= STRUCT_MAX
        opts.append({"id": "mejorar", "label": "MEJORAR", "sub": "MÁXIMO" if maxed else "%d ecos" % _upgrade_cost(t), "icon": s[1], "enabled": not maxed and income >= float(_upgrade_cost(t))})
        opts.append({"id": "vender", "label": "VENDER", "sub": "+50 %", "icon": "vender", "enabled": true})
    else:
        title = "CONSTRUIR"
        for type in ["centinela", "generador", "campana"]:
            opts.append({"id": type, "label": STRUCTS[type][0], "sub": "%d ecos" % _build_cost(type), "icon": STRUCTS[type][1], "enabled": income >= float(_build_cost(type))})
    popup = {"title": title, "tile": t, "anchor": _tile_center(t), "options": opts}
    popup_sel = 0
    _sfx("toque", -14.0, 1.1)


func _open_door_popup() -> void:
    var opts: Array = [
        {"id": "reparar", "label": "REPARAR", "sub": "%d ecos" % _repair_cost(), "icon": "reparar", "enabled": income >= float(_repair_cost()) and gate_hp < gate_max},
        {"id": "puerta", "label": "REFORZAR", "sub": "MÁXIMO" if gate_level >= DOOR_MAX else "%d ecos" % _door_cost(), "icon": "puerta", "enabled": gate_level < DOOR_MAX and income >= float(_door_cost())},
    ]
    popup = {"title": "PUERTA · NV %d/%d" % [gate_level, DOOR_MAX], "tile": Vector2i(-1, -1), "anchor": DOOR.get_center() + Vector2(-90, 0), "options": opts}
    popup_sel = 0
    _sfx("toque", -14.0, 1.1)


func _popup_rect() -> Rect2:
    var n: int = (popup["options"] as Array).size()
    var size := Vector2(float(n) * 96.0 + 12.0, 128.0)
    var a: Vector2 = popup["anchor"]
    var pos := Vector2(a.x - size.x * 0.5, a.y - size.y - 34.0)
    if pos.y < 70.0:
        pos.y = a.y + 34.0
    pos.x = clampf(pos.x, 8.0, W - size.x - 8.0)
    return Rect2(pos, size)


func _popup_option_rect(i: int) -> Rect2:
    var r := _popup_rect()
    return Rect2(r.position.x + 6.0 + float(i) * 96.0, r.position.y + 28.0, 90.0, 94.0)


func _popup_choose(i: int) -> void:
    var opts: Array = popup["options"]
    if i < 0 or i >= opts.size():
        return
    var id: String = opts[i]["id"]
    var t: Vector2i = popup["tile"]
    var keep: bool = true
    match id:
        "dormir":
            _action(0)
            keep = false
        "lecho":
            _action(1)
        "reparar":
            _action(4)
        "puerta":
            _action(2)
        "mejorar":
            _upgrade(t)
        "vender":
            _sell(t)
            keep = false
        _:
            _build(id, t)
    # Se queda abierto para seguir mejorando, con los precios nuevos.
    if keep and not popup.is_empty():
        var sel: int = popup_sel
        if t.x >= 0:
            _open_popup_for(t)
        else:
            _open_door_popup()
        popup_sel = sel
    else:
        popup = {}


func _process(delta: float) -> void:
    tick += delta
    info_time = maxf(0.0, info_time - delta)
    gate_flash = maxf(0.0, gate_flash - delta * 3.0)
    for s in shots:
        s["t"] = float(s["t"]) - delta
    shots = shots.filter(func(s): return float(s["t"]) > 0.0)
    if phase == "play" and not paused:
        _advance(delta)
    if tension != null and tension.stream != null:
        var target: float = 0.0
        if phase == "play" and not hunters.is_empty():
            target = clampf((900.0 - _front_x()) / 165.0, 0.0, 1.0) * 0.6 + (1.0 - clampf(gate_hp / gate_max, 0.0, 1.0)) * 0.5
        tension_level = move_toward(tension_level, clampf(target, 0.0, 1.0), delta * 0.5)
        tension.volume_db = linear_to_db(maxf(tension_level, 0.001)) - 8.0
    queue_redraw()


func _front_x() -> float:
    var x: float = SPAWN_X
    for h in hunters:
        x = minf(x, float(h["x"]))
    return x


## Freno de las campanas: 5 % por nivel, hasta el 45 %.
func _slow_factor() -> float:
    var lv: int = 0
    for t in structs:
        if structs[t]["type"] == "campana":
            lv += int(structs[t]["level"])
    return clampf(1.0 - 0.05 * float(lv), 0.55, 1.0)


func _advance(dt: float) -> void:
    var tutorial: bool = tut_step >= 0
    if not tutorial:
        elapsed += dt
        total_time += dt
    waves = 1 + int(elapsed / 25.0)
    shield_left = maxf(0.0, shield_left - dt)
    if sleeping:
        income += dt * income_rate
        sparks += dt * float(generator_level) * 0.45
    if tutorial:
        _tut_update(dt)
        if tut_step < 0:
            return
    if not tutorial and elapsed >= PHASE_LENGTH:
        _win_stage()
        return
    spawn_t -= dt
    if not tutorial and spawn_t <= 0.0 and hunters.size() < _max_hunters():
        _spawn_hunter()
        spawn_t = maxf(2.0, 8.0 - float(stage) * 0.5)
    var slow: float = _slow_factor()
    var speed: float = (28.0 + float(waves) * 6.5) * (1.0 + 0.06 * float(stage - 1)) * slow
    var dmg: float = (14.0 + float(waves) * 4.0) * (1.0 + 0.3 * float(stage - 1) + 0.03 * pow(float(stage - 1), 2.0))
    for i in range(hunters.size()):
        var h: Dictionary = hunters[i]
        h["hit"] = maxf(0.0, float(h["hit"]) - dt)
        var stop: float = DOOR_X + float(i) * 26.0
        h["x"] = maxf(stop, float(h["x"]) - speed * (0.8 if bool(h["boss"]) else 1.0) * dt)
        if float(h["x"]) <= stop + 0.5:
            h["cooldown"] = float(h["cooldown"]) - dt
            if float(h["cooldown"]) <= 0.0:
                h["cooldown"] = maxf(0.4, 1.75 - float(waves) * 0.10 - 0.05 * float(stage - 1)) / slow
                if shield_left <= 0.0:
                    gate_hp -= dmg * (2.0 if bool(h["boss"]) else 1.0)
                    gate_flash = 1.0
                    _sfx("puerta", -9.0, 1.3)
    # Cada centinela dispara por su cuenta a la entidad más adelantada.
    if not hunters.is_empty() and _front_x() < 938.0:
        for t in structs:
            var st: Dictionary = structs[t]
            if st["type"] != "centinela":
                continue
            st["cd"] = float(st["cd"]) - dt
            if float(st["cd"]) > 0.0 or hunters.is_empty():
                continue
            st["cd"] = 0.58
            var target_i: int = 0
            for i in range(hunters.size()):
                if float(hunters[i]["x"]) < float(hunters[target_i]["x"]):
                    target_i = i
            var tg: Dictionary = hunters[target_i]
            tg["hp"] = float(tg["hp"]) - _ward_damage(int(st["level"]))
            tg["hit"] = 0.15
            shots.append({"from": _tile_center(t) + Vector2(0, -22), "to": Vector2(float(tg["x"]), 300.0 + float(tg["lane"])), "t": 0.12})
            if float(tg["hp"]) <= 0.0:
                slain += 1
                slain_in_stage += 1
                income += (9.0 + float(waves) * 2.0) * (1.0 + 0.1 * float(stage - 1)) * (3.0 if bool(tg["boss"]) else 1.0)
                hunters.remove_at(target_i)
                if hunters.is_empty():
                    spawn_t = maxf(spawn_t, 2.4)
                _say("¡JEFE derrotado!" if bool(tg["boss"]) else "Entidad repelida. Ecos recuperados.")
                _sfx("alma", -7.0)
    if tutorial:
        gate_hp = maxf(gate_hp, 1.0) # en el tutorial la puerta no cae
    if gate_hp <= 0.0:
        gate_hp = 0.0
        _record_end(false)
        sleeping = false
        popup = {}
        phase = "lost"
        _sfx("muerte", -4.0)
        _say("La puerta ha cedido.")


## Potenciar cuesta cada vez más energía.
func _power_cost() -> float:
    return roundf(6.0 * float(ward_power) * (1.0 + 0.25 * float(ward_power - 1)))


## Daño de un centinela: crece con su nivel y con el poder global, sin dispararse.
func _ward_damage(level: int) -> float:
    return 12.0 * (1.0 + 0.6 * float(level - 1)) * (1.0 + 0.12 * float(ward_power - 1))


## Para las pruebas: una entidad justo en la puerta, a punto de golpear.
func _debug_hunter_at_door() -> void:
    hunters.clear()
    _spawn_hunter()
    hunters[0]["x"] = DOOR_X
    hunters[0]["cooldown"] = 0.0


# ------------------------------------------------------------ ENTRADA
func _bottom_rect(i: int) -> Rect2:
    return Rect2(6.0 + float(i) * 238.0, 512.0, 230.0, 120.0)


func _input(event: InputEvent) -> void:
    if event is InputEventJoypadButton and event.pressed:
        _pad_button(event.button_index)
        queue_redraw()
        return
    if event is InputEventJoypadMotion and (event.axis == JOY_AXIS_LEFT_X or event.axis == JOY_AXIS_LEFT_Y):
        var v: float = event.axis_value
        var d := Vector2i.ZERO
        if absf(v) > 0.55:
            d = Vector2i(signi(roundi(v)), 0) if event.axis == JOY_AXIS_LEFT_X else Vector2i(0, signi(roundi(v)))
        var cur := Vector2i(d.x if event.axis == JOY_AXIS_LEFT_X else pad_stick.x, d.y if event.axis == JOY_AXIS_LEFT_Y else pad_stick.y)
        if cur != pad_stick:
            pad_stick = cur
            if d != Vector2i.ZERO:
                _move_cursor(d)
        return
    if event is InputEventScreenTouch:
        if event.pressed:
            _tap(make_input_local(event).position)
    elif event is InputEventMouseButton:
        # El toque ya llegó como InputEventScreenTouch: el clic emulado se ignora
        # (si no, cada toque contaba dos veces: dormir y levantarse a la vez).
        if event.device == InputEvent.DEVICE_ID_EMULATION:
            return
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            _tap(make_input_local(event).position)
    elif event is InputEventMouseMotion:
        hover_pos = make_input_local(event).position
        cursor_visible = false
    elif event is InputEventKey and event.pressed and not event.echo:
        _key(event.keycode)
    queue_redraw()


func _key(k: Key) -> void:
    if k == KEY_ESCAPE:
        if not popup.is_empty():
            popup = {}
        else:
            _leave()
        return
    match phase:
        "selection":
            if k in [KEY_ENTER, KEY_SPACE]:
                _choose_start()
            elif k == KEY_T:
                _start_tutorial()
            return
        "won":
            if k in [KEY_ENTER, KEY_SPACE]:
                _next_stage()
            return
        "lost":
            if k == KEY_ENTER:
                _start(chamber)
            return
    if tut_step >= 0 and k == KEY_ENTER and tut_step in [0, TUT_STEPS.size() - 1] and popup.is_empty():
        _tut_tap(TUT_CARD.get_center())
        return
    if tut_step >= 0 and k == KEY_BACKSPACE:
        _end_tutorial()
        return
    if k == KEY_P:
        _action(8)
    elif k in [KEY_LEFT, KEY_A]:
        _move_cursor(Vector2i(-1, 0))
    elif k in [KEY_RIGHT, KEY_D]:
        _move_cursor(Vector2i(1, 0))
    elif k in [KEY_UP, KEY_W]:
        _move_cursor(Vector2i(0, -1))
    elif k in [KEY_DOWN, KEY_S]:
        _move_cursor(Vector2i(0, 1))
    elif k in [KEY_ENTER, KEY_E]:
        if popup.is_empty():
            _open_popup_for(cursor)
        else:
            _popup_choose(popup_sel)
    elif k == KEY_SPACE:
        _action(0)
    elif k >= KEY_1 and k <= KEY_8:
        if not popup.is_empty() and int(k) - int(KEY_1) < (popup["options"] as Array).size():
            _popup_choose(int(k) - int(KEY_1))
        else:
            _action(int(k) - int(KEY_1))


## Teclado y mando: un recuadro recorre las baldosas (más allá de la última
## columna está la puerta); con el menú abierto, izquierda y derecha eligen.
func _move_cursor(d: Vector2i) -> void:
    cursor_visible = true
    if not popup.is_empty() and d.y == 0:
        popup_sel = clampi(popup_sel + d.x, 0, (popup["options"] as Array).size() - 1)
        return
    popup = {}
    cursor = Vector2i(clampi(cursor.x + d.x, 0, COLS), clampi(cursor.y + d.y, 0, ROWS - 1))
    _sfx("toque", -18.0, 1.3)


func _pad_button(b: int) -> void:
    match b:
        JOY_BUTTON_DPAD_LEFT:
            _key(KEY_LEFT)
        JOY_BUTTON_DPAD_RIGHT:
            _key(KEY_RIGHT)
        JOY_BUTTON_DPAD_UP:
            _key(KEY_UP)
        JOY_BUTTON_DPAD_DOWN:
            _key(KEY_DOWN)
        JOY_BUTTON_A:
            _key(KEY_ENTER)
        JOY_BUTTON_Y:
            if phase == "play":
                _action(0)
            elif phase == "selection":
                _start_tutorial()
        JOY_BUTTON_X:
            if phase == "play":
                _action(7)
        JOY_BUTTON_RIGHT_SHOULDER:
            if phase == "play":
                _action(6)
        JOY_BUTTON_START:
            if phase == "play":
                _action(8)
            else:
                _key(KEY_ENTER)
        JOY_BUTTON_B, JOY_BUTTON_BACK:
            _key(KEY_ESCAPE)


func _tap(at: Vector2) -> void:
    hover_pos = at
    cursor_visible = false
    if EXIT_RECT.has_point(at):
        _leave()
        return
    if phase == "selection":
        if TUT_BTN.grow(6.0).has_point(at):
            if tutorial_done:
                _start_tutorial()
            else:
                tutorial_done = true # «saltar tutorial»
                _save_records()
                _start()
        elif at.y > 270.0 and at.y < 515.0:
            _choose_start()
        return
    if phase == "won":
        if at.y > 300.0:
            _next_stage()
        return
    if phase == "lost":
        if at.y > 350.0:
            _start(chamber)
        return
    if phase != "play":
        return
    if PAUSE_RECT.has_point(at):
        _action(8)
        return
    if paused:
        return
    if tut_step >= 0 and _tut_tap(at):
        return
    if not popup.is_empty():
        for i in range((popup["options"] as Array).size()):
            if _popup_option_rect(i).has_point(at):
                popup_sel = i
                _popup_choose(i)
                return
        if _popup_rect().has_point(at):
            return
        popup = {}
    if at.y >= 512.0:
        var i: int = clampi(int((at.x - 6.0) / 238.0), 0, 3)
        _action([0, 4, 6, 7][i])
        return
    if DOOR.grow(18.0).has_point(at):
        _open_door_popup()
        return
    var t: Vector2i = _tile_at(at)
    if t.x >= 0:
        _open_popup_for(t)


## Empezar: la primera vez, con el tutorial guiado.
func _choose_start() -> void:
    if tutorial_done:
        _start()
    else:
        _start_tutorial()


func _leave() -> void:
    get_tree().change_scene_to_file("res://scenes/main.tscn")


func _defense_path() -> String:
    return DEFENSE_SAVE_TEST if Engine.has_meta("modo_prueba") else DEFENSE_SAVE


# ------------------------------------------------------------ DIBUJO
func _draw() -> void:
    # De lado a lado: el fondo de la celda ocupa toda la pantalla, sin recuadro.
    draw_rect(Rect2(-screen_pad.x, -screen_pad.y, W + screen_pad.x * 2.0, H + screen_pad.y * 2.0), Color("#07060a"))
    _draw_room()
    _draw_corridor()
    _draw_door()
    _draw_bed()
    for t in structs:
        _draw_struct(t)
    _draw_tile_hint()
    _draw_hunters()
    _draw_shots()
    _draw_vignette()
    _draw_top_bar()
    _draw_bottom_bar()
    if info_time > 0.0 and phase == "play" and popup.is_empty():
        _pill(info, Vector2(ROOM.get_center().x, ROOM.end.y - 18.0), 13, GOLD_HI)
    if tut_step >= 0 and phase == "play":
        _draw_tutorial()
    if not popup.is_empty() and phase == "play":
        _draw_popup()
    match phase:
        "selection":
            _draw_selection()
        "won":
            _draw_reward()
        "lost":
            _draw_lost()
    if paused and phase == "play":
        _modal(Rect2(240, 200, 480, 150))
        _title("En pausa", Vector2(240, 262), 40, CREAM, 480.0)
        _center_text("Toca PAUSA o pulsa P para seguir", 312, 15, GOLD_HI)


func _draw_room() -> void:
    var r := ROOM
    draw_rect(r.grow(14.0), Color("#1a1620"))
    for y in range(ROWS):
        for x in range(COLS):
            var tile := _tile_rect(Vector2i(x, y))
            draw_rect(tile, Color("#2a2630") if (x + y) % 2 == 0 else Color("#25212b"))
            draw_rect(Rect2(tile.position, Vector2(TILE, 2)), Color(1, 1, 1, 0.03))
            draw_rect(tile, Color(0, 0, 0, 0.25), false, 1.0)
    var rug := Rect2(BED.position - Vector2(12, 12), BED.size + Vector2(24, 24))
    draw_rect(rug, Color("#3b2550"))
    draw_rect(rug.grow(-5.0), Color("#4a2e63"), false, 2.0)
    draw_rect(Rect2(r.position.x - 14, r.position.y - 14, r.size.x + 28, 14), Color("#3a3440"))
    for x in range(0, int(r.size.x + 28), 28):
        draw_rect(Rect2(r.position.x - 14 + x, r.position.y - 14, 26, 6), Color("#4a4352"))
    draw_rect(r.grow(14.0), Color("#120f16"), false, 3.0)
    for c in [r.position + Vector2(10, 10), Vector2(r.position.x + 10, r.end.y - 10)]:
        var flick: float = 0.5 + 0.5 * sin(tick * 7.0 + c.y) * sin(tick * 2.3)
        for k in range(4, 0, -1):
            draw_circle(c, 8.0 + float(k) * 9.0, Color(1.0, 0.75, 0.4, 0.025 + 0.01 * flick))
    if sleeping:
        for k in range(5, 0, -1):
            draw_circle(BED.get_center(), 40.0 + float(k) * 18.0, Color(0.56, 0.78, 0.84, 0.025))


func _draw_corridor() -> void:
    var c := Rect2(ROOM.end.x + 14.0, ROOM.position.y - 14.0, W - ROOM.end.x - 14.0, ROOM.size.y + 28.0)
    draw_rect(c, Color("#100d14"))
    for y in range(int(c.position.y), int(c.end.y), 28):
        draw_rect(Rect2(c.position.x, float(y), c.size.x, 1), Color(1, 1, 1, 0.025))
    var flick: float = 1.0 if fmod(tick, 3.7) > 0.25 else 0.2
    var lamp := Vector2(c.get_center().x + 40.0, c.position.y + 20.0)
    for k in range(5, 0, -1):
        draw_circle(lamp + Vector2(0, 60), 30.0 + float(k) * 22.0, Color(0.7, 0.85, 0.9, 0.02 * flick))
    draw_circle(lamp + Vector2(0, 6), 4.0, Color(0.8, 0.95, 1.0, 0.9 * flick))
    if _slow_factor() < 1.0:
        # Ondas de las campanas en el pasillo.
        for k in range(3):
            var rr: float = fmod(tick * 60.0 + float(k) * 50.0, 150.0)
            draw_arc(Vector2(c.position.x + 20.0, c.get_center().y), rr, -1.2, 1.2, 24, Color(0.9, 0.85, 0.6, 0.25 * (1.0 - rr / 150.0)), 2.0)
    _pill("PASILLO", Vector2(c.get_center().x, c.end.y - 14.0), 11, Color("#6d6772"))


func _draw_door() -> void:
    var d := DOOR
    draw_rect(d.grow(4.0), Color("#3a3440"))
    draw_rect(d, Color("#5a3f2c").lerp(CRIMSON, gate_flash * 0.6))
    for i in range(3):
        draw_line(Vector2(d.position.x + 5 + i * 7, d.position.y), Vector2(d.position.x + 5 + i * 7, d.end.y), Color("#3b281b"), 1.0)
    for y in [d.position.y + 18, d.end.y - 24]:
        draw_rect(Rect2(d.position.x, y, d.size.x, 6), Color("#2b2d2e"))
    var damage: float = 1.0 - clampf(gate_hp / gate_max, 0.0, 1.0)
    if damage > 0.3:
        draw_polyline(PackedVector2Array([d.position + Vector2(6, 30), d.position + Vector2(16, 50), d.position + Vector2(8, 72)]), Color("#120c08"), 2.0)
    if damage > 0.65:
        draw_polyline(PackedVector2Array([d.position + Vector2(18, 80), d.position + Vector2(8, 96), d.position + Vector2(16, 110)]), Color("#120c08"), 2.0)
    if shield_left > 0.0:
        draw_rect(d.grow(8.0), Color(0.56, 0.86, 0.95, 0.18 + 0.08 * sin(tick * 8.0)))
    var bar := Rect2(d.get_center().x - 60.0, d.position.y - 34.0, 120, 12)
    draw_rect(bar.grow(2.0), Color(0, 0, 0, 0.8))
    draw_rect(bar, Color("#3a1a20"))
    draw_rect(Rect2(bar.position, Vector2(bar.size.x * clampf(gate_hp / gate_max, 0.0, 1.0), bar.size.y)), Color("#c9a25e") if gate_hp / gate_max > 0.35 else CRIMSON)
    _text_center("%d/%d" % [int(gate_hp), int(gate_max)], Rect2(bar.position.x, bar.position.y - 1.0, bar.size.x, 12), 10, CREAM)
    _pill("NV %d" % gate_level, Vector2(d.get_center().x, d.end.y + 18.0), 11, GOLD_HI)
    if cursor_visible and cursor.x >= COLS and phase == "play":
        draw_rect(d.grow(10.0), GOLD_HI, false, 2.0)


func _draw_bed() -> void:
    var b := BED
    draw_rect(Rect2(b.position + Vector2(5, 7), b.size), Color(0, 0, 0, 0.4))
    draw_rect(b, Color("#4a3426"))
    draw_rect(Rect2(b.position, Vector2(b.size.x, 8)), Color("#6b4c37"))
    draw_rect(b.grow(-7.0), Color("#2c2a3a"))
    draw_rect(Rect2(b.position.x + 14, b.position.y + 14, b.size.x - 28, 34), Color("#d9d2ba"))
    var blanket := Rect2(b.position.x + 10, b.position.y + 56, b.size.x - 20, b.size.y - 66)
    draw_rect(blanket, Color("#4a2e63") if not sleeping else Color("#5b3a7a"))
    draw_rect(b, Color("#1b130d"), false, 2.0)
    if sleeping:
        draw_texture_rect_region(HERO, Rect2(b.get_center().x - 20.0, b.position.y + 6.0, 40, 56), Rect2(0, 0, 40, 56))
        for k in range(3):
            var z: float = fmod(tick + float(k) * 0.7, 2.1)
            _label("z", Vector2(b.end.x - 10.0 + z * 12.0, b.position.y + 10.0 - z * 18.0), 12 + k * 3, Color(SOUL.r, SOUL.g, SOUL.b, 1.0 - z * 0.45))
    else:
        draw_texture_rect_region(HERO, Rect2(b.end.x + 6.0, b.get_center().y - 28.0, 40, 56), Rect2(0, 0, 40, 56))
    _pill("NV %d · %s" % [bed_level, ("+%d/s" % int(income_rate)) if sleeping else "TOCA: DORMIR"], Vector2(b.get_center().x, b.end.y + 22.0), 11, SOUL if sleeping else GOLD_HI)


func _draw_struct(t: Vector2i) -> void:
    var st: Dictionary = structs[t]
    var c: Vector2 = _tile_center(t)
    var lv: int = int(st["level"])
    var tile := _tile_rect(t)
    draw_rect(tile.grow(-3.0), Color(0.72, 0.58, 0.35, 0.08))
    match str(st["type"]):
        "centinela":
            draw_rect(Rect2(c.x - 14, c.y + 8, 28, 12), Color("#4a4352"))
            var bob: float = sin(tick * 2.4 + c.x * 0.05) * 3.0
            var k := c + Vector2(0, -10 + bob)
            var glow: float = 0.04 + 0.012 * float(lv)
            for r in range(3, 0, -1):
                draw_circle(k, 6.0 + float(r) * 6.0, Color(SOUL.r, SOUL.g, SOUL.b, glow))
            var s: float = 0.8 + 0.04 * float(lv)
            draw_colored_polygon(PackedVector2Array([k + Vector2(0, -18) * s, k, k + Vector2(0, 16) * s, k + Vector2(-10, -1) * s]), Color("#bfe9f2"))
            draw_colored_polygon(PackedVector2Array([k + Vector2(0, -18) * s, k + Vector2(10, -1) * s, k + Vector2(0, 16) * s, k]), Color("#5ea7bb"))
        "generador":
            draw_rect(Rect2(c - Vector2(18, 14), Vector2(36, 30)), Color("#8a6a3a"))
            draw_rect(Rect2(c - Vector2(18, 14), Vector2(36, 4)), Color("#c9a25e"))
            var spin: float = tick * (3.0 if sleeping else 0.6)
            draw_circle(c + Vector2(0, 2), 9.0, Color("#3a2a1a"))
            draw_line(c + Vector2(0, 2) + Vector2.from_angle(spin) * 8.0, c + Vector2(0, 2) - Vector2.from_angle(spin) * 8.0, GOLD_HI, 2.0)
        "campana":
            var sway: float = sin(tick * 3.0) * 0.25
            draw_rect(Rect2(c.x - 18, c.y - 22, 36, 4), Color("#4a4352"))
            draw_set_transform(c + Vector2(0, -20), sway, Vector2.ONE)
            draw_colored_polygon(PackedVector2Array([Vector2(-6, 4), Vector2(6, 4), Vector2(14, 28), Vector2(-14, 28)]), Color("#c9a25e"))
            draw_rect(Rect2(-14, 26, 28, 4), Color("#e3bd7b"))
            draw_circle(Vector2(0, 32), 3.0, Color("#6a5030"))
            draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
    _pill(str(lv), tile.position + Vector2(TILE - 12.0, TILE - 8.0), 10, GOLD_HI if lv < STRUCT_MAX else Color("#ffd36b"))


## Baldosa señalada (cursor de ratón, teclado o mando).
func _draw_tile_hint() -> void:
    if phase != "play" or paused:
        return
    var t: Vector2i = cursor if cursor_visible else _tile_at(hover_pos)
    if not popup.is_empty():
        t = popup["tile"]
    if t.x < 0 or t.x >= COLS:
        return
    var r := _tile_rect(t) if not _is_bed_tile(t) else BED.grow(6.0)
    var a: float = 0.6 + 0.4 * sin(tick * 6.0)
    draw_rect(r, Color(GOLD_HI.r, GOLD_HI.g, GOLD_HI.b, a), false, 2.0)
    if not structs.has(t) and not _is_bed_tile(t) and popup.is_empty():
        draw_line(r.get_center() + Vector2(-8, 0), r.get_center() + Vector2(8, 0), Color(CREAM.r, CREAM.g, CREAM.b, a), 2.0)
        draw_line(r.get_center() + Vector2(0, -8), r.get_center() + Vector2(0, 8), Color(CREAM.r, CREAM.g, CREAM.b, a), 2.0)


func _draw_hunters() -> void:
    for h in hunters:
        var boss: bool = bool(h["boss"])
        var scale: float = 1.6 if boss else 1.2
        var x: float = float(h["x"])
        var y: float = 300.0 + float(h["lane"]) + sin(tick * 2.0 + x * 0.02) * 3.0
        var sheet: Texture2D = MONSTER_SHEETS[h["kind"]]
        var at_door: bool = x <= DOOR_X + 160.0 and float(h["cooldown"]) < 0.3
        var frame: int = 2 + int(tick * 8.0) % 4
        if h["kind"] == "angel":
            frame = int(tick * 6.0) % 4
        elif at_door:
            frame = 6 + int(tick * 6.0) % 2
        var size := Vector2(48, 64) * scale
        draw_set_transform(Vector2(x, y + size.y * 0.45), 0.0, Vector2(1.0, 0.32))
        draw_circle(Vector2.ZERO, 18.0 * scale, Color(0, 0, 0, 0.3))
        draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
        if boss:
            for k in range(3, 0, -1):
                draw_circle(Vector2(x, y), 30.0 + float(k) * 10.0, Color(0.8, 0.1, 0.15, 0.05))
        var tint := Color(1, 0.55, 0.55) if float(h["hit"]) > 0.0 else Color.WHITE
        draw_texture_rect_region(sheet, Rect2(Vector2(x, y) - size * 0.5, size), Rect2(frame * 48.0, 3.0 * 64.0, 48.0, 64.0), tint)
        var bar := Rect2(x - 30.0 * scale, y - size.y * 0.55 - 8.0, 60.0 * scale, 6)
        bar.position.x = clampf(bar.position.x, 4.0, W - bar.size.x - 4.0)
        draw_rect(bar.grow(1.0), Color(0, 0, 0, 0.7))
        draw_rect(Rect2(bar.position, Vector2(bar.size.x * clampf(float(h["hp"]) / float(h["max"]), 0.0, 1.0), bar.size.y)), CRIMSON)
        if boss:
            _pill("JEFE", Vector2(bar.get_center().x, bar.position.y - 10.0), 11, Color("#ff8a8a"))


func _draw_shots() -> void:
    for s in shots:
        var a: float = clampf(float(s["t"]) / 0.12, 0.0, 1.0)
        draw_line(s["from"], s["to"], Color(0.75, 0.95, 1.0, 0.7 * a), 2.0)
        draw_circle(s["to"], 5.0 * a, Color(0.85, 0.97, 1.0, a))


func _draw_vignette() -> void:
    for k in range(6):
        var g: float = float(k) * 8.0
        draw_rect(Rect2(g - screen_pad.x, g - screen_pad.y, W + screen_pad.x * 2.0 - g * 2.0, H + screen_pad.y * 2.0 - g * 2.0), Color(0, 0, 0, 0.06), false, 8.0)


func _draw_top_bar() -> void:
    draw_rect(Rect2(-screen_pad.x, -screen_pad.y, W + screen_pad.x * 2.0, 64 + screen_pad.y), Color(0.02, 0.018, 0.03, 0.95))
    draw_rect(Rect2(-screen_pad.x, 62, W + screen_pad.x * 2.0, 2), GOLD)
    _title("Vigilia", Vector2(16, 44), 36, CREAM, -1.0)
    var badge := Rect2(150, 12, 110, 40)
    _panel_box(badge, Color("#4a1a24") if _is_boss_stage() else VIOLET, GOLD_HI)
    _text_center("FASE %d" % stage, Rect2(badge.position.x, badge.position.y + 4.0, badge.size.x, 20), 18, CREAM)
    _text_center("JEFE" if _is_boss_stage() else "BOTÍN NIVEL %d" % Botin.nivel(stage), Rect2(badge.position.x, badge.position.y + 23.0, badge.size.x, 12), 9, GOLD_HI)
    var bar := Rect2(272, 32, 220, 10)
    draw_rect(bar.grow(2.0), Color(0, 0, 0, 0.8))
    draw_rect(Rect2(bar.position, Vector2(bar.size.x * clampf(elapsed / PHASE_LENGTH, 0.0, 1.0), bar.size.y)), SOUL)
    _label("%d / %d s" % [int(elapsed), int(PHASE_LENGTH)], Vector2(272, 24), 12, CREAM)
    _chip(Rect2(506, 12, 150, 40), "alma", "%d" % int(income), "+%d/s" % int(income_rate) if sleeping else "¡duerme!", SOUL)
    _chip(Rect2(664, 12, 150, 40), "generador", "%d" % int(sparks), "energía", GOLD_HI)
    if phase == "play":
        _round_button(PAUSE_RECT, "reanudar" if paused else "pausa", PAUSE_RECT.has_point(hover_pos))
    _round_button(EXIT_RECT, "salir", EXIT_RECT.has_point(hover_pos))


## Abajo, solo lo que se usa a menudo; el resto se toca en la celda.
func _draw_bottom_bar() -> void:
    draw_rect(Rect2(-screen_pad.x, 504, W + screen_pad.x * 2.0, H - 504 + screen_pad.y), Color(0.02, 0.018, 0.03, 0.95))
    draw_rect(Rect2(-screen_pad.x, 504, W + screen_pad.x * 2.0, 2), GOLD)
    var items := [
        ["levantar" if sleeping else "descansar", "LEVANTARSE" if sleeping else "DORMIR", "ESPACIO / Y", true],
        ["reparar", "REPARAR PUERTA", "%d ecos" % _repair_cost(), income >= float(_repair_cost()) and gate_hp < gate_max],
        ["potenciar", "POTENCIAR", "%d energía · poder %d" % [int(_power_cost()), ward_power], sparks >= _power_cost() and wards > 0 and ward_power < POWER_MAX],
        ["escudo", "ESCUDO", "14 energía", sparks >= 14.0 and shield_left <= 0.0],
    ]
    for i in range(items.size()):
        var r := _bottom_rect(i)
        var it: Array = items[i]
        var hot: bool = r.has_point(hover_pos)
        var can: bool = bool(it[3]) and phase == "play"
        var glow: bool = i == 0 and not sleeping and phase == "play"
        _panel_box(r, Color("#2a1d36") if glow else (Color("#241c2c") if hot else Color("#141018")), GOLD_HI if hot or glow else (GOLD if can else EDGE))
        draw_texture_rect(ICONS[it[0]], Rect2(r.position + Vector2(16, 24), Vector2(64, 64)), false, Color.WHITE if can else Color(0.45, 0.45, 0.5, 0.8))
        draw_string(font, r.position + Vector2(92, 52), it[1], HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 96.0, 15, CREAM)
        draw_string(font, r.position + Vector2(92, 76), ("TOCA" if DisplayServer.is_touchscreen_available() else it[2]) if i == 0 else it[2], HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 96.0, 12, SOUL if can else Color("#6d6772"))
    if phase == "play" and structs.is_empty() and popup.is_empty() and tut_step < 0:
        var a: float = 0.6 + 0.4 * sin(tick * 3.0)
        _pill("Toca cualquier baldosa libre para construir · toca algo construido para mejorarlo", Vector2(ROOM.get_center().x, ROOM.position.y + 16.0), 12, Color(GOLD_HI.r, GOLD_HI.g, GOLD_HI.b, a))


func _draw_popup() -> void:
    var r := _popup_rect()
    var a: Vector2 = popup["anchor"]
    var above: bool = r.position.y < a.y
    var tip_y: float = r.end.y if above else r.position.y
    draw_colored_polygon(PackedVector2Array([Vector2(a.x - 8, tip_y), Vector2(a.x + 8, tip_y), Vector2(a.x, a.y - 26.0 if above else a.y + 26.0)]), GOLD)
    _panel_box(r, Color(0.04, 0.035, 0.05, 0.98), GOLD)
    _text_center(str(popup["title"]), Rect2(r.position.x, r.position.y + 6.0, r.size.x, 14), 12, GOLD_HI)
    var opts: Array = popup["options"]
    for i in range(opts.size()):
        var o: Dictionary = opts[i]
        var orr := _popup_option_rect(i)
        var hot: bool = orr.has_point(hover_pos) or (cursor_visible and popup_sel == i)
        var ok: bool = bool(o["enabled"])
        _panel_box(orr, Color("#241c2c") if hot else Color("#141018"), GOLD_HI if hot else (SOUL if ok else EDGE))
        draw_texture_rect(ICONS[o["icon"]], Rect2(orr.position + Vector2(orr.size.x * 0.5 - 20.0, 6), Vector2(40, 40)), false, Color.WHITE if ok else Color(0.45, 0.45, 0.5, 0.8))
        _text_center(str(o["label"]), Rect2(orr.position.x, orr.position.y + 50.0, orr.size.x, 12), 11, CREAM)
        _text_center(str(o["sub"]), Rect2(orr.position.x, orr.position.y + 70.0, orr.size.x, 12), 11, SOUL if ok else CRIMSON)


func _draw_tutorial() -> void:
    var target: Rect2 = _tut_target()
    var a: float = 0.55 + 0.45 * sin(tick * 6.0)
    if target.size != Vector2.ZERO:
        draw_rect(target.grow(4.0), Color(1.0, 0.85, 0.4, a), false, 3.0)
        var tip := Vector2(target.get_center().x, target.position.y - 6.0 - 6.0 * absf(sin(tick * 4.0)))
        if target.position.y < 110.0:
            tip = Vector2(target.get_center().x, target.end.y + 6.0 + 6.0 * absf(sin(tick * 4.0)))
            draw_colored_polygon(PackedVector2Array([tip, tip + Vector2(-10, 16), tip + Vector2(10, 16)]), GOLD_HI)
        else:
            draw_colored_polygon(PackedVector2Array([tip, tip + Vector2(-10, -16), tip + Vector2(10, -16)]), GOLD_HI)
    var r := TUT_CARD
    _panel_box(r, Color(0.05, 0.04, 0.07, 0.96), GOLD_HI.lerp(Color.WHITE, tut_flash))
    var step: Array = TUT_STEPS[tut_step]
    _label(step[0], r.position + Vector2(12, 22), 15, GOLD_HI)
    _label("%d/%d" % [tut_step + 1, TUT_STEPS.size()], r.position + Vector2(r.size.x - 44.0, 22), 11, Color("#9a957f"))
    draw_multiline_string(font, r.position + Vector2(10, 44), step[1], HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 18.0, 13, 6, CREAM)
    if tut_step in [0, TUT_STEPS.size() - 1]:
        _label("▶ TOCA AQUÍ / ENTER", r.position + Vector2(12, r.size.y - 12.0), 11, Color(SOUL.r, SOUL.g, SOUL.b, a))
    else:
        _panel_box(TUT_SKIP, Color("#141018"), EDGE)
        _text_center("SALTAR", Rect2(TUT_SKIP.position.x, TUT_SKIP.position.y + 6.0, TUT_SKIP.size.x, 14), 11, Color("#9a957f"))


func _draw_selection() -> void:
    draw_rect(Rect2(0, 64, W, 440), Color(0, 0, 0, 0.6))
    var panel := Rect2(130, 100, 700, 395)
    _modal(panel)
    _title("Vigilia del Claustro", Vector2(130, 158), 44, CREAM, panel.size.x)
    _center_text("Defiende tu celda. Fases sin fin, cada una más dura.", 190, 15, SOUL)
    var steps := [["descansar", "1 · DUERME", "toca el lecho: ganas ecos"], ["centinela", "2 · CONSTRUYE", "toca cualquier baldosa"], ["potenciar", "3 · MEJORA", "toca lo construido"], ["bolsa_almas", "4 · GANA", "botín para la campaña"]]
    for i in range(steps.size()):
        var cx: float = panel.position.x + 100.0 + float(i) * 166.0
        draw_texture_rect(ICONS[steps[i][0]], Rect2(cx - 28.0, 214, 56, 56), false)
        _text_center(steps[i][1], Rect2(cx - 80.0, 278, 160, 18), 15, CREAM)
        _text_center(steps[i][2], Rect2(cx - 80.0, 298, 160, 16), 11, SOUL)
    _center_text("Centinelas disparan · generadores dan energía · campanas frenan a las entidades.", 344, 13, GOLD_HI)
    var pulse: float = 0.6 + 0.4 * sin(tick * 3.0)
    _panel_box(START_BTN, Color("#2a1d36"), Color(GOLD_HI.r, GOLD_HI.g, GOLD_HI.b, 0.6 + 0.4 * pulse))
    _text_center("EMPEZAR" if tutorial_done else "EMPEZAR CON TUTORIAL", Rect2(START_BTN.position.x, START_BTN.position.y + 8.0, START_BTN.size.x, 18), 16, CREAM)
    _text_center("ENTER / A", Rect2(START_BTN.position.x, START_BTN.position.y + 30.0, START_BTN.size.x, 12), 10, SOUL)
    _panel_box(TUT_BTN, Color("#141018"), GOLD)
    _text_center("REPETIR TUTORIAL" if tutorial_done else "SALTAR TUTORIAL", Rect2(TUT_BTN.position.x, TUT_BTN.position.y + 8.0, TUT_BTN.size.x, 18), 12, CREAM)
    _text_center("T / Y" if tutorial_done else "toca aquí", Rect2(TUT_BTN.position.x, TUT_BTN.position.y + 30.0, TUT_BTN.size.x, 12), 10, Color("#9a957f"))
    _center_text("MEJOR FASE: %d   ·   MEJOR PUNTUACIÓN: %d" % [best_stage, high_score], 456, 13, CREAM)


func _draw_reward() -> void:
    draw_rect(Rect2(0, 64, W, 440), Color(0, 0, 0, 0.6))
    var panel := Rect2(160, 96, 640, 400)
    _modal(panel)
    _title("Fase %d superada" % stage, Vector2(160, 152), 44, CREAM, panel.size.x)
    _center_text("Botín para la campaña (ya está en tu bolsa):", 186, 14, SOUL)
    var n: int = rewards.size()
    for i in range(n):
        var key: String = rewards[i]
        var info_o: Array = Botin.OBJETOS.get(key, [key, "", 1, "alma"])
        var card := Rect2(480.0 - float(n) * 140.0 + float(i) * 280.0 + 10.0, 206, 260, 170)
        var tier: int = int(info_o[2])
        var tier_col: Color = [Color("#9a957f"), SOUL, Color("#a988d0"), GOLD_HI][clampi(tier - 1, 0, 3)]
        _panel_box(card, Color("#141018"), tier_col)
        var glow: float = 0.5 + 0.5 * sin(tick * 3.0 + float(i))
        draw_circle(card.position + Vector2(card.size.x * 0.5, 50), 34.0, Color(tier_col.r, tier_col.g, tier_col.b, 0.08 + 0.06 * glow))
        if ICONS.has(info_o[3]):
            draw_texture_rect(ICONS[info_o[3]], Rect2(card.position + Vector2(card.size.x * 0.5 - 28.0, 22), Vector2(56, 56)), false)
        _text_center(str(info_o[0]), Rect2(card.position.x, card.position.y + 88.0, card.size.x, 18), 15, CREAM)
        draw_multiline_string(font, card.position + Vector2(14, 128), str(info_o[1]), HORIZONTAL_ALIGNMENT_CENTER, card.size.x - 28.0, 12, 2, SOUL)
        _text_center(["COMÚN", "POCO COMÚN", "RARO", "ÉPICO"][clampi(tier - 1, 0, 3)], Rect2(card.position.x, card.end.y - 22.0, card.size.x, 14), 11, tier_col)
    var pulse: float = 0.6 + 0.4 * sin(tick * 3.0)
    _center_text("TOCA O PULSA ENTER: FASE %d%s" % [stage + 1, " (JEFE)" if (stage + 1) % 5 == 0 else ""], 418, 18, Color(GOLD_HI.r, GOLD_HI.g, GOLD_HI.b, pulse))
    _center_text("ESC o SALIR: volver con lo ganado", 452, 12, CREAM)


func _draw_lost() -> void:
    draw_rect(Rect2(0, 64, W, 440), Color(0.1, 0, 0, 0.55))
    var panel := Rect2(160, 130, 640, 320)
    _modal(panel)
    _title("La puerta ha cedido", Vector2(160, 190), 44, Color("#ff8a8a"), panel.size.x)
    _center_text("Llegaste a la fase %d   ·   Entidades: %d   ·   Puntos: %d" % [stage, slain, session_score], 246, 15, CREAM)
    _center_text("El botín de las fases superadas ya está en tu bolsa.", 280, 13, SOUL)
    _center_text("TOCA PARA EMPEZAR DE NUEVO   ·   ESC PARA VOLVER", 398, 15, GOLD_HI)


# ------------------------------------------------------------ PIEZAS DE INTERFAZ
func _panel_box(r: Rect2, fill: Color, edge: Color) -> void:
    draw_rect(Rect2(r.position + Vector2(2, 3), r.size), Color(0, 0, 0, 0.4))
    draw_rect(r, fill)
    draw_rect(Rect2(r.position, Vector2(r.size.x, 2)), Color(1, 1, 1, 0.05))
    draw_rect(r, edge, false, 2.0)


func _modal(r: Rect2) -> void:
    _panel_box(r, Color(0.04, 0.035, 0.05, 0.97), GOLD)
    draw_rect(r.grow(-6.0), Color("#3a3440"), false, 1.0)


func _chip(r: Rect2, icon: String, value: String, sub: String, color: Color) -> void:
    _panel_box(r, Color("#141018"), EDGE)
    draw_texture_rect(ICONS[icon], Rect2(r.position + Vector2(6, 6), Vector2(28, 28)), false)
    draw_string(font, r.position + Vector2(40, 22), value, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, color)
    draw_string(font, r.position + Vector2(40, 35), sub, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#9a957f"))


func _round_button(r: Rect2, icon: String, hot: bool) -> void:
    _panel_box(r, Color("#241c2c") if hot else Color("#141018"), GOLD_HI if hot else GOLD)
    draw_texture_rect(ICONS[icon], Rect2(r.get_center() - Vector2(16, 16), Vector2(32, 32)), false)


func _pill(text_value: String, center: Vector2, size: int, color: Color) -> void:
    var width: float = font.get_string_size(text_value, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
    var box := Rect2(center.x - width * 0.5 - 8, center.y - size + 1, width + 16, size + 7)
    draw_rect(box, Color(0.03, 0.025, 0.04, 0.85))
    draw_rect(box, Color(color.r, color.g, color.b, 0.4), false, 1.0)
    draw_string(font, Vector2(center.x - width * 0.5, center.y + 2), text_value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


func _title(text_value: String, at: Vector2, size: int, color: Color, width: float) -> void:
    var f: Font = title_font if title_font != null else font
    draw_string(f, at, text_value, HORIZONTAL_ALIGNMENT_CENTER if width > 0.0 else HORIZONTAL_ALIGNMENT_LEFT, width, size, color)


func _label(text_value: String, at: Vector2, size: int = 16, color: Color = CREAM) -> void:
    draw_string(font, at, text_value, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, color)


func _center_text(text_value: String, y: float, size: int = 16, color: Color = CREAM) -> void:
    draw_string(font, Vector2(40, y), text_value, HORIZONTAL_ALIGNMENT_CENTER, 880.0, size, color)


func _text_center(text_value: String, rect: Rect2, size: int, color: Color) -> void:
    draw_string(font, Vector2(rect.position.x, rect.position.y + size), text_value, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, size, color)



# ------------------------------------------------------------ PANTALLA COMPLETA REAL
## Igual que en la campaña: «expand» llena cualquier pantalla; la celda queda
## centrada y lo que sobra se rellena con la propia celda, en penumbra.
var screen_pad: Vector2 = Vector2.ZERO
var backdrop_rect: TextureRect


func _setup_fullscreen() -> void:
    var layer := CanvasLayer.new()
    layer.layer = -1
    add_child(layer)
    # Mismo fondo que la campaña: penumbra continua, sin copias ampliadas.
    var grad := Gradient.new()
    grad.set_color(0, Color8(22, 18, 28))
    grad.set_color(1, Color8(4, 3, 7))
    var tex := GradientTexture2D.new()
    tex.gradient = grad
    tex.fill = GradientTexture2D.FILL_RADIAL
    tex.fill_from = Vector2(0.5, 0.5)
    tex.fill_to = Vector2(1.05, 0.5)
    tex.width = 256
    tex.height = 256
    backdrop_rect = TextureRect.new()
    backdrop_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    backdrop_rect.stretch_mode = TextureRect.STRETCH_SCALE
    backdrop_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    backdrop_rect.texture = tex
    layer.add_child(backdrop_rect)
    get_viewport().size_changed.connect(_fit_screen)
    _fit_screen()


func _fit_screen() -> void:
    var view: Vector2 = get_viewport_rect().size
    screen_pad = ((view - Vector2(W, H)) * 0.5).floor().max(Vector2.ZERO)
    if DisplayServer.get_name() == "headless":
        screen_pad = Vector2.ZERO # sin pantalla (pruebas automáticas): disposición base
    position = screen_pad
    if backdrop_rect != null:
        backdrop_rect.position = Vector2.ZERO
        backdrop_rect.size = view
    queue_redraw()
