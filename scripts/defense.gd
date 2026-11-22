extends Node2D
## Modo alternativo: Vigilia del Claustro. Defensa de una celda del templo,
## por fases sin fin: duermes en el lecho para ganar ecos, construyes
## centinelas y generadores y refuerzas la puerta mientras las entidades
## avanzan por el pasillo. Cada fase superada da un objeto al azar que pasa a
## la campaña (scripts/botin.gd); cada fase es más difícil y su botín, mejor.
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
## Paleta de la campaña: negros, dorado envejecido, violeta y carmesí.
const CREAM := Color("#d9d2ba")
const SOUL := Color("#8fc7d7")
const GOLD := Color("#b8955a")
const GOLD_HI := Color("#e3bd7b")
const CRIMSON := Color("#d1474f")
const VIOLET := Color("#3b2550")
const PANEL := Color(0.035, 0.03, 0.045, 0.92)
const EDGE := Color("#2f2a35")
## Celda, puerta y pasillo (rejilla de 56 px, como un plano de dormitorio).
const TILE := 56.0
const ROOM := Rect2(40, 88, 616, 392)
const DOOR := Rect2(650, 228, 24, 112)
const DOOR_X := 700.0 # donde se paran las entidades a golpear
const SPAWN_X := 990.0
const BED := Rect2(96, 200, 112, 168)
## Casillas de centinela (centros) y de generador.
const SLOTS := [Vector2(460, 172), Vector2(572, 172), Vector2(460, 396), Vector2(572, 396)]
const GEN_SLOTS := [Vector2(292, 452), Vector2(348, 452), Vector2(404, 452), Vector2(292, 116), Vector2(348, 116), Vector2(404, 116)]
const EXIT_RECT := Rect2(888, 8, 56, 48)
const PAUSE_RECT := Rect2(826, 8, 56, 48)
## Entidades: hojas originales de 48x64 (fila 3 mira a la izquierda, a la puerta).
const MONSTER_SHEETS := {
    "ghoul": preload("res://assets/visual/enemies/ghoul.png"),
    "wizard": preload("res://assets/visual/enemies/hechicero.png"),
    "angel": preload("res://assets/visual/enemies/testigo.png"),
    "mastin": preload("res://assets/visual/enemies/mastin.png"),
    "segador": preload("res://assets/visual/enemies/segador.png"),
    "tejedora": preload("res://assets/visual/enemies/tejedora.png"),
}
## Orden de aparición por fase y jefes (cada 5 fases).
const STAGE_KINDS := ["ghoul", "wizard", "angel", "mastin", "segador", "ghoul", "tejedora", "mastin"]
const BOSS_KINDS := ["tejedora", "segador", "angel"]
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
    "pan": preload("res://assets/visual/iconos/pan.png"),
    "fosforos": preload("res://assets/visual/iconos/fosforos.png"),
    "vial": preload("res://assets/visual/iconos/vial.png"),
    "incienso": preload("res://assets/visual/iconos/incienso.png"),
    "bolsa_almas": preload("res://assets/visual/iconos/bolsa_almas.png"),
    "brazalete": preload("res://assets/visual/iconos/brazalete.png"),
    "amuleto": preload("res://assets/visual/iconos/amuleto.png"),
    "resonancia": preload("res://assets/visual/iconos/resonancia.png"),
    "reliquia": preload("res://assets/visual/iconos/reliquia.png"),
    "calavera": preload("res://assets/visual/iconos/calavera.png"),
}

var phase: String = "selection" # selection (portada), play, won (fase superada), lost
var chamber: int = 0 # se conserva por compatibilidad: hay un solo modo
var stage: int = 1 # fase actual (sin límite)
var hover_pos: Vector2 = Vector2(-100, -100)
var tooltip_left: float = 0.0
var elapsed: float = 0.0 # segundos dentro de la fase
var total_time: float = 0.0
var income: float = 22.0
var income_rate: float = 2.0
var sleeping: bool = false
var bed_level: int = 1
var gate_level: int = 1
var gate_max: float = 150.0
var gate_hp: float = 150.0
var gate_flash: float = 0.0
var wards: int = 0
var waves: int = 1
var hunters: Array = [] # {x, hp, max, kind, cooldown, boss, hit}
var spawn_t: float = 0.0
var auto_fire: float = 0.0
var shots: Array = [] # destellos de los centinelas: {from, to, t}
var slain: int = 0
var info: String = ""
var info_time: float = 0.0
var font: Font
var title_font: Font
var tick: float = 0.0
var sparks: float = 0.0
var generator_level: int = 0
var ward_power: int = 1
var shield_left: float = 0.0
var paused: bool = false
var high_score: int = 0
var best_time: float = 0.0
var best_stage: int = 0
var session_score: int = 0
var rewards: Array = [] # claves del botín de la última fase
var rng := RandomNumberGenerator.new()
## Audio original compartido con la campaña (herramientas/generar_audio.py).
var music: AudioStreamPlayer
var tension: AudioStreamPlayer
var sfx_pool: Array[AudioStreamPlayer] = []
var sfx_streams: Dictionary = {}
var tension_level: float = 0.0
## Mando: la cruceta (o el stick) elige una acción, A la usa, B sale.
var pad_sel: int = 0
var pad_stick_dir: int = 0


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
    # Sin audio en pruebas headless (igual que la campaña).
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
## Empieza en la fase 1. El parámetro se ignora (compatibilidad).
func _start(_choice: int = 0) -> void:
    chamber = 0
    phase = "play"
    stage = 1
    elapsed = 0.0
    total_time = 0.0
    income = 30.0
    income_rate = 2.5
    sparks = 4.0
    generator_level = 0
    ward_power = 1
    shield_left = 0.0
    paused = false
    session_score = 0
    sleeping = false
    bed_level = 1
    gate_level = 1
    gate_max = 210.0
    gate_hp = gate_max
    wards = 0
    waves = 1
    slain = 0
    auto_fire = 0.0
    rewards.clear()
    _begin_stage()
    _say("Duerme para ganar ecos. Construye. Resiste la fase %d." % stage)
    queue_redraw()


func _begin_stage() -> void:
    slain_in_stage = 0
    hunters.clear()
    shots.clear()
    elapsed = 0.0
    waves = 1
    spawn_t = 0.0
    _spawn_hunter()


## Tras el botín: la fase siguiente, más dura. Defensas y ecos se conservan.
func _next_stage() -> void:
    if phase != "won":
        return
    stage += 1
    phase = "play"
    gate_hp = minf(gate_max, gate_hp + gate_max * 0.25) # un respiro entre fases
    rewards.clear()
    _begin_stage()
    _say("FASE %d. Más fuertes, más rápidas.%s" % [stage, " ¡Viene un JEFE!" if _is_boss_stage() else ""])
    _sfx("sello", -8.0, 0.7)


func _is_boss_stage() -> bool:
    return stage % 5 == 0


## Multiplicador de dificultad de la fase.
func _stage_mult() -> float:
    var n: float = float(stage - 1)
    return 1.0 + 0.45 * n + 0.05 * n * n # crece cada vez más: no hay techo


func _max_hunters() -> int:
    return mini(5, 1 + stage / 2)


func _spawn_hunter() -> void:
    var boss: bool = _is_boss_stage() and not hunters.any(func(h): return bool(h["boss"])) and slain_in_stage == 0
    var kind: String
    if boss:
        kind = BOSS_KINDS[(stage / 5 - 1) % BOSS_KINDS.size()]
    else:
        kind = STAGE_KINDS[(stage - 1 + waves - 1) % STAGE_KINDS.size()] if stage > 1 else ["ghoul", "wizard", "angel"][(waves - 1) % 3]
    var hp: float = (52.0 + float(waves) * 32.0) * (1.25 if kind == "angel" else 1.0) * _stage_mult() * (4.0 if boss else 1.0)
    hunters.append({"x": SPAWN_X + float(hunters.size()) * 40.0, "hp": hp, "max": hp, "kind": kind, "cooldown": 1.0,
        "boss": boss, "hit": 0.0, "lane": rng.randf_range(-40.0, 40.0)})
    if boss:
        _say("¡JEFE! %s se acerca por el pasillo." % _kind_name(kind).to_upper())
        _sfx("muerte", -10.0, 0.6)


var slain_in_stage: int = 0


func _kind_name(kind: String) -> String:
    return {"ghoul": "el Ghoul", "wizard": "el Hechicero", "angel": "el Testigo", "mastin": "el Mastín",
        "segador": "el Segador", "tejedora": "la Tejedora"}.get(kind, kind)


func _load_records() -> void:
    if not FileAccess.file_exists(_defense_path()):
        return
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(_defense_path()))
    if parsed is Dictionary:
        high_score = maxi(0, int(parsed.get("high_score", 0)))
        best_time = maxf(0.0, float(parsed.get("best_time", 0.0)))
        best_stage = maxi(0, int(parsed.get("best_stage", 0)))


func _save_records() -> void:
    var file := FileAccess.open(_defense_path(), FileAccess.WRITE)
    if file != null:
        file.store_string(JSON.stringify({
            "high_score": high_score,
            "best_time": best_time,
            "best_stage": best_stage,
            "version": 2
        }))


func _record_end(win: bool) -> void:
    var bonus: int = 300 * stage if win else 0
    session_score = slain * 50 + int(total_time) * 3 + (gate_level + bed_level + wards * ward_power) * 10 + bonus
    high_score = maxi(high_score, session_score)
    best_time = maxf(best_time, total_time)
    best_stage = maxi(best_stage, stage if win else stage - 1)
    _save_records()


func _say(message: String) -> void:
    info = message
    info_time = 3.5


## Fase superada: botín para la campaña (dos objetos en fase de jefe).
func _win_stage() -> void:
    phase = "won"
    sleeping = false
    hunters.clear()
    shots.clear()
    rewards.clear()
    for i in range(2 if _is_boss_stage() else 1):
        var key: String = Botin.sortear(stage, rng)
        Botin.aplicar(key)
        rewards.append(key)
    _record_end(true)
    _sfx("sello", -4.0, 0.8)


func _action(choice: int) -> bool:
    if phase != "play":
        return false
    if choice == 8:
        paused = not paused
        _say("Vigilia en pausa." if paused else "La vigilia continúa.")
        queue_redraw()
        return true
    if paused:
        return false
    match choice:
        0:
            sleeping = not sleeping
            _say("Duermes: el lecho genera ecos." if sleeping else "Te levantas. Sin ingresos.")
        1:
            var cost: float = 18.0 * float(bed_level)
            if income < cost or bed_level >= 8:
                _say("Ecos insuficientes o lecho al máximo.")
                return false
            income -= cost
            bed_level += 1
            income_rate = 1.5 + float(bed_level)
            _say("Lecho mejorado: +%d ecos/s." % int(income_rate))
        2:
            var cost: float = 25.0 * float(gate_level)
            if income < cost or gate_level >= 8:
                _say("Faltan ecos para reforzar la puerta.")
                return false
            income -= cost
            gate_level += 1
            gate_max += 95.0
            gate_hp = minf(gate_max, gate_hp + 120.0)
            _say("Puerta reforzada a nivel %d." % gate_level)
        3:
            var cost: float = 22.0 + float(wards) * 20.0
            if income < cost or wards >= 4:
                _say("Ecos insuficientes o cuatro centinelas construidos.")
                return false
            income -= cost
            wards += 1
            _say("Un centinela despierta (%d/4)." % wards)
        4:
            if income < 18.0 or gate_hp >= gate_max:
                _say("Reparación innecesaria o faltan ecos.")
                return false
            income -= 18.0
            gate_hp = minf(gate_max, gate_hp + 85.0)
            _say("La puerta ha sido reparada.")
        5:
            var cost: float = 35.0 + 25.0 * float(generator_level)
            if income < cost or generator_level >= 6:
                _say("Faltan ecos o el generador llegó a su límite.")
                return false
            income -= cost
            generator_level += 1
            _say("Generador %d: energía mientras duermes." % generator_level)
        6:
            var cost: float = 6.0 * float(ward_power)
            if sparks < cost or wards < 1 or ward_power >= 6:
                _say("Construye un centinela y produce más energía.")
                return false
            sparks -= cost
            ward_power += 1
            _say("Los centinelas golpean más fuerte (poder %d)." % ward_power)
        7:
            if sparks < 14.0 or shield_left > 0.0:
                _say("Necesitas 14 de energía y el escudo inactivo.")
                return false
            sparks -= 14.0
            shield_left = 8.0
            _say("Escudo: 8 segundos sin daño en la puerta.")
        _:
            return false
    _sfx("sello" if choice == 3 else "interfaz", -10.0, 1.3 if choice == 3 else 1.0)
    queue_redraw()
    return true


func _process(delta: float) -> void:
    tick += delta
    info_time = maxf(0.0, info_time - delta)
    tooltip_left = maxf(0.0, tooltip_left - delta)
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


func _advance(dt: float) -> void:
    elapsed += dt
    total_time += dt
    waves = 1 + int(elapsed / 25.0)
    shield_left = maxf(0.0, shield_left - dt)
    if sleeping:
        income += dt * income_rate
        sparks += dt * float(generator_level) * 0.85
    if elapsed >= PHASE_LENGTH:
        _win_stage()
        return
    # Aparecen más entidades a la vez según la fase.
    spawn_t -= dt
    if spawn_t <= 0.0 and hunters.size() < _max_hunters():
        _spawn_hunter()
        spawn_t = maxf(2.5, 8.0 - float(stage) * 0.5)
    var speed: float = (28.0 + float(waves) * 6.5) * (1.0 + 0.06 * float(stage - 1))
    var dmg: float = (14.0 + float(waves) * 4.0) * (1.0 + 0.3 * float(stage - 1))
    for i in range(hunters.size()):
        var h: Dictionary = hunters[i]
        h["hit"] = maxf(0.0, float(h["hit"]) - dt)
        var stop: float = DOOR_X + float(i) * 26.0
        h["x"] = maxf(stop, float(h["x"]) - speed * (0.8 if bool(h["boss"]) else 1.0) * dt)
        if float(h["x"]) <= stop + 0.5:
            h["cooldown"] = float(h["cooldown"]) - dt
            if float(h["cooldown"]) <= 0.0:
                h["cooldown"] = maxf(0.45, 1.75 - float(waves) * 0.10 - 0.05 * float(stage - 1))
                if shield_left <= 0.0:
                    gate_hp -= dmg * (2.0 if bool(h["boss"]) else 1.0)
                    gate_flash = 1.0
                    _sfx("puerta", -9.0, 1.3)
    # Centinelas: disparan a la entidad más adelantada.
    if wards > 0 and not hunters.is_empty() and _front_x() < 938.0:
        auto_fire -= dt
        if auto_fire <= 0.0:
            auto_fire = 0.58
            var target_i: int = 0
            for i in range(hunters.size()):
                if float(hunters[i]["x"]) < float(hunters[target_i]["x"]):
                    target_i = i
            var t: Dictionary = hunters[target_i]
            t["hp"] = float(t["hp"]) - float(wards * ward_power) * 12.0
            t["hit"] = 0.15
            for n in range(wards):
                shots.append({"from": SLOTS[n] + Vector2(0, -26), "to": Vector2(float(t["x"]), 330.0 + float(t["lane"]) * 0.3), "t": 0.12})
            if float(t["hp"]) <= 0.0:
                slain += 1
                slain_in_stage += 1
                income += (9.0 + float(waves) * 2.0) * (3.0 if bool(t["boss"]) else 1.0)
                hunters.remove_at(target_i)
                spawn_t = maxf(spawn_t, 2.4) if hunters.is_empty() else spawn_t
                _say("¡JEFE derrotado!" if bool(t["boss"]) else "Entidad repelida. Ecos recuperados.")
                _sfx("alma", -7.0)
    if gate_hp <= 0.0:
        gate_hp = 0.0
        _record_end(false)
        sleeping = false
        phase = "lost"
        _sfx("muerte", -4.0)
        _say("La puerta ha cedido.")


## Para las pruebas: una entidad justo en la puerta, a punto de golpear.
func _debug_hunter_at_door() -> void:
    hunters.clear()
    _spawn_hunter()
    hunters[0]["x"] = DOOR_X
    hunters[0]["cooldown"] = 0.0


# ------------------------------------------------------------ ENTRADA
func _bottom_rect(i: int) -> Rect2:
    return Rect2(6.0 + float(i) * 119.0, 512.0, 113.0, 120.0)


func _pad_action_center(i: int) -> Vector2:
    return _bottom_rect(i).get_center()


func _pad_move(step: int) -> void:
    pad_sel = (pad_sel + step + 8) % 8
    hover_pos = _pad_action_center(pad_sel)
    tooltip_left = 2.2


func _pad_key(k: Key) -> void:
    var ev := InputEventKey.new()
    ev.keycode = k
    ev.pressed = true
    _input(ev)


func _input(event: InputEvent) -> void:
    if event is InputEventJoypadButton and event.pressed:
        match event.button_index:
            JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_UP:
                _pad_move(-1)
            JOY_BUTTON_DPAD_RIGHT, JOY_BUTTON_DPAD_DOWN:
                _pad_move(1)
            JOY_BUTTON_A:
                if phase == "play":
                    _action(pad_sel)
                else:
                    _pad_key(KEY_ENTER)
            JOY_BUTTON_START:
                if phase == "play":
                    _action(8)
                else:
                    _pad_key(KEY_ENTER)
            JOY_BUTTON_Y:
                if phase == "play":
                    _action(0)
            JOY_BUTTON_B, JOY_BUTTON_BACK:
                _leave()
                return
        queue_redraw()
        return
    if event is InputEventJoypadMotion and event.axis == JOY_AXIS_LEFT_X:
        var d: int = 0 if absf(event.axis_value) < 0.5 else signi(roundi(event.axis_value))
        if d != pad_stick_dir:
            pad_stick_dir = d
            if d != 0:
                _pad_move(d)
                queue_redraw()
        return
    if event is InputEventScreenTouch:
        if event.pressed:
            _tap(make_input_local(event).position)
    elif event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            _tap(make_input_local(event).position)
    elif event is InputEventMouseMotion:
        hover_pos = make_input_local(event).position
        tooltip_left = 0.0
    elif event is InputEventKey and event.pressed and not event.echo:
        var k: Key = event.keycode
        if k == KEY_ESCAPE:
            _leave()
        elif phase == "selection" and k in [KEY_ENTER, KEY_SPACE]:
            _start()
        elif phase == "won" and k in [KEY_ENTER, KEY_SPACE]:
            _next_stage()
        elif phase == "lost" and k == KEY_ENTER:
            _start(chamber)
        elif phase == "play":
            if k == KEY_P:
                _action(8)
            elif k == KEY_SPACE:
                _action(0)
            elif k >= KEY_1 and k <= KEY_8:
                _action(int(k) - int(KEY_1))
    queue_redraw()


func _tap(at: Vector2) -> void:
    hover_pos = at
    tooltip_left = 2.2
    if EXIT_RECT.has_point(at):
        _leave()
        return
    if phase == "selection":
        if at.y > 270.0 and at.y < 515.0:
            _start()
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
    if at.y >= 512.0:
        _action(clampi(int((at.x - 6.0) / 119.0), 0, 7))
        return
    # Tocar el mundo: lecho = dormir; casilla vacía = centinela; puerta = reparar.
    if BED.grow(8.0).has_point(at):
        _action(0)
        return
    for i in range(SLOTS.size()):
        if at.distance_to(SLOTS[i]) < 34.0 and i >= wards:
            _action(3)
            return
    if DOOR.grow(16.0).has_point(at):
        _action(4)


func _leave() -> void:
    get_tree().change_scene_to_file("res://scenes/main.tscn")


func _defense_path() -> String:
    return DEFENSE_SAVE_TEST if Engine.has_meta("modo_prueba") else DEFENSE_SAVE


# ------------------------------------------------------------ DIBUJO
func _draw() -> void:
    draw_rect(Rect2(0, 0, W, H), Color("#07060a"))
    _draw_room()
    _draw_corridor()
    _draw_door()
    _draw_bed()
    _draw_generators()
    for i in range(SLOTS.size()):
        _draw_slot(i)
    _draw_hunters()
    _draw_shots()
    _draw_vignette()
    _draw_top_bar()
    _draw_bottom_bar()
    if info_time > 0.0 and phase == "play":
        _pill(info, Vector2(ROOM.get_center().x, ROOM.end.y - 18.0), 13, GOLD_HI)
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
    _draw_tooltip()


## Celda: suelo de baldosas en rejilla, muros gruesos, velas y alfombra.
func _draw_room() -> void:
    var r := ROOM
    draw_rect(r.grow(14.0), Color("#1a1620"))
    var cols: int = int(r.size.x / TILE)
    var rows: int = int(r.size.y / TILE)
    for y in range(rows):
        for x in range(cols):
            var tile := Rect2(r.position + Vector2(x, y) * TILE, Vector2(TILE, TILE))
            var a: bool = (x + y) % 2 == 0
            draw_rect(tile, Color("#2a2630") if a else Color("#25212b"))
            draw_rect(Rect2(tile.position, Vector2(TILE, 2)), Color(1, 1, 1, 0.03))
            draw_rect(tile, Color(0, 0, 0, 0.25), false, 1.0)
    # Alfombra bajo el lecho.
    var rug := Rect2(BED.position - Vector2(16, 16), BED.size + Vector2(32, 32))
    draw_rect(rug, Color("#3b2550"))
    draw_rect(rug.grow(-5.0), Color("#4a2e63"), false, 2.0)
    # Muros: banda superior con sillares y zócalo.
    draw_rect(Rect2(r.position.x - 14, r.position.y - 14, r.size.x + 28, 14), Color("#3a3440"))
    for x in range(0, int(r.size.x + 28), 28):
        draw_rect(Rect2(r.position.x - 14 + x, r.position.y - 14, 26, 6), Color("#4a4352"))
    draw_rect(r.grow(14.0), Color("#120f16"), false, 3.0)
    draw_rect(r, Color(0, 0, 0, 0.5), false, 2.0)
    # Velas en las esquinas: luz cálida que parpadea.
    for c in [r.position + Vector2(18, 18), Vector2(r.position.x + 18, r.end.y - 18)]:
        var flick: float = 0.5 + 0.5 * sin(tick * 7.0 + c.y) * sin(tick * 2.3)
        for k in range(4, 0, -1):
            draw_circle(c, 8.0 + float(k) * 9.0, Color(1.0, 0.75, 0.4, 0.025 + 0.01 * flick))
        draw_rect(Rect2(c.x - 3, c.y - 2, 6, 10), Color("#d9d2ba"))
        draw_circle(c + Vector2(0, -5), 3.0 + flick, Color(1.0, 0.8, 0.4))
    # Resplandor del lecho cuando duermes.
    if sleeping:
        for k in range(5, 0, -1):
            draw_circle(BED.get_center(), 40.0 + float(k) * 18.0, Color(0.56, 0.78, 0.84, 0.025))


## Pasillo: oscuro, con una lámpara que parpadea y marcas de garras.
func _draw_corridor() -> void:
    var c := Rect2(ROOM.end.x + 14.0, ROOM.position.y - 14.0, W - ROOM.end.x - 14.0, ROOM.size.y + 28.0)
    draw_rect(c, Color("#100d14"))
    for y in range(int(c.position.y), int(c.end.y), 28):
        draw_rect(Rect2(c.position.x, float(y), c.size.x, 1), Color(1, 1, 1, 0.025))
    var flick: float = 1.0 if fmod(tick, 3.7) > 0.25 else 0.2
    var lamp := Vector2(c.get_center().x + 40.0, c.position.y + 20.0)
    for k in range(5, 0, -1):
        draw_circle(lamp + Vector2(0, 60), 30.0 + float(k) * 22.0, Color(0.7, 0.85, 0.9, 0.02 * flick))
    draw_rect(Rect2(lamp.x - 6, lamp.y - 4, 12, 8), Color("#4a4352"))
    draw_circle(lamp + Vector2(0, 6), 4.0, Color(0.8, 0.95, 1.0, 0.9 * flick))
    for i in range(3):
        var p := Vector2(c.position.x + 40.0 + float(i) * 70.0, c.end.y - 60.0 - float(i % 2) * 120.0)
        for k in range(3):
            draw_line(p + Vector2(k * 4, 0), p + Vector2(k * 4 + 6, 14), Color(0.4, 0.1, 0.12, 0.5), 1.0)
    _pill("PASILLO", Vector2(c.get_center().x, c.end.y - 14.0), 11, Color("#6d6772"))


## Puerta: tablones con herrajes, barra de vida y nivel en puntos.
func _draw_door() -> void:
    var d := DOOR
    draw_rect(d.grow(4.0), Color("#3a3440"))
    var hurt: Color = Color("#5a3f2c").lerp(CRIMSON, gate_flash * 0.6)
    draw_rect(d, hurt)
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
        draw_rect(d.grow(8.0), SOUL, false, 2.0)
    # Barra de vida grande encima de la puerta.
    var bar := Rect2(d.get_center().x - 60.0, d.position.y - 40.0, 120, 12)
    draw_rect(bar.grow(2.0), Color(0, 0, 0, 0.8))
    draw_rect(bar, Color("#3a1a20"))
    draw_rect(Rect2(bar.position, Vector2(bar.size.x * clampf(gate_hp / gate_max, 0.0, 1.0), bar.size.y)), Color("#c9a25e") if gate_hp / gate_max > 0.35 else CRIMSON)
    _text_center("%d/%d" % [int(gate_hp), int(gate_max)], Rect2(bar.position.x, bar.position.y - 1.0, bar.size.x, 12), 10, CREAM)
    for i in range(8):
        draw_rect(Rect2(bar.position.x + float(i) * 15.0 + 1.0, bar.position.y - 8.0, 12, 4), GOLD_HI if i < gate_level else Color("#2f2a35"))


## Lecho: cama con dosel bajo; el personaje duerme y suelta «z».
func _draw_bed() -> void:
    var b := BED
    draw_rect(Rect2(b.position + Vector2(5, 7), b.size), Color(0, 0, 0, 0.4))
    draw_rect(b, Color("#4a3426"))
    draw_rect(Rect2(b.position, Vector2(b.size.x, 8)), Color("#6b4c37"))
    draw_rect(b.grow(-7.0), Color("#2c2a3a"))
    draw_rect(Rect2(b.position.x + 14, b.position.y + 14, b.size.x - 28, 34), Color("#d9d2ba"))
    var blanket := Rect2(b.position.x + 10, b.position.y + 56, b.size.x - 20, b.size.y - 66)
    draw_rect(blanket, Color("#4a2e63") if not sleeping else Color("#5b3a7a"))
    for i in range(4):
        draw_line(Vector2(blanket.position.x, blanket.position.y + 14 + i * 22), Vector2(blanket.end.x, blanket.position.y + 14 + i * 22), Color(1, 1, 1, 0.05), 2.0)
    draw_rect(b, Color("#1b130d"), false, 2.0)
    if sleeping:
        draw_texture_rect_region(HERO, Rect2(b.get_center().x - 20.0, b.position.y + 6.0, 40, 56), Rect2(0, 0, 40, 56))
        for k in range(3):
            var z: float = fmod(tick + float(k) * 0.7, 2.1)
            _label("z", Vector2(b.end.x - 10.0 + z * 12.0, b.position.y + 10.0 - z * 18.0), 12 + k * 3, Color(SOUL.r, SOUL.g, SOUL.b, 1.0 - z * 0.45))
    else:
        draw_texture_rect_region(HERO, Rect2(b.end.x + 10.0, b.get_center().y - 28.0, 40, 56), Rect2(0, 0, 40, 56))
    # Nivel del lecho en puntos.
    for i in range(8):
        draw_rect(Rect2(b.position.x + 4.0 + float(i) * 13.0, b.end.y + 6.0, 10, 4), GOLD_HI if i < bed_level else Color("#2f2a35"))
    _pill(("DURMIENDO  +%d/s" % int(income_rate)) if sleeping else "TOCA PARA DORMIR", Vector2(b.get_center().x, b.end.y + 26.0), 12, SOUL if sleeping else GOLD_HI)


## Generadores: un pequeño motor de latón por nivel, con chispas.
func _draw_generators() -> void:
    for i in range(GEN_SLOTS.size()):
        var p: Vector2 = GEN_SLOTS[i]
        if i >= generator_level:
            draw_rect(Rect2(p - Vector2(18, 18), Vector2(36, 36)), Color(1, 1, 1, 0.03))
            continue
        draw_rect(Rect2(p - Vector2(16, 14), Vector2(32, 28)), Color("#8a6a3a"))
        draw_rect(Rect2(p - Vector2(16, 14), Vector2(32, 4)), Color("#c9a25e"))
        var spin: float = tick * (3.0 if sleeping else 0.6)
        draw_circle(p + Vector2(0, 2), 8.0, Color("#3a2a1a"))
        draw_line(p + Vector2(0, 2) + Vector2.from_angle(spin) * 7.0, p + Vector2(0, 2) - Vector2.from_angle(spin) * 7.0, GOLD_HI, 2.0)
        if sleeping and int(tick * 6.0 + float(i)) % 5 == 0:
            draw_circle(p + Vector2(10, -16), 2.0, Color(1.0, 0.9, 0.5))


## Casilla de centinela: círculo rúnico; con centinela, un cristal sobre pedestal.
func _draw_slot(i: int) -> void:
    var p: Vector2 = SLOTS[i]
    var built: bool = i < wards
    var tile := Rect2(p - Vector2(TILE, TILE) * 0.5, Vector2(TILE, TILE))
    draw_rect(tile, Color(0.72, 0.58, 0.35, 0.10 if built else 0.05))
    draw_rect(tile, Color(GOLD.r, GOLD.g, GOLD.b, 0.5 if built else 0.25), false, 1.0)
    if not built:
        var a: float = 0.35 + 0.2 * sin(tick * 2.0 + p.x)
        draw_line(p + Vector2(-8, 0), p + Vector2(8, 0), Color(CREAM.r, CREAM.g, CREAM.b, a), 2.0)
        draw_line(p + Vector2(0, -8), p + Vector2(0, 8), Color(CREAM.r, CREAM.g, CREAM.b, a), 2.0)
        if i == wards:
            _pill("%d ECOS" % int(22.0 + float(wards) * 20.0), p + Vector2(0, 22), 10, GOLD_HI if income >= 22.0 + float(wards) * 20.0 else Color("#8a5a64"))
        return
    draw_rect(Rect2(p.x - 14, p.y + 8, 28, 12), Color("#4a4352"))
    draw_rect(Rect2(p.x - 14, p.y + 8, 28, 3), Color("#6d6772"))
    var bob: float = sin(tick * 2.4 + p.x * 0.05) * 3.0
    var c := p + Vector2(0, -12 + bob)
    for r in range(3, 0, -1):
        draw_circle(c, 6.0 + float(r) * 6.0, Color(SOUL.r, SOUL.g, SOUL.b, 0.05 + 0.01 * float(ward_power)))
    draw_colored_polygon(PackedVector2Array([c + Vector2(0, -18), c + Vector2(0, 0), c + Vector2(0, 16), c + Vector2(-10, -1)]), Color("#bfe9f2"))
    draw_colored_polygon(PackedVector2Array([c + Vector2(0, -18), c + Vector2(10, -1), c + Vector2(0, 16), c + Vector2(0, 0)]), Color("#5ea7bb"))
    for k in range(ward_power):
        draw_rect(Rect2(p.x - 15.0 + float(k) * 5.0, p.y + 22.0, 3, 3), GOLD_HI)


func _draw_hunters() -> void:
    for h in hunters:
        var boss: bool = bool(h["boss"])
        var scale: float = 1.6 if boss else 1.2
        var x: float = float(h["x"])
        var y: float = 300.0 + float(h["lane"]) + sin(tick * 2.0 + x * 0.02) * 3.0
        var sheet: Texture2D = MONSTER_SHEETS[h["kind"]]
        var at_door: bool = x <= DOOR_X + 120.0 and float(h["cooldown"]) < 0.3
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
        draw_line(s["from"], s["to"], Color(0.75, 0.95, 1.0, 0.8 * a), 3.0)
        draw_circle(s["to"], 6.0 * a, Color(0.85, 0.97, 1.0, a))


func _draw_vignette() -> void:
    for k in range(6):
        var g: float = float(k) * 8.0
        draw_rect(Rect2(g, g, W - g * 2.0, H - g * 2.0), Color(0, 0, 0, 0.06), false, 8.0)


## Barra superior: fase, tiempo, ecos, energía, pausa y salir.
func _draw_top_bar() -> void:
    draw_rect(Rect2(0, 0, W, 64), Color(0.02, 0.018, 0.03, 0.95))
    draw_rect(Rect2(0, 62, W, 2), GOLD)
    _title("Vigilia", Vector2(16, 44), 36, CREAM, -1.0)
    var badge := Rect2(150, 12, 110, 40)
    _panel_box(badge, Color("#4a1a24") if _is_boss_stage() else VIOLET, GOLD_HI)
    _text_center("FASE %d" % stage, Rect2(badge.position.x, badge.position.y + 4.0, badge.size.x, 20), 18, CREAM)
    _text_center("JEFE" if _is_boss_stage() else "NIVEL DE BOTÍN %d" % Botin.nivel(stage), Rect2(badge.position.x, badge.position.y + 23.0, badge.size.x, 12), 9, GOLD_HI)
    var bar := Rect2(272, 30, 220, 10)
    draw_rect(bar.grow(2.0), Color(0, 0, 0, 0.8))
    draw_rect(Rect2(bar.position, Vector2(bar.size.x * clampf(elapsed / PHASE_LENGTH, 0.0, 1.0), bar.size.y)), SOUL)
    _label("%d / %d s" % [int(elapsed), int(PHASE_LENGTH)], Vector2(272, 24), 12, CREAM)
    _chip(Rect2(506, 12, 150, 40), "alma", "%d" % int(income), "+%d/s" % int(income_rate) if sleeping else "duerme", SOUL)
    _chip(Rect2(664, 12, 150, 40), "generador", "%d" % int(sparks), "energía", GOLD_HI)
    if phase == "play":
        _round_button(PAUSE_RECT, "reanudar" if paused else "pausa", PAUSE_RECT.has_point(hover_pos))
    _round_button(EXIT_RECT, "salir", EXIT_RECT.has_point(hover_pos))


## Barra inferior: ocho botones grandes con icono, nombre y coste.
func _draw_bottom_bar() -> void:
    draw_rect(Rect2(0, 504, W, H - 504), Color(0.02, 0.018, 0.03, 0.95))
    draw_rect(Rect2(0, 504, W, 2), GOLD)
    var items := [
        ["levantar" if sleeping else "descansar", "LEVANTARSE" if sleeping else "DORMIR", "1", "Durmiendo en el lecho ganas ecos.", true],
        ["lecho", "LECHO", "%d" % (18 * bed_level), "+1 eco por segundo al dormir (%d/8)." % bed_level, income >= 18.0 * bed_level and bed_level < 8],
        ["puerta", "PUERTA", "%d" % (25 * gate_level), "Más resistencia y repara 120 (%d/8)." % gate_level, income >= 25.0 * gate_level and gate_level < 8],
        ["centinela", "CENTINELA", "%d" % int(22.0 + float(wards) * 20.0), "Cristal que dispara solo (%d/4)." % wards, income >= 22.0 + float(wards) * 20.0 and wards < 4],
        ["reparar", "REPARAR", "18", "Restaura 85 de la puerta.", income >= 18.0 and gate_hp < gate_max],
        ["generador", "GENERADOR", "%d" % int(35.0 + generator_level * 25.0), "Energía mientras duermes (%d/6)." % generator_level, income >= 35.0 + generator_level * 25.0 and generator_level < 6],
        ["potenciar", "POTENCIAR", "%d EN" % (6 * ward_power), "Más daño de los centinelas (%d/6)." % ward_power, sparks >= 6.0 * ward_power and wards > 0 and ward_power < 6],
        ["escudo", "ESCUDO", "14 EN", "8 s sin daño en la puerta.", sparks >= 14.0 and shield_left <= 0.0],
    ]
    for i in range(items.size()):
        var r := _bottom_rect(i)
        var it: Array = items[i]
        var hot: bool = r.has_point(hover_pos) or (pad_sel == i and tooltip_left > 0.0)
        var can: bool = bool(it[4]) and phase == "play"
        _panel_box(r, Color("#241c2c") if hot else Color("#141018"), GOLD_HI if hot else (GOLD if can else EDGE))
        draw_texture_rect(ICONS[it[0]], Rect2(r.get_center().x - 22.0, r.position.y + 10.0, 44, 44), false, Color.WHITE if can or i == 0 else Color(0.45, 0.45, 0.5, 0.8))
        _text_center(it[1], Rect2(r.position.x, r.position.y + 58.0, r.size.x, 16), 12, CREAM)
        var cost := Rect2(r.position.x + 14.0, r.position.y + 84.0, r.size.x - 28.0, 22)
        _panel_box(cost, Color("#1a1f2a"), SOUL if can else EDGE)
        _text_center(("TOCA" if DisplayServer.is_touchscreen_available() else "TECLA " + it[2]) if i == 0 else it[2], Rect2(cost.position.x, cost.position.y + 2.0, cost.size.x, 16), 12, SOUL if can else Color("#6d6772"))
        if hot and phase == "play":
            _tooltip = [r, it[1], it[3]]


var _tooltip: Array = []
func _draw_tooltip() -> void:
    if _tooltip.is_empty():
        return
    var rect: Rect2 = _tooltip[0]
    var title: String = _tooltip[1]
    var desc: String = _tooltip[2]
    var width: float = maxf(font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x, font.get_string_size(desc, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x) + 28.0
    var x: float = clampf(rect.get_center().x - width * 0.5, 8.0, W - width - 8.0)
    var box := Rect2(x, rect.position.y - 60.0, width, 52.0)
    _panel_box(box, Color(0.03, 0.03, 0.05, 0.97), GOLD)
    draw_string(font, box.position + Vector2(14, 21), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, CREAM)
    draw_string(font, box.position + Vector2(14, 41), desc, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, SOUL)
    _tooltip = []


func _draw_selection() -> void:
    draw_rect(Rect2(0, 64, W, 440), Color(0, 0, 0, 0.6))
    var panel := Rect2(130, 110, 700, 380)
    _modal(panel)
    _title("Vigilia del Claustro", Vector2(130, 168), 44, CREAM, panel.size.x)
    _center_text("Defiende tu celda. Fases sin fin, cada una más dura.", 200, 15, SOUL)
    var steps := [["descansar", "DUERME", "para ganar ecos"], ["centinela", "CONSTRUYE", "centinelas"], ["puerta", "REFUERZA", "la puerta"], ["bolsa_almas", "GANA", "botín para la campaña"]]
    for i in range(steps.size()):
        var cx: float = panel.position.x + 100.0 + float(i) * 166.0
        draw_texture_rect(ICONS[steps[i][0]], Rect2(cx - 28.0, 226, 56, 56), false)
        _text_center(steps[i][1], Rect2(cx - 80.0, 290, 160, 18), 15, CREAM)
        _text_center(steps[i][2], Rect2(cx - 80.0, 310, 160, 16), 12, SOUL)
    _center_text("Cada fase superada te da un objeto para la campaña. Cuanto más lejos, mejor.", 356, 13, GOLD_HI)
    var pulse: float = 0.6 + 0.4 * sin(tick * 3.0)
    _center_text("TOCA O PULSA ENTER PARA EMPEZAR", 412, 18, Color(GOLD_HI.r, GOLD_HI.g, GOLD_HI.b, pulse))
    _center_text("MEJOR FASE: %d   ·   MEJOR PUNTUACIÓN: %d" % [best_stage, high_score], 462, 13, CREAM)


## Fase superada: tarjetas con el botín y botón para seguir.
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
    _center_text("ESC o SALIR: volver al templo con lo ganado", 452, 12, CREAM)


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
