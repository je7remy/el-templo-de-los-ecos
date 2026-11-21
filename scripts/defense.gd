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
const ROOM := preload("res://assets/visual/rooms/room_1.png")
const HERO := preload("res://assets/visual/protagonist_sheet.png")
const HUNTER := preload("res://assets/gothic_enemies/ghoul_1.png")
const ALT_HUNTER := preload("res://assets/gothic_enemies/angel_1.png")
const WIZARD := preload("res://assets/gothic_enemies/wizard_1.png")
## Caja útil de cada sprite (x0, x1, y_base) y escala uniforme: evita deformarlos.
const MONSTER_FRAMES := {
    "angel": [13.0, 108.0, 112.0, 0.62],
    "ghoul": [9.0, 49.0, 59.0, 1.25],
    "wizard": [21.0, 55.0, 65.0, 1.3],
}

var phase: String = "selection" # selection, play, won, lost
var chamber: int = 0
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

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    font = ThemeDB.fallback_font
    _load_records()
    queue_redraw()

func _start(choice: int = 0) -> void:
    chamber = clampi(choice, 0, 2)
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
    gate_max = 150.0 + (125.0 if chamber == 1 else 0.0)
    gate_hp = gate_max
    if chamber == 0:
        income_rate += 1.0
    elif chamber == 2:
        sparks = 8.0
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
            income_rate = 1.0 + float(bed_level) + (1.0 if chamber == 0 else 0.0)
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
    queue_redraw()
    return true

func _process(delta: float) -> void:
    tick += delta
    info_time = maxf(0.0, info_time - delta)
    if phase == "play" and not paused:
        _advance(delta)
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
                return
    if hunter_x <= 736.0:
        hunter_cooldown -= dt
        if hunter_cooldown <= 0.0:
            hunter_cooldown = maxf(0.55, 1.75 - waves * 0.10)
            gate_hp -= 14.0 + waves * 4.0
            if shield_left > 0.0:
                gate_hp += 14.0 + waves * 4.0
            if gate_hp <= 0.0:
                gate_hp = 0.0
                _record_end(false)
                sleeping = false
                phase = "lost"
                _say("La puerta ha cedido. La vigilia ha terminado.")

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            _tap(make_input_local(event).position)
    elif event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            _tap(make_input_local(event).position)
    elif event is InputEventKey and event.pressed and not event.echo:
        var k: Key = event.keycode
        if k == KEY_ESCAPE:
            _leave()
        elif phase == "selection" and k in [KEY_ENTER, KEY_SPACE]:
            _start(0)
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
    if at.x > 847.0 and at.y < 92.0:
        _leave()
        return
    if phase == "selection":
        if at.y > 270.0 and at.y < 515.0:
            _start(clampi(int(at.x / 320.0), 0, 2))
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
    draw_rect(Rect2(0, 0, W, H), Color(0.015, 0.028, 0.047, 0.58))
    draw_rect(Rect2(0, 0, 960, 111), DARK)
    draw_rect(Rect2(0, 109, 960, 2), GOLD)
    _label("VIGILIA DEL CLAUSTRO", Vector2(24, 38), 28, MINT)
    _label("Una prueba de defensa en el templo • sin alterar la campaña", Vector2(24, 71), 13, BLUE)
    _button(Rect2(849, 17, 91, 64), "SALIR", "")
    if phase == "selection":
        _draw_selection()
        return
    _draw_chamber()
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
    _center("ELIGE UNA CAMARA PARA PROTEGER", 206, 27, MINT)
    _center("Descansa para ganar ecos. Refuerza la puerta. Despierta centinelas.", 247, 17, BLUE)
    var names := ["UMBRAL", "CLAUSTRO", "ARCHIVO"]
    var buffs := ["+1 eco/s al descansar", "+125 resistencia de puerta", "+8 energia inicial"]
    for i in range(3):
        var cell := Rect2(22.0 + i * 316.0, 300, 290, 178)
        draw_rect(cell, Color(0.07, 0.12 + float(i) * 0.025, 0.15, 0.90))
        draw_rect(cell, GOLD, false, 2)
        _text_centered(names[i], cell, 25, MINT)
        _text_centered(buffs[i], Rect2(cell.position.x, cell.position.y + 80, cell.size.x, 40), 14, BLUE)
    _center("MEJOR PUNTAJE: %d  |  MAXIMA SUPERVIVENCIA: %d s" % [high_score, int(best_time)], 561, 15, GOLD)

func _draw_chamber() -> void:
    var progress: float = minf(1.0, elapsed / LENGTH)
    _label("NOCHE %d  |  %d/%d s" % [waves, int(elapsed), int(LENGTH)], Vector2(22, 135), 16, MINT)
    _label("ECOS: %d  +%d/s   ENERGIA: %d" % [int(income), int(income_rate) if sleeping else 0, int(sparks)], Vector2(338, 135), 17, GOLD)
    draw_rect(Rect2(22, 145, 914, 8), Color("#33434a"))
    draw_rect(Rect2(22, 145, 914 * progress, 8), BLUE)
    # Cámara protegida, cama y umbral.
    # Cámara: suelo de piedra oscuro con muro, para que el templo de fondo no
    # compita con los elementos de juego.
    draw_rect(Rect2(44, 175, 673, 296), Color(0.055, 0.085, 0.10, 0.88))
    for row in range(6):
        draw_line(Vector2(48, 175 + row * 50), Vector2(713, 175 + row * 50), Color(1, 1, 1, 0.025), 1.0)
    draw_rect(Rect2(44, 175, 673, 296), Color("#5f5d50"), false, 4)
    draw_rect(Rect2(48, 179, 665, 3), Color("#8c876f"))
    _draw_bed(Rect2(130, 269, 184, 147))
    # Defensas aparecen en espacios edificables y atacan automaticamente.
    for slot in range(4):
        var p := Vector2(425 + (slot % 2) * 120, 255 + (slot / 2) * 160)
        draw_rect(Rect2(p - Vector2(33, 33), Vector2(66, 66)), Color("#223540"))
        draw_rect(Rect2(p - Vector2(33, 33), Vector2(66, 66)), GOLD if slot < wards else Color("#597078"), false, 2)
        if slot < wards:
            _draw_sentinel(p)
        else:
            _label("+", p + Vector2(-12, 13), 32, MINT)
    # Puerta, barra de vida y entidad antagonista.
    _draw_gate(Rect2(710, 269, 33, 182))
    draw_rect(Rect2(662, 254, 130, 9), Color("#60383c"))
    draw_rect(Rect2(662, 254, 130 * clampf(gate_hp / gate_max, 0.0, 1.0), 9), BLUE)
    _label("PUERTA NIV %d" % gate_level, Vector2(662, 245), 13, MINT)
    if shield_left > 0.0:
        draw_rect(Rect2(702, 266, 51, 195), Color(0.17, 0.85, 0.91, 0.21))
        _label("ESCUDO %d" % int(ceilf(shield_left)), Vector2(643, 286), 12, BLUE)
    if hunter_respawn <= 0.0:
        var hpos := Vector2(hunter_x, 365.0 + sin(tick * 2.0) * 7.0)
        var monster: Texture2D = HUNTER
        if hunter_kind == "angel":
            monster = ALT_HUNTER
        elif hunter_kind == "wizard":
            monster = WIZARD
        var frame: Array = MONSTER_FRAMES[hunter_kind]
        var scale: float = frame[3]
        var feet := Vector2(roundf(hpos.x), roundf(hpos.y + 12.0))
        for i in range(3):
            var k: float = 1.0 - float(i) * 0.28
            draw_set_transform(Vector2(hunter_x, 380.0), 0.0, Vector2(1.0, 0.32))
            draw_circle(Vector2.ZERO, 20.0 * k, Color(0, 0, 0, 0.14))
        # Avanza hacia la izquierda: el ghoul de perfil mira a la derecha y se voltea.
        var flip: float = -1.0 if hunter_kind == "ghoul" else 1.0
        draw_set_transform(feet, 0.0, Vector2(flip, 1.0))
        var anchor := Vector2((frame[0] + frame[1]) * 0.5 * scale, frame[2] * scale)
        draw_texture_rect(monster, Rect2(-anchor, Vector2(monster.get_width(), monster.get_height()) * scale), false)
        draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
        # Barra de vida sobre la cabeza, siempre dentro de la pantalla.
        var bar_top: float = feet.y - frame[2] * scale - 12.0
        var bar_x: float = clampf(hpos.x - 30.0, 8.0, W - 68.0)
        draw_rect(Rect2(bar_x - 1, bar_top - 1, 62, 7), Color(0, 0, 0, 0.6))
        draw_rect(Rect2(bar_x, bar_top, 60, 5), Color("#493137"))
        draw_rect(Rect2(bar_x, bar_top, 60 * clampf(hunter_hp / hunter_max, 0, 1), 5), CRIMSON)
        if wards > 0 and hunter_x < 938:
            for n in range(wards):
                var source := Vector2(425 + (n % 2) * 120, 255 + (n / 2) * 160)
                draw_line(source, hpos, Color(0.56, 0.85, 0.93, 0.25 + 0.14 * sin(tick * 10.0)), 2)
    _label("REPELIDAS: %d  |  PUNTOS: %d" % [slain, slain * 50 + int(elapsed) * 3], Vector2(24, 480), 12, BLUE)
    if info_time > 0.0:
        _label(info, Vector2(294, 480), 12, GOLD)
    var tech_names := ["GENERADOR", "POTENCIAR", "ESCUDO", "REANUDAR" if paused else "PAUSA"]
    var tech_costs := ["%d ecos" % int(35.0 + generator_level * 25.0), "%d energia" % (6 * ward_power), "14 energia", "P"]
    for i in range(4):
        _button(Rect2(12 + i * 238.0, 490, 226, 60), tech_names[i], tech_costs[i])
    var costs := ["ESPACIO", "%d ecos" % (18 * bed_level), "%d ecos" % (25 * gate_level), "%d ecos" % (22 + 20 * wards), "18 ecos"]
    var names := ["DESCANSAR" if not sleeping else "LEVANTAR", "LECHO", "PUERTA", "CENTINELA", "REPARAR"]
    for idx in range(5):
        _button(Rect2(12 + idx * 191, 558, 181, 69), names[idx], costs[idx])

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
    if sleeping:
        draw_rect(area, Color(BLUE.r, BLUE.g, BLUE.b, 0.06))
    draw_rect(area, GOLD if sleeping else Color("#7a6b4f"), false, 2)
    _label("LECHO NIV %d" % bed_level, Vector2(area.position.x + 18, area.end.y - 14), 15, MINT)
    _label("DURMIENDO" if sleeping else "TOCA PARA DESCANSAR", Vector2(area.position.x + 4, area.end.y + 22), 13, BLUE)


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


func _button(rect: Rect2, heading: String, detail: String) -> void:
    draw_rect(rect, Color("#172e39"))
    draw_rect(rect, GOLD, false, 2)
    _text_centered(heading, Rect2(rect.position.x, rect.position.y + 4, rect.size.x, 31), 15, MINT)
    if not detail.is_empty():
        _text_centered(detail, Rect2(rect.position.x, rect.position.y + 36, rect.size.x, 26), 12, GOLD)

func _label(text_value: String, at: Vector2, size: int = 16, color: Color = MINT) -> void:
    draw_string(font, at, text_value, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, color)

func _center(text_value: String, y: float, size: int = 16, color: Color = MINT) -> void:
    draw_string(font, Vector2(40, y), text_value, HORIZONTAL_ALIGNMENT_CENTER, 880.0, size, color)

func _text_centered(text_value: String, rect: Rect2, size: int, color: Color) -> void:
    draw_string(font, Vector2(rect.position.x, rect.position.y + size + 4), text_value, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, size, color)
