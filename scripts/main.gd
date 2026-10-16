extends Node2D
## Primer piso. Adaptación de los tres documentos GDD, Lore v0.2 y Reglas v0.1.
## Knowledge Temple + GothicVania reales incorporados desde los ZIP aportados.
## Mecánicas no canonizadas se indican como provisionales en docs/DECISIONES.md.

const W: float = 960.0
const H: float = 640.0
const ARENA: Rect2 = Rect2(40.0, 122.0, 880.0, 458.0)
const SAVE_PATH: String = "user://templo_personaje_v03.json"
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
const WALL_COLOR := Color("#394052")
const BG := Color("#090c17")
const CREAM := Color("#d9d2ba")
const SOUL := Color("#8fc7d7")
const RED := Color("#d06470")

## Precarga estatica: Godot detecta estas rutas al importar el proyecto y al exportarlo.
## No cargar PNG mediante rutas construidas dinamicamente: pueden omitirse del import/export.
const ART_PRELOADED := {
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
var torch_on: bool = true
var dash_left: float = 0.0
var dash_cd: float = 0.0
var pulse_cd: float = 0.0
var ward_left: float = 0.0
var damage_cd: float = 0.0
var enemy_stun: float = 0.0
var enemy_pos: Vector2 = Vector2(788, 370)
var enemy_home: Vector2 = Vector2(788, 370)
var enemy_alert: bool = false
var wizard_cast_cd: float = 2.6
var fireballs: Array[Dictionary] = []
var collected: Array[bool] = [false, false, false]
var obstacles: Array[Rect2] = []
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
var toast: String = ""
var toast_left: float = 0.0
var deaths: int = 0
var cleared: int = 0
var ambience: AudioStreamPlayer
var effects: AudioStreamPlayer


func _ready() -> void:
    font = ThemeDB.fallback_font
    randomize()
    _load_progress()
    _load_art()
    ambience = AudioStreamPlayer.new()
    add_child(ambience)
    ambience.stream = load("res://audio/ambient.wav")
    ambience.volume_db = -21.0
    ambience.finished.connect(_repeat_ambience)
    ambience.play()
    effects = AudioStreamPlayer.new()
    add_child(effects)
    effects.stream = load("res://audio/chime.wav")
    effects.volume_db = -12.0
    queue_redraw()

func _load_art() -> void:
    # Preload hace que la ausencia de un asset sea un error comprobable y no invisible.
    art = ART_PRELOADED.duplicate()


func _repeat_ambience() -> void:
    ambience.play()


func _load_progress() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var data = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
    if data is Dictionary:
        identity_number = maxi(1, int(data.get("identity_number", 1)))
        new_humans = maxi(0, int(data.get("new_humans", 0)))
        reincarnations = maxi(0, int(data.get("reincarnations", 0)))
        has_pulse = bool(data.get("has_pulse", false))
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
    torch_on = true
    seal_acquired = false
    observed_rule = remembered_rule
    game_mode = "play"
    _enter_room()
    if remembered_rule:
        _say("Recuerdas la regla del Testigo de una vida anterior.", 4.0)
    else:
        _say("No recuerdas el origen del templo. Busca respuestas.", 4.0)


func _enter_room() -> void:
    player_pos = Vector2(115.0, 359.0)
    player_dir = Vector2.RIGHT
    enemy_pos = Vector2(765.0, 358.0)
    if current_room == 1:
        enemy_pos = Vector2(772.0, 472.0) # Burning Ghoul
    elif current_room == 3:
        enemy_pos = Vector2(773.0, 354.0) # Wizard
    wizard_cast_cd = 2.4
    fireballs.clear()
    enemy_home = enemy_pos
    enemy_stun = 0.0
    enemy_alert = false
    room_elapsed = 0.0
    still_timer = 0.0
    dark_timer = 0.0
    letter_found = false
    collected = [false, false, false]
    ward_left = 0.0
    torch_on = true
    obstacles.clear()
    match current_room:
        0:
            obstacles.append(Rect2(397, 295, 62, 60))
            obstacles.append(Rect2(630, 378, 70, 55))
        1:
            obstacles.append(Rect2(331, 305, 55, 86))
            obstacles.append(Rect2(601, 305, 55, 86))
        2:
            obstacles.append(Rect2(315, 285, 50, 70))
            obstacles.append(Rect2(530, 400, 55, 70))
        3:
            obstacles.append(Rect2(341, 340, 70, 60))
            obstacles.append(Rect2(635, 340, 70, 60))
        4:
            obstacles.append(Rect2(365, 245, 62, 62))
            obstacles.append(Rect2(655, 412, 54, 54))
    _say(ROOM_WHISPERS[current_room], 4.5)


func _input(event: InputEvent) -> void:
    if not (event is InputEventKey):
        return
    if not event.pressed or event.echo:
        return
    var k: Key = event.keycode
    if game_mode == "title":
        if k == KEY_ENTER or k == KEY_KP_ENTER:
            _new_run()
    elif game_mode == "dead" or game_mode == "victory":
        if k == KEY_ENTER or k == KEY_KP_ENTER:
            _new_run()
        elif k == KEY_ESCAPE:
            game_mode = "title"
    elif game_mode == "altar":
        if k == KEY_1:
            _buy_upgrade(1)
        elif k == KEY_ESCAPE or k == KEY_E:
            game_mode = "play"
    elif game_mode == "play":
        if k == KEY_E:
            _interact()
        elif k == KEY_F:
            torch_on = not torch_on
            _say("Linterna " + ("encendida" if torch_on else "apagada") + ".", 1.3)
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


func _buy_upgrade(choice: int) -> void:
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
    effects.play()
    _say("Adquiriste Resonancia nivel 0. Pulsa Q para utilizarla.", 4.0)


func _use_pulse() -> void:
    if not has_pulse:
        _say("Todavía no adquiriste Resonancia en el altar.", 2.0)
        return
    if pulse_cd > 0.0 or stamina < 24.0:
        _say("Resonancia necesita energía o tiempo de recuperación.", 2.0)
        return
    pulse_cd = 11.0
    stamina -= 24.0
    if current_room in [1, 2, 3] and player_pos.distance_to(enemy_pos) < 220.0:
        enemy_stun = 1.6 + 0.5 * float(ability_level)
        _say("La resonancia interrumpe brevemente a la criatura.", 2.2)
    else:
        _say("Una vibración recorre la piedra.", 1.6)
    effects.play()


func _interact() -> void:
    if current_room == 2 and not seal_acquired and player_pos.distance_to(Vector2(704, 343)) < 60.0:
        seal_acquired = true
        remembered_rule = true
        observed_rule = true
        if has_pulse:
            ability_level = maxi(ability_level, 1)
        _save_progress()
        _say("SELLO RECUPERADO. El Testigo se inmoviliza cuando tú te detienes.", 5.0)
        effects.play()
        return
    if current_room == 1 and player_pos.distance_to(Vector2(522, 230)) < 64.0:
        game_mode = "altar"
        return
    if current_room == 3 and player_pos.distance_to(Vector2(507, 355)) < 72.0:
        letter_found = true
        _say("Carta: 'He regresado. El cuerpo cambia, pero recuerdo sus ojos.'", 5.0)
        effects.play()
        return
    for i in range(RELICS.size()):
        if not collected[i] and player_pos.distance_to(RELICS[i]) < 47.0:
            collected[i] = true
            souls += 7
            fear = maxf(0.0, fear - 8.0)
            _say("Fragmento reunido: +7 almas. Es la moneda del templo.", 2.5)
            effects.play()
            return
    if player_pos.distance_to(Vector2(867, 355)) < 74.0:
        if _room_ready():
            if current_room == 4:
                _win_run()
            else:
                current_room += 1
                _enter_room()
        else:
            _say(_required_clue(), 3.2)
        return
    _say("La piedra no responde a tu tacto.", 1.3)

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
    effects.play()

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
        ability_level = 0
        remembered_rule = false
        # Una persona nueva, sin la memoria de la anterior.
    _save_progress()
    game_mode = "dead"


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
    return v.normalized()


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
    if game_mode == "play":
        _update_play(delta)
    queue_redraw()


func _update_play(dt: float) -> void:
    room_elapsed += dt
    dash_cd = maxf(0.0, dash_cd - dt)
    pulse_cd = maxf(0.0, pulse_cd - dt)
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
        if not _is_blocked(nx):
            player_pos.x = nx.x
        var ny := Vector2(player_pos.x, player_pos.y + move.y * speed * dt)
        if not _is_blocked(ny):
            player_pos.y = ny.y

    watcher_open = fmod(room_elapsed, 6.0) < 3.25
    if current_room in [1, 2, 3]:
        _update_enemy(dt)
        var near: float = player_pos.distance_to(enemy_pos)
        if near < 185.0:
            fear += dt * (8.0 if watcher_open else 2.0)
    else:
        fear -= 4.0 * dt
    fear = clampf(fear, 0.0, 100.0)
    if fear >= 100.0:
        hp -= dt * 5.0
    if hp <= 0.0:
        _lose_run()

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


func _draw() -> void:
    draw_rect(Rect2(0, 0, W, H), BG)
    _draw_background()
    if game_mode == "title":
        _draw_title()
        return
    _draw_room()
    _draw_topbar()
    _draw_footer()
    if toast_left > 0.0:
        draw_rect(Rect2(110, 581, 744, 37), Color("#191f2a"))
        _text(toast, Vector2(124, 605), 15, CREAM)
    if game_mode == "altar":
        _draw_altar_overlay()
    elif game_mode == "dead":
        _draw_end_overlay(false)
    elif game_mode == "victory":
        _draw_end_overlay(true)


func _draw_background() -> void:
    for i in range(0, 14):
        var px: float = float(i * 73 + 19)
        var py: float = 54.0 + sin(float(i) * 1.67) * 24.0
        draw_circle(Vector2(px, py), 1.0 + float(i % 3), Color(0.50, 0.64, 0.72, 0.20))
    draw_line(Vector2(35, 105), Vector2(925, 105), Color("#394352"), 1.0)


func _draw_room() -> void:
    var room_bg: Texture2D = art["room_%d" % current_room]
    draw_texture_rect(room_bg, Rect2(0.0, 0.0, W, H), false)
    # Environmental props are authentic textures baked into the backgrounds.
    _draw_door()
    if current_room == 2:
        var rune := Vector2(704, 343)
        draw_arc(rune, 41.0, 0.0, TAU, 48, SOUL if seal_acquired else Color("#be9b68"), 2.0)
        if not seal_acquired:
            _draw_relic(rune, 2)
            _text("SELLO", rune + Vector2(-23, 57), 12, CREAM)
        _draw_watcher_eye(Vector2(765, 245))
    if current_room == 3:
        _draw_letter(Vector2(507, 355))
    if current_room == 1:
        _draw_altar(Vector2(522, 230))
    for i in range(RELICS.size()):
        if not collected[i]:
            _draw_relic(RELICS[i], i)
    if current_room in [1, 2, 3]:
        _draw_enemy()
    if current_room == 3:
        _draw_fireballs()
    _draw_player()
    # Small lighting cue; room architecture remains legible even unlit.
    if torch_on:
        for r in range(4, 0, -1):
            draw_circle(player_pos, float(r) * 37.0, Color(0.87, 0.74, 0.43, 0.012))
    else:
        draw_rect(ARENA, Color(0.0, 0.0, 0.05, 0.09))
    if damage_cd > 0.0:
        draw_rect(ARENA, Color(0.8, 0.1, 0.18, 0.05))


func _draw_watcher_eye(at: Vector2) -> void:
    var tint: Color = RED if watcher_open else Color("#72858d")
    draw_circle(at, 26, Color("#22202a"))
    draw_arc(at, 22, 0.0, TAU, 35, tint, 3.0)
    draw_circle(at, 9.0 if watcher_open else 2.0, tint)
    _text("MIRADA" if watcher_open else "CEGUERA", at + Vector2(-33, -35), 11, tint)


func _draw_door() -> void:
    var ready: bool = _room_ready()
    var tone: Color = Color("#82bdaf") if ready else Color("#904657")
    draw_rect(Rect2(874, 298, 31, 115), Color("#090c0d"))
    draw_texture_rect(art["knowledge_door"], Rect2(865, 300, 38, 106), false)
    draw_rect(Rect2(872, 303, 26, 101), tone, false, 2.0)
    if ready:
        _text("SALIDA", Vector2(852, 288), 12, tone)
    else:
        _text("SELLADA", Vector2(838, 288), 12, tone)


func _draw_altar(at: Vector2) -> void:
    draw_arc(at, 44.0, 0.0, TAU, 48, Color("#b5a179"), 2.0)
    draw_texture_rect(art["knowledge_altar"], Rect2(at.x - 36.0, at.y - 40.0, 72.0, 90.0), false)
    _text("INTERCAMBIO [E]", at + Vector2(-52, 69), 12, CREAM)


func _draw_letter(at: Vector2) -> void:
    draw_circle(at, 31.0, Color(0.59, 0.79, 0.55, 0.09))
    draw_texture_rect(art["knowledge_book"], Rect2(at.x - 34, at.y - 26, 68, 49), false)
    _text("ARCHIVO [E]", at + Vector2(-44, 46), 12, CREAM)


func _draw_relic(at: Vector2, index: int) -> void:
    var wave: float = sin(elapsed * 2.3 + float(index) * 2.5) * 4.0
    var p := at + Vector2(0, wave)
    draw_circle(p, 26.0, Color(0.43, 0.76, 0.87, 0.11))
    draw_circle(p, 13.0, Color("#679ba9"))
    draw_colored_polygon(PackedVector2Array([
        p + Vector2(0, -16), p + Vector2(10, 0),
        p + Vector2(0, 16), p + Vector2(-10, 0)
    ]), SOUL)
    draw_line(p + Vector2(-4, 0), p + Vector2(4, 0), Color.WHITE, 2.0)


func _draw_enemy() -> void:
    var kind: String = "ghoul" if current_room == 1 else ("angel" if current_room == 2 else "wizard")
    var max_frames: int = 5 if kind == "wizard" else 8
    var frame: int = 1 + (int(elapsed * 8.0) % max_frames)
    var texture: Texture2D = art["%s_%d" % [kind, frame]]
    var dims := Vector2(82.0, 87.0)
    if kind == "angel":
        dims = Vector2(135, 123)
    elif kind == "wizard":
        dims = Vector2(115, 95)
    var dest := Rect2(enemy_pos.x - dims.x * 0.5, enemy_pos.y - dims.y + 13.0, dims.x, dims.y)
    draw_circle(enemy_pos + Vector2(0, 9), 24.0, Color(0, 0, 0, 0.35))
    draw_texture_rect(texture, dest, false)
    if enemy_alert:
        draw_arc(enemy_pos, 41.0, 0.0, TAU, 36, RED, 1.6)
    if enemy_stun > 0.0:
        draw_arc(enemy_pos, 40.0, 0.0, TAU, 36, SOUL, 2.0)
        _text("ATURDIDO", enemy_pos + Vector2(-43, -85), 12, SOUL)


func _draw_fireballs() -> void:
    var frame: int = 1 + (int(elapsed * 11.0) % 3)
    for ball in fireballs:
        var p: Vector2 = ball["pos"]
        draw_texture_rect(art["fireball_%d" % frame], Rect2(p.x - 20, p.y - 20, 40, 40), false)


func _draw_player() -> void:
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


func _draw_topbar() -> void:
    _text("EL TEMPLO DE LOS ECOS · PISO 1", Vector2(40, 35), 19, CREAM)
    _text(ROOM_NAMES[current_room], Vector2(40, 66), 14, SOUL)
    _text("SALA %d/5" % (current_room + 1), Vector2(826, 36), 15, CREAM)
    _text("ALMAS: %d" % souls, Vector2(826, 66), 15, SOUL)
    _bar(Rect2(363, 24, 170, 13), hp / max_hp, RED)
    _bar(Rect2(363, 48, 170, 11), stamina / 100.0, Color("#8bbfaf"))
    _bar(Rect2(363, 68, 170, 10), fear / 100.0, Color("#c7a368"))
    _text("VIDA", Vector2(300, 36), 12, CREAM)
    _text("ENERGÍA", Vector2(287, 59), 12, CREAM)
    _text("MIEDO", Vector2(296, 79), 12, CREAM)


func _bar(rect: Rect2, fraction: float, color: Color) -> void:
    draw_rect(rect, Color("#30353d"))
    draw_rect(Rect2(rect.position, Vector2(rect.size.x * clampf(fraction, 0.0, 1.0), rect.size.y)), color)
    draw_rect(rect, Color("#666a75"), false, 1.0)


func _draw_footer() -> void:
    _text("WASD: moverte    E: interactuar    F: linterna    ESPACIO: esquivar", Vector2(44, 598), 14, CREAM)
    _text("Q: Resonancia%s    ESC: menú    Identidad: %03d" % [" (nivel %d)" % ability_level if has_pulse else " (sin adquirir)", identity_number], Vector2(44, 620), 14, SOUL)
    var task: String = "MISIÓN: Recuperar el sello del Testigo"
    if current_room == 1:
        task = "BRASAS: tu luz puede atraer algo"
    elif current_room == 3:
        task = "ARCHIVO: lee la carta, evita los conjuros"
    if current_room == 2:
        task = "OJO ABIERTO: INMÓVIL" if watcher_open else "OJO CERRADO: AVANZA"
        if seal_acquired:
            task = "SELLO RECUPERADO · VE A LA PUERTA"
    _text(task, Vector2(486, 118), 14, SOUL if _room_ready() else CREAM)


func _draw_title() -> void:
    draw_texture_rect(art["room_0"], Rect2(0, 0, W, H), false)
    draw_rect(Rect2(0, 0, W, H), Color(0.015, 0.025, 0.030, 0.78))
    draw_rect(Rect2(100, 201, 760, 391), Color(0.04, 0.08, 0.09, 0.83))
    draw_rect(Rect2(100, 201, 760, 391), Color("#6b7463"), false, 2.0)
    _center("EL TEMPLO", 280, 42, CREAM)
    _center("DE LOS ECOS", 328, 42, SOUL)
    _center("UN DOMINIO QUE SE ALIMENTA DE SUS CAUTIVOS", 375, 18, CREAM)
    _center("No conoces las reglas. Aún.", 422, 18, CREAM)
    _center("[ ENTER ] DESPERTAR", 484, 24, Color("#d6b997"))
    _center("PISO 1 · 5 salas · reglas por descubrir", 525, 15, SOUL)
    _center("Humano %03d  ·  Retornos: %d  ·  Absorciones: %d" % [identity_number, reincarnations, new_humans], 565, 13, CREAM)
    if toast_left > 0:
        _center(toast, 168, 14, RED)


func _draw_altar_overlay() -> void:
    _overlay()
    draw_rect(Rect2(164, 155, 632, 357), Color("#19202b"))
    draw_rect(Rect2(164, 155, 632, 357), Color("#8c8088"), false, 2)
    _center("EL MERCADER SILENCIOSO", 205, 26, CREAM)
    _center("'Todo préstamo tiene un dueño que no conoces.'", 240, 16, SOUL)
    _text("[1] Resonancia (Q) · 14 almas", Vector2(204, 305), 19, CREAM)
    _text("Permite paralizar brevemente al Testigo.", Vector2(204, 343), 15, CREAM)
    _text("Estado: " + ("adquirida, nivel %d" % ability_level if has_pulse else "no adquirida"), Vector2(204, 386), 16, SOUL)
    _text("ALMAS EN TU PODER: %d" % souls, Vector2(204, 441), 17, SOUL)
    _text("E / ESC: salir", Vector2(613, 485), 15, CREAM)

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
