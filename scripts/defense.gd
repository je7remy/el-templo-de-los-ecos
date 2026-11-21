extends Node2D
## Modo alternativo: Vigilia del Claustro, defensa original de una cámara del templo.
## Inspirado en el género de defensa y supervivencia, sin importar recursos de otros juegos.
## Los recursos de este modo no modifican el canon ni el progreso de la campaña.
const W := 960.0
const H := 640.0
const LENGTH := 135.0
const DEFENSE_SAVE := "user://vigilia_claustro_records.json"
const MINT := Color("#d7cfb6")
const BLUE := Color("#9bcfd8")
const GOLD := Color("#e3bd7b")
const CRIMSON := Color("#d1747b")
const DARK := Color("#101722")
## Claustro sin los objetos centrales (herramientas/limpiar_fondos.py).
const ROOM := preload("res://assets/visual/rooms/vigilia.png")
const CHAMBER := Rect2(44, 175, 673, 296)
const HERO := preload("res://assets/visual/protagonist_sheet.png")
const HUNTER := preload("res://assets/gothic_enemies/ghoul_1.png")
const ALT_HUNTER := preload("res://assets/gothic_enemies/angel_1.png")
const WIZARD := preload("res://assets/gothic_enemies/wizard_1.png")
## Entidades originales (herramientas/generar_enemigos.py): celdas 48x64,
## fila 3 = mirando a la izquierda, hacia la puerta. Clave: tipo de oleada.
const MONSTER_SHEETS := {
    "ghoul": preload("res://assets/visual/enemies/ghoul.png"),
    "wizard": preload("res://assets/visual/enemies/hechicero.png"),
    "angel": preload("res://assets/visual/enemies/testigo.png"),
}

var phase: String = "selection" # selection (portada), play, won, lost
var chamber: int = 0 # se conserva por compatibilidad: ya hay un solo modo
## Iconos originales (herramientas/generar_iconos.py) y descripción al pasar el cursor.
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
}
const EXIT_RECT := Rect2(872, 22, 64, 64)
var hover_pos: Vector2 = Vector2(-100, -100)
var tooltip_left: float = 0.0 # en táctil, la descripción se ve un momento tras tocar
var elapsed: float = 0.0
var income: float = 22.0
var income_rate: float = 2.0
var sleeping: bool = false
var bed_level: int = 1
var gate_level: int = 1
var gate_max: float = 150.0
var gate_hp: float = 150.0
var wards: int = 0
var waves: int = 1
var hunter_x: float = 955.0
var hunter_hp: float = 62.0
var hunter_max: float = 62.0
var hunter_cooldown: float = 1.2
var hunter_respawn: float = 0.0
var auto_fire: float = 0.0
var slain: int = 0
var info: String = "Elige un refugio y protege su umbral."
var info_time: float = 4.0
var font: Font
const Ajustes := preload("res://scripts/ajustes.gd")
const PIXEL_FONT := preload("res://assets/fonts/PixelifySans.ttf")
var tick: float = 0.0
var sparks: float = 0.0
var generator_level: int = 0
var ward_power: int = 1
var shield_left: float = 0.0
var paused: bool = false
var hunter_kind: String = "ghoul"
var high_score: int = 0
var best_time: float = 0.0
var session_score: int = 0
## Audio original compartido con la campaña (herramientas/generar_audio.py).
var music: AudioStreamPlayer
var tension: AudioStreamPlayer
var sfx_pool: Array[AudioStreamPlayer] = []
var sfx_streams: Dictionary = {}
var tension_level: float = 0.0

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    # Tipografía pixel (Pixelify Sans, OFL), sin suavizado para que encaje con el pixel art.
    font = PIXEL_FONT
    if font is FontFile:
        var ff := font as FontFile
        ff.antialiasing = TextServer.FONT_ANTIALIASING_NONE
        ff.hinting = TextServer.HINTING_NONE
        ff.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
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
    # Mismos volúmenes que en Configuración (scripts/ajustes.gd).
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
        for key in ["alma", "dano", "sello", "puerta", "linterna", "muerte", "interfaz", "toque"]:
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

## Un solo modo: las ventajas de las antiguas tres cámaras se reparten.
## El parámetro se ignora (se mantiene para no romper llamadas antiguas).
func _start(_choice: int = 0) -> void:
    chamber = 0
    phase = "play"
    elapsed = 0.0
    income = 30.0
    income_rate = 2.0
    sparks = 0.0
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
    income_rate = 2.5
    sparks = 4.0
    wards = 0
    waves = 1
    slain = 0
    auto_fire = 0.0
    _respawn_hunter()
    _say("Descansa para ganar ecos. Construye defensas. Resiste.")
    queue_redraw()

func _load_records() -> void:
    if not FileAccess.file_exists(DEFENSE_SAVE):
        return
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(DEFENSE_SAVE))
    if parsed is Dictionary:
        high_score = maxi(0, int(parsed.get("high_score", 0)))
        best_time = maxf(0.0, float(parsed.get("best_time", 0.0)))

func _save_records() -> void:
    var file := FileAccess.open(DEFENSE_SAVE, FileAccess.WRITE)
    if file != null:
        file.store_string(JSON.stringify({
            "high_score": high_score,
            "best_time": best_time,
            "version": 1
        }))

func _record_end(win: bool) -> void:
    var bonus: int = 300 if win else 0
    session_score = slain * 50 + int(elapsed) * 3 + (gate_level + bed_level + wards * ward_power) * 10 + bonus
    high_score = maxi(high_score, session_score)
    best_time = maxf(best_time, minf(elapsed, LENGTH))
    _save_records()

func _say(message: String) -> void:
    info = message
    info_time = 3.5

func _respawn_hunter() -> void:
    hunter_x = 962.0
    var kinds: Array[String] = ["ghoul", "wizard", "angel"]
    hunter_kind = kinds[(waves - 1) % kinds.size()]
    hunter_max = (52.0 + float(waves) * 32.0) * (1.25 if hunter_kind == "angel" else 1.0)
    hunter_hp = hunter_max
    hunter_cooldown = 1.0
    hunter_respawn = 0.0

func _action(choice: int) -> bool:
    if phase != "play":
        return false
    if choice == 8:
        paused = not paused
        _say("Vigilia pausada." if paused else "La vigilia continua.")
        queue_redraw()
        return true
    if paused:
        return false
    match choice:
        0:
            sleeping = not sleeping
            _say("Descansas para generar ecos." if sleeping else "Te has levantado. Sin ingresos.")
        1:
            var cost: float = 18.0 * float(bed_level)
            if income < cost or bed_level >= 8:
                _say("Ecos insuficientes o cama al maximo.")
                return false
            income -= cost
            bed_level += 1
            income_rate = 1.5 + float(bed_level)
            _say("Lecho mejorado: +%d ecos/s." % int(income_rate))
        2:
            var cost: float = 25.0 * float(gate_level)
            if income < cost or gate_level >= 8:
                _say("Necesitas mas ecos para reforzar el umbral.")
                return false
            income -= cost
            gate_level += 1
            gate_max += 95.0
            gate_hp = minf(gate_max, gate_hp + 120.0)
            _say("Puerta reforzada a nivel %d." % gate_level)
        3:
            var cost: float = 22.0 + float(wards) * 20.0
            if income < cost or wards >= 4:
                _say("Ecos insuficientes o cuatro defensas construidas.")
                return false
            income -= cost
            wards += 1
            _say("Un centinela ha despertado. Defensas: %d/4." % wards)
        4:
            if income < 18.0 or gate_hp >= gate_max:
                _say("Reparacion innecesaria o faltan ecos.")
                return false
            income -= 18.0
            gate_hp = minf(gate_max, gate_hp + 85.0)
            _say("La piedra del umbral ha sido reparada.")
        5:
            var cost: float = 35.0 + 25.0 * float(generator_level)
            if income < cost or generator_level >= 6:
                _say("Faltan ecos o el generador alcanzo su limite.")
                return false
            income -= cost
            generator_level += 1
            _say("Generador %d: la energia fluye mientras descansas." % generator_level)
        6:
            var cost: float = 6.0 * float(ward_power)
            if sparks < cost or wards < 1 or ward_power >= 6:
                _say("Construye un centinela y produce mas energia.")
                return false
            sparks -= cost
            ward_power += 1
            _say("Los centinelas ahora infligen mas dano.")
        7:
            if sparks < 14.0 or shield_left > 0.0:
                _say("Necesitas 14 de energia y el escudo inactivo.")
                return false
            sparks -= 14.0
            shield_left = 8.0
            _say("Escudo protector: 8 segundos de inmunidad al umbral.")
        _:
            return false
    _sfx("sello" if choice == 3 else "interfaz", -10.0, 1.3 if choice == 3 else 1.0)
    queue_redraw()
    return true

func _process(delta: float) -> void:
    tick += delta
    info_time = maxf(0.0, info_time - delta)
    tooltip_left = maxf(0.0, tooltip_left - delta)
    if phase == "play" and not paused:
        _advance(delta)
    # Tensión: sube cuando la entidad llega a la puerta y con la puerta dañada.
    if tension != null and tension.stream != null:
        var target: float = 0.0
        if phase == "play" and hunter_respawn <= 0.0:
            target = clampf((900.0 - hunter_x) / 165.0, 0.0, 1.0) * 0.6 + (1.0 - clampf(gate_hp / gate_max, 0.0, 1.0)) * 0.5
        tension_level = move_toward(tension_level, clampf(target, 0.0, 1.0), delta * 0.5)
        tension.volume_db = linear_to_db(maxf(tension_level, 0.001)) - 8.0
    queue_redraw()

func _advance(dt: float) -> void:
    elapsed += dt
    waves = 1 + int(elapsed / 25.0)
    shield_left = maxf(0.0, shield_left - dt)
    if sleeping:
        income += dt * income_rate
        sparks += dt * float(generator_level) * 0.85
    best_time = maxf(best_time, minf(elapsed, LENGTH))
    if elapsed >= LENGTH:
        phase = "won"
        _sfx("sello", -4.0, 0.8)
        _record_end(true)
        sleeping = false
        _say("Has sobrevivido a la vigilia. El templo mantiene sus secretos.")
        return
    if hunter_respawn > 0.0:
        hunter_respawn -= dt
        if hunter_respawn <= 0.0:
            _respawn_hunter()
        return
    # El cazador avanza hacia la puerta de la cámara.
    hunter_x = maxf(735.0, hunter_x - (28.0 + waves * 6.5) * dt)
    if wards > 0 and hunter_x < 938.0:
        auto_fire -= dt
        if auto_fire <= 0.0:
            hunter_hp -= float(wards * ward_power) * 12.0
            auto_fire = 0.58
            if hunter_hp <= 0.0:
                slain += 1
                income += 9.0 + waves * 2.0
                hunter_respawn = 2.4
                hunter_x = 1000.0
                _say("Centinelas: entidad repelida. Ecos recuperados.")
                _sfx("alma", -7.0)
                return
    if hunter_x <= 736.0:
        hunter_cooldown -= dt
        if hunter_cooldown <= 0.0:
            hunter_cooldown = maxf(0.55, 1.75 - waves * 0.10)
            gate_hp -= 14.0 + waves * 4.0
            if shield_left > 0.0:
                gate_hp += 14.0 + waves * 4.0
            else:
                _sfx("puerta", -9.0, 1.3)
            if gate_hp <= 0.0:
                gate_hp = 0.0
                _record_end(false)
                sleeping = false
                phase = "lost"
                _sfx("muerte", -4.0)
                _say("La puerta ha cedido. La vigilia ha terminado.")

func _input(event: InputEvent) -> void:
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
        elif phase in ["won", "lost"] and k == KEY_ENTER:
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
    if at.x > 847.0 and at.y < 92.0:
        _leave()
        return
    if phase == "selection":
        if at.y > 270.0 and at.y < 515.0:
            _start()
        return
    if phase in ["won", "lost"]:
        if at.y > 350.0:
            _start(chamber)
        return
    if phase == "play":
        if at.y >= 556.0:
            _action(clampi(int(at.x / 192.0), 0, 4))
        elif at.y >= 484.0 and at.y < 555.0:
            _action(5 + clampi(int(at.x / 240.0), 0, 3))
        elif Rect2(115, 250, 225, 190).has_point(at):
            _action(0)

func _leave() -> void:
    get_tree().change_scene_to_file("res://scenes/main.tscn")

func _draw() -> void:
    draw_texture_rect(ROOM, Rect2(0, 0, W, H), false)
    if phase == "selection":
        draw_rect(Rect2(0, 0, W, H), Color(0.015, 0.028, 0.047, 0.58))
    else:
        # Fuera de la cámara, el claustro queda en penumbra.
        var shade := Color(0.01, 0.02, 0.035, 0.50)
        draw_rect(Rect2(0, 0, W, CHAMBER.position.y - 12), shade)
        draw_rect(Rect2(0, CHAMBER.end.y + 12, W, H - CHAMBER.end.y - 12), shade)
        draw_rect(Rect2(0, CHAMBER.position.y - 12, CHAMBER.position.x - 12, CHAMBER.size.y + 24), shade)
        draw_rect(Rect2(CHAMBER.end.x + 26, CHAMBER.position.y - 12, W, CHAMBER.size.y + 24), Color(0.01, 0.02, 0.035, 0.30))
    draw_rect(Rect2(0, 0, 960, 111), DARK)
    draw_rect(Rect2(0, 109, 960, 2), GOLD)
    _label("VIGILIA DEL CLAUSTRO", Vector2(24, 38), 28, MINT)
    _label("Una prueba de defensa en el templo • sin alterar la campaña", Vector2(24, 71), 13, BLUE)
    _icon_button(EXIT_RECT, "salir", "", "SALIR", "Vuelve al menú del templo. ESC.")
    if phase == "selection":
        _draw_selection()
        _draw_tooltip()
        return
    _draw_chamber()
    _draw_tooltip()
    if paused and phase == "play":
        draw_rect(Rect2(160, 185, 640, 255), Color(0.025, 0.039, 0.060, 0.93))
        draw_rect(Rect2(160, 185, 640, 255), GOLD, false, 2)
        _center("VIGILIA EN PAUSA", 270, 31, MINT)
        _center("TOCA PAUSA O P PARA CONTINUAR", 343, 19, GOLD)
    if phase in ["won", "lost"]:
        draw_rect(Rect2(130, 183, 700, 323), Color(0.02, 0.035, 0.07, 0.94))
        draw_rect(Rect2(130, 183, 700, 323), GOLD, false, 2)
        _center("AMANECER: HAS RESISTIDO" if phase == "won" else "EL UMBRAL HA CAIDO", 263, 29, BLUE if phase == "won" else CRIMSON)
        _center("Entidades: %d  |  Tiempo: %d s  |  Puntos: %d" % [slain, int(elapsed), session_score], 324, 19)
        _center("TOCA PARA REINTENTAR • ESC PARA VOLVER", 416, 17, GOLD)

func _draw_selection() -> void:
    _center("UNA NOCHE EN LA CÁMARA", 206, 27, MINT)
    _center("Resiste %d segundos hasta el amanecer." % int(LENGTH), 247, 17, BLUE)
    # Portada: un panel que se toca para empezar (misma zona táctil de antes).
    var panel := Rect2(130, 280, 700, 225)
    draw_rect(panel, Color(0.05, 0.09, 0.12, 0.92))
    draw_rect(panel, GOLD, false, 2)
    var steps := [["descansar", "DESCANSA", "para ganar ecos"], ["centinela", "DESPIERTA", "centinelas"], ["puerta", "REFUERZA", "el umbral"]]
    for i in range(steps.size()):
        var cx: float = panel.position.x + 120.0 + float(i) * 230.0
        draw_texture_rect(ICONS[steps[i][0]], Rect2(cx - 32.0, 300, 64, 64), false)
        _text_centered(steps[i][1], Rect2(cx - 110.0, 368, 220, 24), 17, MINT)
        _text_centered(steps[i][2], Rect2(cx - 110.0, 392, 220, 22), 13, BLUE)
    var pulse: float = 0.6 + 0.4 * sin(tick * 3.0)
    _center("TOCA O PULSA ENTER PARA COMENZAR", 478, 18, Color(GOLD.r, GOLD.g, GOLD.b, pulse))
    _center("MEJOR PUNTAJE: %d  |  MAXIMA SUPERVIVENCIA: %d s" % [high_score, int(best_time)], 561, 15, GOLD)

func _draw_chamber() -> void:
    var progress: float = minf(1.0, elapsed / LENGTH)
    _label("NOCHE %d  |  %d/%d s" % [waves, int(elapsed), int(LENGTH)], Vector2(22, 135), 16, MINT)
    _label("ECOS: %d  +%d/s   ENERGIA: %d" % [int(income), int(income_rate) if sleeping else 0, int(sparks)], Vector2(338, 135), 17, GOLD)
    draw_rect(Rect2(22, 145, 914, 8), Color("#33434a"))
    draw_rect(Rect2(22, 145, 914 * progress, 8), BLUE)
    # Cámara protegida dentro del claustro: luz cálida, muros bajos de piedra.
    _draw_floor_glow(Vector2(222, 330), 170.0, Color(0.95, 0.75, 0.45), 0.045 if not sleeping else 0.07)
    _draw_floor_glow(Vector2(485, 335), 150.0, Color(0.56, 0.80, 0.86), 0.03 + 0.012 * float(wards))
    _draw_chamber_walls()
    _draw_bed(Rect2(130, 269, 184, 147))
    # Defensas aparecen en espacios edificables y atacan automaticamente.
    for slot in range(4):
        var p := Vector2(425 + (slot % 2) * 120, 255 + (slot / 2) * 160)
        _draw_slot(p, slot < wards)
    # Puerta, barra de vida y entidad antagonista.
    _draw_gate(Rect2(710, 269, 33, 182))
    draw_rect(Rect2(662, 254, 130, 9), Color("#60383c"))
    draw_rect(Rect2(662, 254, 130 * clampf(gate_hp / gate_max, 0.0, 1.0), 9), BLUE)
    _tag("PUERTA NIV %d" % gate_level, Vector2(727, 243), 12, MINT)
    if shield_left > 0.0:
        draw_rect(Rect2(702, 266, 51, 195), Color(0.17, 0.85, 0.91, 0.21))
        _tag("ESCUDO %d" % int(ceilf(shield_left)), Vector2(680, 290), 12, BLUE)
    if hunter_respawn <= 0.0:
        var hpos := Vector2(hunter_x, 365.0 + sin(tick * 2.0) * 7.0)
        var sheet: Texture2D = MONSTER_SHEETS[hunter_kind]
        var attacking: bool = hunter_x <= 736.0
        var frame: int = 2 + int(tick * 8.0) % 4 # caminando hacia la puerta
        if hunter_kind == "angel":
            frame = int(tick * 6.0) % 4 # flota con el ojo abierto
        elif attacking:
            frame = 6 + int(tick * 6.0) % 2 if hunter_kind == "wizard" else int(tick * 3.0) % 2
        var feet := Vector2(roundf(hpos.x), roundf(hpos.y + 12.0))
        for i in range(3):
            var k: float = 1.0 - float(i) * 0.28
            draw_set_transform(Vector2(hunter_x, 380.0), 0.0, Vector2(1.0, 0.32))
            draw_circle(Vector2.ZERO, 18.0 * k, Color(0, 0, 0, 0.14))
        draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
        draw_texture_rect_region(sheet, Rect2(feet.x - 24.0, feet.y - 61.0, 48.0, 64.0), Rect2(frame * 48.0, 3.0 * 64.0, 48.0, 64.0))
        # Barra de vida sobre la cabeza, siempre dentro de la pantalla.
        var bar_top: float = feet.y - 66.0
        var bar_x: float = clampf(hpos.x - 30.0, 8.0, W - 68.0)
        draw_rect(Rect2(bar_x - 1, bar_top - 1, 62, 7), Color(0, 0, 0, 0.6))
        draw_rect(Rect2(bar_x, bar_top, 60, 5), Color("#493137"))
        draw_rect(Rect2(bar_x, bar_top, 60 * clampf(hunter_hp / hunter_max, 0, 1), 5), CRIMSON)
        if wards > 0 and hunter_x < 938:
            for n in range(wards):
                var source := Vector2(425 + (n % 2) * 120, 255 + (n / 2) * 160)
                draw_line(source, hpos, Color(0.56, 0.85, 0.93, 0.25 + 0.14 * sin(tick * 10.0)), 2)
    draw_string(font, Vector2(560, 135), "REPELIDAS: %d  |  PUNTOS: %d" % [slain, slain * 50 + int(elapsed) * 3], HORIZONTAL_ALIGNMENT_RIGHT, 376.0, 13, BLUE)
    if info_time > 0.0:
        _tag(info, Vector2(CHAMBER.position.x + CHAMBER.size.x * 0.5, CHAMBER.end.y - 14), 12, GOLD)
    # Botones con icono: la zona táctil es la misma que antes.
    var tech := [
        ["generador", "%d ecos · 6" % int(35.0 + generator_level * 25.0), "GENERADOR  [6]", "Produce energía mientras descansas. Nivel %d/6." % generator_level],
        ["potenciar", "%d energía · 7" % (6 * ward_power), "POTENCIAR  [7]", "Los centinelas golpean más fuerte. Poder %d/6." % ward_power],
        ["escudo", "14 energía · 8", "ESCUDO  [8]", "La puerta no recibe daño durante 8 segundos."],
        ["reanudar" if paused else "pausa", "P", "REANUDAR" if paused else "PAUSA", "Detiene o reanuda la noche."],
    ]
    for i in range(4):
        _icon_button(Rect2(12 + i * 238.0, 490, 226, 60), tech[i][0], tech[i][1], tech[i][2], tech[i][3])
    var base := [
        ["levantar" if sleeping else "descansar", "ESPACIO · 1", "LEVANTARSE  [1]" if sleeping else "DESCANSAR  [1]", "Dormido en el lecho ganas ecos. Despierto, nada."],
        ["lecho", "%d ecos · 2" % (18 * bed_level), "LECHO  [2]", "Mejora la cama: +1 eco por segundo al descansar. Nivel %d/8." % bed_level],
        ["puerta", "%d ecos · 3" % (25 * gate_level), "PUERTA  [3]", "Refuerza el umbral: más resistencia y repara 120."],
        ["centinela", "%d ecos · 4" % (22 + 20 * wards), "CENTINELA  [4]", "Despierta una estatua que ataca sola (%d/4)." % wards],
        ["reparar", "18 ecos · 5", "REPARAR  [5]", "Restaura 85 de resistencia de la puerta."],
    ]
    for idx in range(5):
        _icon_button(Rect2(12 + idx * 191, 558, 181, 69), base[idx][0], base[idx][1], base[idx][2], base[idx][3])

func _draw_floor_glow(center: Vector2, radius: float, color: Color, strength: float) -> void:
    draw_set_transform(center, 0.0, Vector2(1.0, 0.62))
    for i in range(14):
        var k: float = 1.0 - float(i) * 0.065
        draw_circle(Vector2.ZERO, radius * k, Color(color.r, color.g, color.b, strength * 0.36))
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Muro bajo de sillares alrededor de la cámara, con hueco para la puerta.
func _wall_segment(rect: Rect2) -> void:
    draw_rect(Rect2(rect.position + Vector2(3, 4), rect.size), Color(0, 0, 0, 0.30))
    draw_rect(rect, Color("#3d4335"))
    var horizontal: bool = rect.size.x > rect.size.y
    var length: float = rect.size.x if horizontal else rect.size.y
    var course: int = 0
    var t: float = 0.0
    while t < length:
        var block: float = 18.0 if course % 2 == 0 else 14.0
        var along := Vector2(t, 0.0) if horizontal else Vector2(0.0, t)
        var span := Vector2(minf(block, length - t), rect.size.y) if horizontal else Vector2(rect.size.x, minf(block, length - t))
        draw_rect(Rect2(rect.position + along, span), Color("#4a5240") if course % 3 != 1 else Color("#434a3a"))
        draw_rect(Rect2(rect.position + along, Vector2(span.x, 2.0) if horizontal else Vector2(2.0, span.y)), Color("#66705a"))
        t += block
        course += 1
    draw_rect(rect, Color("#171a13"), false, 1.0)


func _draw_chamber_walls() -> void:
    var c := CHAMBER
    var thick: float = 12.0
    _wall_segment(Rect2(c.position.x - thick, c.position.y - thick, c.size.x + thick * 2.0, thick))
    _wall_segment(Rect2(c.position.x - thick, c.position.y, thick, c.size.y))
    _wall_segment(Rect2(c.position.x - thick, c.end.y, c.size.x + thick * 2.0, thick))
    # Lado derecho: el umbral (puerta) ocupa el hueco del muro.
    _wall_segment(Rect2(c.end.x - 7.0, c.position.y, thick + 14.0, 269.0 - c.position.y - 8.0))
    _wall_segment(Rect2(c.end.x - 7.0, 459.0, thick + 14.0, c.end.y - 459.0))


## Espacio para centinela: círculo rúnico en el suelo; ocupado, un pedestal.
func _draw_slot(p: Vector2, occupied: bool) -> void:
    draw_set_transform(p + Vector2(0, 14), 0.0, Vector2(1.0, 0.45))
    draw_arc(Vector2.ZERO, 30.0, 0.0, TAU, 40, Color(GOLD.r, GOLD.g, GOLD.b, 0.55 if occupied else 0.30), 2.0)
    draw_arc(Vector2.ZERO, 23.0, 0.0, TAU, 32, Color(BLUE.r, BLUE.g, BLUE.b, 0.35 if occupied else 0.15), 1.0)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
    if occupied:
        draw_rect(Rect2(p.x - 11, p.y + 4, 22, 12), Color("#4a5240"))
        draw_rect(Rect2(p.x - 11, p.y + 4, 22, 3), Color("#6b7560"))
        draw_rect(Rect2(p.x - 11, p.y + 4, 22, 12), Color("#171a13"), false, 1.0)
        _draw_sentinel(p + Vector2(0, -12))
    else:
        var a: float = 0.45 + 0.2 * sin(tick * 2.0 + p.x)
        draw_line(p + Vector2(-7, 14), p + Vector2(7, 14), Color(MINT.r, MINT.g, MINT.b, a), 2.0)
        draw_line(p + Vector2(0, 7), p + Vector2(0, 21), Color(MINT.r, MINT.g, MINT.b, a), 2.0)


## Lecho: marco de madera, almohada y manta; el durmiente aparece sobre él.
func _draw_bed(area: Rect2) -> void:
    var frame := Rect2(area.position.x + 26, area.position.y + 14, 132, 92)
    draw_rect(Rect2(frame.position + Vector2(4, 6), frame.size), Color(0, 0, 0, 0.35))
    draw_rect(frame, Color("#4a3426"))
    draw_rect(Rect2(frame.position, Vector2(frame.size.x, 5)), Color("#6b4c37"))
    draw_rect(frame.grow(-6), Color("#2c3d43"))
    draw_rect(Rect2(frame.position.x + 10, frame.position.y + 12, 34, frame.size.y - 24), Color("#cfc6b0"))
    draw_rect(Rect2(frame.position.x + 10, frame.position.y + 12, 34, 4), Color("#ebe3cf"))
    var blanket := Rect2(frame.position.x + 50, frame.position.y + 8, frame.size.x - 58, frame.size.y - 16)
    draw_rect(blanket, Color("#3f6a6e") if not sleeping else Color("#4f8187"))
    for i in range(3):
        draw_line(Vector2(blanket.position.x + 14 + i * 22, blanket.position.y + 4), Vector2(blanket.position.x + 14 + i * 22, blanket.end.y - 4), Color(1, 1, 1, 0.06), 2.0)
    draw_rect(frame, Color("#1b130d"), false, 2.0)
    if sleeping:
        # De lado, con la cabeza sobre la almohada.
        draw_set_transform(Vector2(frame.position.x + 27, frame.position.y + 46), -PI * 0.5, Vector2.ONE)
        draw_texture_rect_region(HERO, Rect2(-20, -14, 40, 56), Rect2(0, 0, 40, 56))
        draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
        var z: float = fmod(tick, 2.0)
        _label("z", Vector2(frame.position.x + 52 + z * 10.0, frame.position.y + 8 - z * 12.0), 14, Color(BLUE.r, BLUE.g, BLUE.b, 1.0 - z * 0.5))
    _tag("LECHO NIV %d" % bed_level, Vector2(area.position.x + area.size.x * 0.5, area.end.y - 12), 14, MINT)
    _tag("DURMIENDO" if sleeping else "TOCA PARA DESCANSAR", Vector2(area.position.x + area.size.x * 0.5, area.end.y + 12), 12, BLUE if sleeping else GOLD)


## Puerta del umbral: tablones con herrajes; se agrieta al perder resistencia.
func _draw_gate(area: Rect2) -> void:
    draw_rect(Rect2(area.position - Vector2(6, 8), Vector2(area.size.x + 12, 8)), Color("#4b5145"))
    draw_rect(Rect2(area.position.x - 6, area.end.y, area.size.x + 12, 8), Color("#4b5145"))
    draw_rect(area, Color("#5a3f2c"))
    for i in range(3):
        draw_line(Vector2(area.position.x + 8 + i * 9, area.position.y), Vector2(area.position.x + 8 + i * 9, area.end.y), Color("#3b281b"), 1.0)
    for y in [area.position.y + 26, area.end.y - 30]:
        draw_rect(Rect2(area.position.x, y, area.size.x, 6), Color("#2b2d2e"))
        draw_circle(Vector2(area.position.x + 6, y + 3), 2.0, Color("#8a8f8c"))
        draw_circle(Vector2(area.end.x - 6, y + 3), 2.0, Color("#8a8f8c"))
    var damage: float = 1.0 - clampf(gate_hp / gate_max, 0.0, 1.0)
    if damage > 0.25:
        draw_polyline(PackedVector2Array([area.position + Vector2(10, 60), area.position + Vector2(20, 82), area.position + Vector2(13, 104)]), Color("#1a120b"), 2.0)
    if damage > 0.6:
        draw_polyline(PackedVector2Array([area.position + Vector2(24, 120), area.position + Vector2(14, 140), area.position + Vector2(22, 162)]), Color("#1a120b"), 2.0)
    draw_rect(area, Color("#1b130d"), false, 2.0)


## Centinela: cristal flotante con halo, en la misma línea visual que las reliquias.
func _draw_sentinel(p: Vector2) -> void:
    var bob: float = sin(tick * 2.4 + p.x * 0.05) * 3.0
    var c := p + Vector2(0, -4 + bob)
    for r in range(3, 0, -1):
        draw_circle(c, 6.0 + float(r) * 5.0, Color(BLUE.r, BLUE.g, BLUE.b, 0.06))
    draw_colored_polygon(PackedVector2Array([c + Vector2(0, -16), c + Vector2(0, 0), c + Vector2(0, 14), c + Vector2(-9, -1)]), Color("#bfe9f2"))
    draw_colored_polygon(PackedVector2Array([c + Vector2(0, -16), c + Vector2(9, -1), c + Vector2(0, 14), c + Vector2(0, 0)]), Color("#5ea7bb"))
    draw_polyline(PackedVector2Array([c + Vector2(0, -16), c + Vector2(9, -1), c + Vector2(0, 14), c + Vector2(-9, -1), c + Vector2(0, -16)]), Color("#e8fbff"), 1.0)


## Botón de imagen: icono grande y coste pequeño. El nombre y la descripción
## aparecen al pasar el cursor por encima (o al tocarlo, un momento).
var _tooltip: Array = [] # [rect, título, descripción] del botón señalado
func _icon_button(rect: Rect2, icon: String, cost: String, heading: String, detail: String) -> void:
    var hover: bool = rect.has_point(hover_pos)
    draw_rect(rect, Color("#1d3a47") if hover else Color("#172e39"))
    draw_rect(rect, Color("#f3d79d") if hover else GOLD, false, 2)
    var side: float = minf(rect.size.y - (20.0 if cost != "" else 8.0), 48.0)
    var icon_rect := Rect2(rect.get_center().x - side * 0.5, rect.position.y + 4.0, side, side)
    draw_texture_rect(ICONS[icon], icon_rect, false)
    if cost != "":
        _text_centered(cost, Rect2(rect.position.x, rect.end.y - 21.0, rect.size.x, 16), 11, GOLD)
    if hover:
        _tooltip = [rect, heading, detail]


func _draw_tooltip() -> void:
    if _tooltip.is_empty():
        return
    var rect: Rect2 = _tooltip[0]
    if not rect.has_point(hover_pos) or (tooltip_left <= 0.0 and DisplayServer.is_touchscreen_available()):
        _tooltip = []
        return
    var title: String = _tooltip[1]
    var desc: String = _tooltip[2]
    var width: float = maxf(font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x, font.get_string_size(desc, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x) + 28.0
    var x: float = clampf(rect.get_center().x - width * 0.5, 8.0, W - width - 8.0)
    var box := Rect2(x, minf(rect.position.y, 490.0) - 62.0, width, 54.0) # sobre las dos filas
    if box.position.y < 4.0:
        box.position.y = rect.end.y + 8.0 # botones de arriba: la descripción va debajo
    draw_rect(box, Color(0.03, 0.05, 0.07, 0.96))
    draw_rect(box, GOLD, false, 1.0)
    draw_string(font, box.position + Vector2(14, 22), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, MINT)
    draw_string(font, box.position + Vector2(14, 43), desc, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, BLUE)
    _tooltip = []


## Etiqueta centrada con fondo oscuro, legible sobre el suelo del templo.
func _tag(text_value: String, center: Vector2, size: int, color: Color) -> void:
    var width: float = font.get_string_size(text_value, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
    draw_rect(Rect2(center.x - width * 0.5 - 6, center.y - size + 1, width + 12, size + 6), Color(0.03, 0.05, 0.06, 0.78))
    draw_string(font, Vector2(center.x - width * 0.5, center.y + 2), text_value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


func _label(text_value: String, at: Vector2, size: int = 16, color: Color = MINT) -> void:
    draw_string(font, at, text_value, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, color)

func _center(text_value: String, y: float, size: int = 16, color: Color = MINT) -> void:
    draw_string(font, Vector2(40, y), text_value, HORIZONTAL_ALIGNMENT_CENTER, 880.0, size, color)

func _text_centered(text_value: String, rect: Rect2, size: int, color: Color) -> void:
    draw_string(font, Vector2(rect.position.x, rect.position.y + size + 4), text_value, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, size, color)
