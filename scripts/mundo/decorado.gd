extends Node
## Decorado de la sala que no se mueve ni pelea: relieve de los muros, grietas
## del desgaste, restos del suelo, sombras y luz de los objetos de la escena,
## motas de polvo, puertas (entrada, pasos laterales y salida), la placa de
## la inscripción, la penumbra con sus luces, los rayos de luz y la niebla.
## La campaña decide qué hay y en qué estado está; aquí solo se dibuja, sobre
## el lienzo del mundo («c»), en el turno que le toca.

const Lienzo := preload("res://scripts/comun/lienzo.gd")

## Profundidad cenital: cara del muro del fondo, muros laterales y frontal.
const MURO_FONDO := Rect2(40, 122, 880, 36)
const MURO_IZQ_X := 67.0
const MURO_DER_X := 893.0
const MURO_FRENTE_Y := 552.0
const NIEBLA := preload("res://assets/visual/fx/niebla.png")

## Restos de mazmorra (herramientas/generar_decorados.py): sin colisión, en
## espejo respecto al eje x = 480 y siempre igual en la misma sala.
const RESTOS := {
    "craneo": preload("res://assets/visual/decorados/craneo.png"),
    "huesos": preload("res://assets/visual/decorados/huesos.png"),
    "costillar": preload("res://assets/visual/decorados/costillar.png"),
    "vasija_rota": preload("res://assets/visual/decorados/vasija_rota.png"),
    "velas": preload("res://assets/visual/decorados/velas.png"),
    "charco_grande": preload("res://assets/visual/decorados/charco_grande.png"),
    "charco_pequeno": preload("res://assets/visual/decorados/charco_pequeno.png"),
    "reguero": preload("res://assets/visual/decorados/reguero.png"),
    "estandarte": preload("res://assets/visual/decorados/estandarte.png"),
    "cadena": preload("res://assets/visual/decorados/cadena.png"),
    "telarana": preload("res://assets/visual/decorados/telarana.png"),
    "manos": preload("res://assets/visual/decorados/manos.png"),
    "goteo": preload("res://assets/visual/decorados/goteo.png"),
}
const RESTOS_SUELO := ["craneo", "huesos", "costillar", "vasija_rota", "velas", "charco_pequeno", "charco_grande", "reguero"]

static func degradado_v(c: CanvasItem, r: Rect2, arriba: Color, abajo: Color) -> void:
    c.draw_polygon(PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]),
        PackedColorArray([arriba, arriba, abajo, abajo]))


static func degradado_h(c: CanvasItem, r: Rect2, izq: Color, der: Color) -> void:
    c.draw_polygon(PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]),
        PackedColorArray([izq, der, der, izq]))


## La luz cae desde arriba: el muro del fondo muestra su cara (más oscura
## abajo) y proyecta sombra; los laterales y el frontal, su remate iluminado.
func muros(c: CanvasItem) -> void:
    var shade := Color(0.01, 0.015, 0.03)
    var floor_l: float = MURO_IZQ_X
    var floor_r: float = MURO_DER_X
    degradado_v(c, Rect2(floor_l - 19.0, MURO_FONDO.position.y, floor_r - floor_l + 38.0, MURO_FONDO.size.y), Color(1.0, 0.95, 0.82, 0.07), Color(shade, 0.34))
    c.draw_rect(Rect2(floor_l - 19.0, MURO_FONDO.position.y, floor_r - floor_l + 38.0, 2.0), Color(0.85, 0.86, 0.74, 0.22))
    degradado_v(c, Rect2(floor_l, MURO_FONDO.end.y, floor_r - floor_l, 30.0), Color(shade, 0.42), Color(shade, 0.0))
    for side in [-1.0, 1.0]:
        var edge: float = floor_l if side < 0.0 else floor_r
        var x0: float = edge if side < 0.0 else edge - 16.0
        degradado_h(c, Rect2(x0, MURO_FONDO.end.y, 16.0, MURO_FRENTE_Y - MURO_FONDO.end.y), Color(shade, 0.26 if side < 0.0 else 0.0), Color(shade, 0.0 if side < 0.0 else 0.26))
        c.draw_rect(Rect2(edge - (2.0 if side < 0.0 else 0.0), MURO_FONDO.position.y, 2.0, MURO_FRENTE_Y - MURO_FONDO.position.y + 23.0), Color(0.80, 0.82, 0.70, 0.16))
    degradado_v(c, Rect2(floor_l, MURO_FRENTE_Y - 12.0, floor_r - floor_l, 12.0), Color(shade, 0.0), Color(shade, 0.18))
    c.draw_rect(Rect2(floor_l - 19.0, MURO_FRENTE_Y, floor_r - floor_l + 38.0, 2.0), Color(0.82, 0.84, 0.72, 0.24))
    c.draw_rect(Rect2(floor_l - 19.0, MURO_FRENTE_Y + 2.0, floor_r - floor_l + 38.0, 21.0), Color(shade, 0.22))


## Grietas, grietas del muro y cascotes según el desgaste del piso (siempre
## iguales en la misma sala: «semilla»).
func desgaste(c: CanvasItem, wear: float, semilla: int) -> void:
    if wear <= 0.0:
        return
    var rng := RandomNumberGenerator.new()
    rng.seed = semilla
    var dark := Color(0.03, 0.04, 0.04, 0.55)
    var lit := Color(0.55, 0.60, 0.50, 0.18)
    for n in range(int(7.0 * wear)):
        var p := Vector2(rng.randf_range(90.0, 870.0), rng.randf_range(180.0, 540.0))
        var ang: float = rng.randf_range(0.0, TAU)
        var pts := PackedVector2Array([p])
        for k in range(rng.randi_range(3, 6)):
            ang += rng.randf_range(-0.7, 0.7)
            p += Vector2.from_angle(ang) * rng.randf_range(8.0, 18.0)
            pts.append(p)
            if rng.randf() < 0.35: # ramificación
                c.draw_line(p, p + Vector2.from_angle(ang + 1.2) * 9.0, dark, 1.0)
        c.draw_polyline(pts, dark, 1.5)
        var edge := PackedVector2Array()
        for q in pts:
            edge.append(q + Vector2(1.0, -1.0)) # filo iluminado desde arriba
        c.draw_polyline(edge, lit, 1.0)
    for n in range(int(4.0 * wear)):
        var x: float = rng.randf_range(100.0, 860.0)
        c.draw_polyline(PackedVector2Array([Vector2(x, 124.0), Vector2(x + rng.randf_range(-6, 6), 136.0), Vector2(x + rng.randf_range(-8, 8), 150.0)]), dark, 1.5)
    for n in range(int(10.0 * wear)):
        var q := Vector2(rng.randf_range(80.0, 880.0), rng.randf_range(165.0, 545.0))
        c.draw_rect(Rect2(q, Vector2(rng.randi_range(2, 4), rng.randi_range(2, 3))), Color(0.42, 0.45, 0.38, 0.6))


## Dónde van los restos de la sala «clave» ([clave, posición arriba-izquierda,
## espejo]; la campaña lo guarda por sala). «despejar»: puntos que no se
## tapan; «bloqueado»: Callable(Vector2) -> bool.
func restos(clave: String, wear: float, despejar: Array, bloqueado: Callable) -> Array:
    var _restos: Array = []
    var rng := RandomNumberGenerator.new()
    rng.seed = hash("decor:" + clave)
    # Muro del fondo: estandartes y cadenas en parejas; sangre según el piso.
    for x in [150.0, 262.0, 372.0]:
        var roll: float = rng.randf()
        var key: String = "estandarte" if roll < 0.4 else ("cadena" if roll < 0.7 else ("manos" if roll < 0.7 + 0.15 * (1.0 + wear) else "goteo"))
        var tex: Texture2D = RESTOS[key]
        var y: float = 121.0 if key in ["estandarte", "cadena"] else 126.0
        _restos.append([key, Vector2(x - tex.get_width() * 0.5, y), false])
        _restos.append([key, Vector2(960.0 - x - tex.get_width() * 0.5, y), true])
    # Telarañas en las esquinas del fondo.
    _restos.append(["telarana", Vector2(68, 158), false])
    _restos.append(["telarana", Vector2(893 - 26, 158), true])
    # Suelo: restos en la mitad izquierda y su reflejo.
    var count: int = 6 + int(3.0 * wear)
    var tries: int = 0
    var placed: int = 0
    while placed < count and tries < 80:
        tries += 1
        var key2: String = RESTOS_SUELO[rng.randi() % RESTOS_SUELO.size()]
        if key2 in ["charco_grande", "reguero"] and rng.randf() > 0.5 + 0.4 * wear:
            continue
        var tex2: Texture2D = RESTOS[key2]
        var size := Vector2(tex2.get_width(), tex2.get_height())
        var center := Vector2(rng.randf_range(90.0, 450.0), rng.randf_range(185.0, 535.0))
        var ok: bool = true
        for q in despejar:
            if Vector2(q).distance_to(center) < 48.0 or Vector2(960.0 - q.x, q.y).distance_to(center) < 48.0:
                ok = false
                break
        if ok and (bloqueado.call(center) or bloqueado.call(Vector2(960.0 - center.x, center.y))):
            ok = false
        for d in _restos:
            if Vector2(d[1]).distance_to(center - size * 0.5) < 40.0:
                ok = false
        if not ok:
            continue
        var top_left := (center - size * 0.5).round()
        _restos.append([key2, top_left, false])
        _restos.append([key2, Vector2(960.0 - top_left.x - size.x, top_left.y), true])
        placed += 1
    return _restos


## Dibuja los restos ya colocados; las velas encendidas titilan.
func dibujar_restos(c: CanvasItem, lista: Array, t: float) -> void:
    for d in lista:
        var tex: Texture2D = RESTOS[d[0]]
        textura_espejo(c, tex, Rect2(d[1], Vector2(tex.get_width(), tex.get_height())), d[2])
    for d in lista:
        if d[0] == "velas":
            var centro: Vector2 = Vector2(d[1]) + Vector2(11, 6)
            c.draw_circle(centro, 14.0, Color(1.0, 0.7, 0.3, 0.05 + 0.03 * sin(t * 9.0 + centro.x)))


static func textura_espejo(c: CanvasItem, tex: Texture2D, dest: Rect2, espejo: bool) -> void:
    if not espejo:
        c.draw_texture_rect(tex, dest, false)
        return
    Lienzo.xf(c, Vector2(dest.position.x + dest.size.x, dest.position.y), 0.0, Vector2(-1.0, 1.0))
    c.draw_texture_rect(tex, Rect2(Vector2.ZERO, dest.size), false)
    Lienzo.xf(c, Vector2.ZERO, 0.0, Vector2.ONE)


## Sombras de contacto y halo de los objetos de la escena de la sala
## (props: {rect, base, shadow, light}).
func sombras_objetos(c: CanvasItem, props: Array, t: float) -> void:
    for prop in props:
        var rect: Rect2 = prop["rect"]
        if prop["shadow"]:
            Lienzo.sombra(c, Vector2(rect.get_center().x, float(prop["base"]) - 3.0), rect.size.x * 0.6, 1.1)
        if prop["light"]:
            var flicker: float = 0.5 + 0.5 * sin(t * 7.0 + rect.position.x) * sin(t * 2.3)
            var centro := Vector2(rect.get_center().x, rect.position.y + rect.size.y * 0.35)
            for r in range(4, 0, -1):
                c.draw_circle(centro, 10.0 + float(r) * 7.0, Color(1.0, 0.78, 0.40, 0.03 + 0.012 * flicker))


## Polvo y ceniza suspendidos (más brasas carmesí cuanto más gastado el piso).
## motas: {p, s, f, ph}.
func motas(c: CanvasItem, lista: Array, wear: float, t: float) -> void:
    for m in lista:
        var p: Vector2 = m["p"]
        var tw: float = 0.5 + 0.5 * sin(t * float(m["f"]) + float(m["ph"]))
        var ember: bool = float(m["ph"]) < wear * 0.9
        var col: Color = Color(0.95, 0.35, 0.22, 0.10 + 0.22 * tw) if ember else Color(0.86, 0.8, 0.66, 0.06 + 0.12 * tw)
        c.draw_rect(Rect2(p.round(), Vector2(float(m["s"]), float(m["s"]))), col)


## Hueco de una puerta lateral (-1 izquierda, 1 derecha) a la altura «y».
static func hueco_lateral(lado: int, y: float) -> Rect2:
    var x: float = 46.0 if lado < 0 else 960.0 - 46.0 - 19.0
    return Rect2(x, y - 36.0, 19.0, 72.0)


static func jambas(c: CanvasItem, gap: Rect2) -> void:
    for y in [gap.position.y - 9.0, gap.end.y]:
        c.draw_rect(Rect2(gap.position.x - 6.0, y, 31.0, 9.0), Color("#454c3c"))
        c.draw_rect(Rect2(gap.position.x - 6.0, y, 31.0, 2.0), Color("#68715a"))
        c.draw_rect(Rect2(gap.position.x - 6.0, y, 31.0, 9.0), Color("#15170f"), false, 1.0)


## Entrada cerrada a tu espalda (a la altura «entrada_y») y los dos pasos
## laterales con su rastrillo («abierto»: lado → 0..1, cuánto ha subido).
func puertas_laterales(c: CanvasItem, entrada_y: float, laterales_y: float, abierto: Dictionary) -> void:
    var entry: Rect2 = hueco_lateral(-1, entrada_y)
    c.draw_rect(entry, Color("#2a2119"))
    for k in range(3):
        c.draw_rect(Rect2(entry.position.x + 2.0 + float(k) * 6.0, entry.position.y + 2.0, 4.0, entry.size.y - 4.0), Color("#3b2e22"))
    c.draw_rect(Rect2(entry.position.x + 3.0, entry.get_center().y - 2.0, entry.size.x - 6.0, 4.0), Color("#5c5446"))
    jambas(c, entry)
    for side in [-1, 1]:
        var gap: Rect2 = hueco_lateral(side, laterales_y)
        var open_k: float = float(abierto[side])
        c.draw_rect(gap, Color("#07090b"))
        if open_k > 0.0:
            var tone := Color(0.89, 0.74, 0.48)
            var dir: float = 1.0 if side < 0 else -1.0
            var mouth: float = gap.end.x if side < 0 else gap.position.x
            c.draw_polygon(PackedVector2Array([Vector2(mouth, gap.position.y), Vector2(mouth, gap.end.y), Vector2(mouth + dir * 70.0, gap.end.y + 16.0), Vector2(mouth + dir * 70.0, gap.position.y - 16.0)]),
                PackedColorArray([Color(tone, 0.18 * open_k), Color(tone, 0.18 * open_k), Color(tone, 0.0), Color(tone, 0.0)]))
        var lift: float = gap.size.y * open_k
        for k in range(4):
            var bx: float = gap.position.x + 2.0 + float(k) * 5.0
            c.draw_rect(Rect2(bx, gap.position.y, 2.0, gap.size.y - lift), Color("#4a4f55"))
        for k in range(3):
            var by: float = gap.position.y + 12.0 + float(k) * 20.0
            if by < gap.end.y - lift:
                c.draw_rect(Rect2(gap.position.x, by, gap.size.x, 2.0), Color("#5d636a"))
        jambas(c, gap)


## Puerta de salida: abierta (luz en el umbral) o sellada (cerrojos que
## laten). Devuelve el hueco, para poner encima su rótulo.
func salida(c: CanvasItem, en: Vector2, abierta: bool, t: float) -> Rect2:
    var tone: Color = Color("#82bdaf") if abierta else Color("#b04d5e")
    var gap := Rect2(en.x + 28.0, en.y - 36.0, 19.0, 72.0)
    var pulse: float = 0.5 + 0.5 * sin(t * 2.2)
    Lienzo.elipse(c, Vector2(gap.position.x - 30.0, en.y), 34.0, 40.0, Color(tone.r, tone.g, tone.b, 0.05 + 0.03 * pulse))
    if abierta:
        c.draw_rect(gap, Color("#05080a"))
        c.draw_polygon(PackedVector2Array([gap.position, gap.position + Vector2(0, gap.size.y), Vector2(gap.position.x - 60.0, gap.end.y + 18.0), Vector2(gap.position.x - 60.0, gap.position.y - 18.0)]),
            PackedColorArray([Color(tone.r, tone.g, tone.b, 0.22), Color(tone.r, tone.g, tone.b, 0.22), Color(tone.r, tone.g, tone.b, 0.0), Color(tone.r, tone.g, tone.b, 0.0)]))
        c.draw_rect(Rect2(gap.position.x + 4.0, gap.position.y + 4.0, 3.0, gap.size.y - 8.0), Color(tone.r, tone.g, tone.b, 0.35 + 0.2 * pulse))
    else:
        c.draw_rect(gap, Color("#2b3027"))
        c.draw_rect(Rect2(gap.position, Vector2(3.0, gap.size.y)), Color("#3d4436"))
        for i in range(4):
            var y: float = gap.position.y + 11.0 + float(i) * 16.0
            c.draw_line(Vector2(gap.position.x + 5.0, y), Vector2(gap.position.x + 14.0, y + 5.0), Color(tone.r, tone.g, tone.b, 0.55 + 0.35 * pulse), 2.0)
    jambas(c, gap)
    return gap


## Placa de la inscripción; brilla si el jugador está cerca.
func placa(c: CanvasItem, en: Vector2, cerca: bool, t: float) -> void:
    var plaque := Rect2(en - Vector2(26, 10), Vector2(52, 20))
    c.draw_rect(plaque.grow(2.0), Color(0, 0, 0, 0.5))
    c.draw_rect(plaque, Color("#5a5446"))
    c.draw_rect(Rect2(plaque.position, Vector2(plaque.size.x, 2)), Color("#8a8370"))
    for i in range(5):
        c.draw_rect(Rect2(plaque.position + Vector2(6.0 + i * 9.0, 8.0 + float(i % 2) * 3.0), Vector2(6, 2)), Color("#2a261f"))
    if cerca:
        c.draw_rect(plaque.grow(3.0), Color(0.78, 0.67, 0.43, 0.35 + 0.2 * sin(t * 4.0)), false, 1.0)


## Penumbra con luces: rejilla de vértices con oscuridad interpolada.
## luces: [[posición, radio, fuerza], …]; nunca llega al negro.
func penumbra(c: CanvasItem, area: Rect2, luces: Array, antorcha: bool, jugador: Vector2, miedo: float, celda: float) -> void:
    if antorcha:
        for r in range(4, 0, -1):
            c.draw_circle(jugador + Vector2(0, -20), float(r) * 34.0, Color(1.0, 0.78, 0.45, 0.018))
    var base_dark: float = 0.40 if antorcha else 0.60
    var fear_edge: float = miedo / 100.0 * 0.28
    var cols: int = int(ceil(area.size.x / celda)) + 1
    var rows: int = int(ceil(area.size.y / celda)) + 1
    var center: Vector2 = area.get_center()
    var alpha: PackedFloat32Array = PackedFloat32Array()
    alpha.resize(cols * rows)
    for r in range(rows):
        for col in range(cols):
            var p := area.position + Vector2(col, r) * celda
            var lit: float = 0.0
            for light in luces:
                var d: float = p.distance_to(light[0])
                if d < light[1]:
                    lit = maxf(lit, pow(1.0 - d / light[1], 1.4) * light[2])
            var edge: float = clampf((p - center).length() / (area.size.x * 0.55) - 0.35, 0.0, 1.0)
            alpha[r * cols + col] = clampf(base_dark * (1.0 - lit) + fear_edge * edge, 0.0, 0.85)
    var tint := Color(0.035, 0.02, 0.07)
    for r in range(rows - 1):
        for col in range(cols - 1):
            var a0: float = alpha[r * cols + col]
            var a1: float = alpha[r * cols + col + 1]
            var a2: float = alpha[(r + 1) * cols + col + 1]
            var a3: float = alpha[(r + 1) * cols + col]
            if a0 + a1 + a2 + a3 < 0.01:
                continue
            var p := area.position + Vector2(col, r) * celda
            c.draw_polygon(
                PackedVector2Array([p, p + Vector2(celda, 0), p + Vector2(celda, celda), p + Vector2(0, celda)]),
                PackedColorArray([Color(tint, a0), Color(tint, a1), Color(tint, a2), Color(tint, a3)]))


## Tres haces de luz desde arriba, con polvo que brilla al cruzarlos.
func rayos(c: CanvasItem, area: Rect2, wear: float, t: float) -> void:
    var base: float = 0.09 * (1.0 - wear * 0.3)
    for i in range(3):
        var x: float = 250.0 + float(i) * 230.0
        var breath: float = 0.75 + 0.25 * sin(t * 0.35 + float(i) * 1.7)
        var a: float = base * breath
        var top_l := Vector2(x, area.position.y + 4.0)
        var top_r := Vector2(x + 34.0, area.position.y + 4.0)
        var bot_r := Vector2(x + 210.0, area.end.y - 30.0)
        var bot_l := Vector2(x + 70.0, area.end.y - 30.0)
        c.draw_polygon(PackedVector2Array([top_l, top_r, bot_r, bot_l]),
            PackedColorArray([Color(1.0, 0.9, 0.7, a), Color(1.0, 0.9, 0.7, a), Color(1.0, 0.9, 0.7, 0.0), Color(1.0, 0.9, 0.7, 0.0)]))
        for d in range(7):
            var k: float = fmod(t * 0.05 + float(d) * 0.143 + float(i) * 0.31, 1.0)
            var across: float = 0.5 + 0.4 * sin(t * 0.6 + float(d) * 2.1)
            var pos: Vector2 = top_l.lerp(bot_l, k).lerp(top_r.lerp(bot_r, k), across)
            c.draw_rect(Rect2(pos.round(), Vector2(1, 1)), Color(1.0, 0.92, 0.75, 0.55 * (1.0 - k) * breath))


## Niebla baja que se desliza (dos capas a distinta velocidad), recortada a
## la sala.
func niebla(c: CanvasItem, area: Rect2, t: float) -> void:
    var tint := Color(0.62, 0.55, 0.75)
    for layer in range(2):
        var speed: float = 9.0 if layer == 0 else -5.5
        var y: float = area.end.y - 150.0 - float(layer) * 70.0
        var alpha: float = 0.2 if layer == 0 else 0.13
        var off: float = fmod(t * speed, 256.0)
        if off > 0.0:
            off -= 256.0
        var x: float = area.position.x + off
        while x < area.end.x:
            var x0: float = maxf(x, area.position.x)
            var x1: float = minf(x + 256.0, area.end.x)
            if x1 > x0:
                var src := Rect2(x0 - x, 0, x1 - x0, 128)
                c.draw_texture_rect_region(NIEBLA, Rect2(x0, y, x1 - x0, 150), src, Color(tint.r, tint.g, tint.b, alpha))
            x += 256.0


## Cadáver (textura de restos) en «en»; la mitad, en espejo para variar.
func cadaver(c: CanvasItem, tex: Texture2D, en: Vector2, espejo: bool) -> void:
    var size := Vector2(tex.get_width(), tex.get_height())
    var dest := Rect2(roundf(en.x - size.x * 0.5), roundf(en.y + 4.0 - size.y * 0.5), size.x, size.y)
    textura_espejo(c, tex, dest, espejo)


## Tu propio cuerpo tendido sobre un charco de sangre (hoja del héroe,
## girada); mientras no recuperes lo que llevabas, un alma late encima.
func cuerpo_propio(c: CanvasItem, en: Vector2, hoja: Texture2D, recuperado: bool, t: float) -> void:
    Lienzo.elipse(c, en + Vector2(4, 2), 30.0, 10.0, Color(0.32, 0.02, 0.05, 0.85))
    Lienzo.elipse(c, en + Vector2(-6, 4), 18.0, 6.0, Color(0.45, 0.03, 0.07, 0.8))
    Lienzo.xf(c, en + Vector2(-4, -2), PI * 0.5, Vector2.ONE)
    c.draw_texture_rect_region(hoja, Rect2(-28, -20, 40, 56), Rect2(0, 0, 40, 56), Color(0.55, 0.5, 0.55, 1.0))
    Lienzo.xf(c, Vector2.ZERO, 0.0, Vector2.ONE)
    if not recuperado:
        var pulse: float = 0.5 + 0.5 * sin(t * 3.0)
        c.draw_circle(en + Vector2(0, -6), 5.0 + pulse * 2.0, Color(0.56, 0.86, 0.95, 0.25 + 0.25 * pulse))


## Marca de una muerte anterior: halo en el suelo y tu silueta translúcida
## (sin hoja, solo el halo). «i» desfasa el latido entre marcas.
func marca_muerte(c: CanvasItem, en: Vector2, i: int, hoja: Texture2D, t: float) -> void:
    var pulse: float = 0.5 + 0.5 * sin(t * 2.0 + float(i))
    Lienzo.elipse(c, en + Vector2(0, 2), 20.0, 7.0, Color(0.56, 0.86, 0.95, 0.10 + 0.08 * pulse))
    if hoja != null:
        c.draw_texture_rect_region(hoja, Rect2(en.x - 20.0, en.y + 4.0 - 54.0, 40.0, 56.0), Rect2(0, 0, 40, 56),
            Color(0.7, 0.95, 1.0, 0.38 + 0.15 * pulse))
