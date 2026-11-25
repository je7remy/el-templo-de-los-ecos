extends Node
## Objetos de la sala que se dibujan en el orden por profundidad (lo de abajo
## tapa a lo de arriba): columnas, braseros, cofre, fuente, altar, carta y
## muros del laberinto. La campaña decide qué hay y en qué estado está; aquí
## solo se dibujan, sobre el lienzo del mundo («c») y en su turno.

const Lienzo := preload("res://scripts/comun/lienzo.gd")
const PILLAR_REACH := 160.0 # distancia del Coloso a la columna para que le caiga encima


## Columna agrietada (sala del Coloso); caída, sus tambores en línea. Cerca
## del Coloso brilla para indicar que se puede derribar.
func pilar(c: CanvasItem, p: Dictionary, t: float, coloso_activo: bool, coloso_en: Vector2) -> void:
    var at: Vector2 = p["pos"]
    if bool(p["fallen"]):
        # Columna caída: tambores de piedra en línea hacia donde estaba el Coloso.
        var dir: Vector2 = p["fall_dir"]
        var k: float = float(p["fall_t"])
        for n in range(5):
            var centro: Vector2 = at + dir * (14.0 + float(n) * 22.0) * k
            c.draw_rect(Rect2(centro - Vector2(12, 8), Vector2(24, 16)), Color("#6a665e"))
            c.draw_rect(Rect2(centro - Vector2(12, 8), Vector2(24, 3)), Color("#8a857b"))
        return
    Lienzo.sombra(c, at + Vector2(0, 2), 16.0)
    var body := Rect2(at.x - 12.0, at.y - 92.0, 24, 92)
    c.draw_rect(body, Color("#7d7a72"))
    c.draw_rect(Rect2(body.position, Vector2(5, body.size.y)), Color("#a8a49a"))
    c.draw_rect(Rect2(at.x - 16.0, at.y - 98.0, 32, 8), Color("#8a857b"))
    c.draw_rect(Rect2(at.x - 16.0, at.y - 8.0, 32, 8), Color("#5f5b54"))
    # Grieta que brilla: aquí se golpea.
    var glow: float = 0.5 + 0.5 * sin(t * 3.0 + at.x)
    c.draw_polyline(PackedVector2Array([Vector2(at.x - 4, at.y - 70), Vector2(at.x + 4, at.y - 54), Vector2(at.x - 2, at.y - 36), Vector2(at.x + 3, at.y - 22)]), Color(1.0, 0.75, 0.35, 0.5 + 0.5 * glow), 2.0)
    if coloso_activo and coloso_en.distance_to(at) < PILLAR_REACH:
        c.draw_rect(body.grow(3.0), Color(1.0, 0.8, 0.4, 0.5 + 0.3 * glow), false, 2.0)


## Brasero de la sala del Hermano Mayor (encendido o apagado).
func brasero(c: CanvasItem, b: Dictionary, t: float) -> void:
    var at: Vector2 = b["pos"]
    Lienzo.sombra(c, at + Vector2(0, 2), 18.0)
    c.draw_rect(Rect2(at.x - 6.0, at.y - 26.0, 12, 26), Color("#4a4352"))
    c.draw_colored_polygon(PackedVector2Array([at + Vector2(-22, -34), at + Vector2(22, -34), at + Vector2(14, -22), at + Vector2(-14, -22)]), Color("#6a5030"))
    c.draw_rect(Rect2(at.x - 22.0, at.y - 36.0, 44, 3), Color("#c9a25e"))
    if bool(b["lit"]):
        var f: float = 0.5 + 0.5 * sin(t * 9.0 + at.x)
        for k in range(4, 0, -1):
            c.draw_circle(at + Vector2(0, -44), 10.0 + float(k) * 12.0, Color(1.0, 0.6, 0.25, 0.04))
        c.draw_colored_polygon(PackedVector2Array([at + Vector2(-14, -36), at + Vector2(14, -36), at + Vector2(4, -62 - 6.0 * f), at + Vector2(-2, -54)]), Color("#f08a3a"))
        c.draw_colored_polygon(PackedVector2Array([at + Vector2(-7, -36), at + Vector2(7, -36), at + Vector2(1, -52 - 4.0 * f)]), Color("#ffd36b"))
    else:
        c.draw_rect(Rect2(at.x - 12.0, at.y - 38.0, 24, 4), Color("#2a2420"))


## Cofre de la sala (abierto o cerrado).
func cofre(c: CanvasItem, at: Vector2, opened: bool, t: float) -> void:
    Lienzo.sombra(c, at + Vector2(0, 2), 22.0)
    var body := Rect2(at.x - 20.0, at.y - 22.0, 40, 22)
    c.draw_rect(body, Color("#5a3b22"))
    c.draw_rect(Rect2(body.position.x, body.position.y + 8.0, body.size.x, 3), Color("#3a2414"))
    c.draw_rect(Rect2(at.x - 3.0, body.position.y, 6, body.size.y), Color("#b8955a"))
    c.draw_rect(body, Color("#1b120a"), false, 1.0)
    if opened:
        # Tapa abierta, hacia atrás.
        c.draw_colored_polygon(PackedVector2Array([Vector2(body.position.x, body.position.y), Vector2(body.end.x, body.position.y), Vector2(body.end.x - 3.0, body.position.y - 14.0), Vector2(body.position.x + 3.0, body.position.y - 14.0)]), Color("#4a2f1a"))
        c.draw_rect(Rect2(body.position.x + 3.0, body.position.y - 2.0, body.size.x - 6.0, 3), Color("#140c06"))
    else:
        c.draw_rect(Rect2(body.position.x - 1.0, body.position.y - 8.0, body.size.x + 2.0, 9), Color("#6b4528"))
        c.draw_rect(Rect2(at.x - 3.0, body.position.y - 8.0, 6, 9), Color("#c9a25e"))
        c.draw_rect(Rect2(at.x - 2.0, body.position.y - 1.0, 4, 4), Color("#2a2420"))
        var g: float = 0.5 + 0.5 * sin(t * 3.0 + at.x)
        c.draw_circle(Vector2(at.x + 12.0, body.position.y - 6.0), 1.5 + g, Color(1.0, 0.9, 0.6, 0.35 + 0.4 * g))


## Fuente de latón (ya usada o no).
func fuente(c: CanvasItem, p: Vector2, used: bool, t: float) -> void:
    Lienzo.sombra(c, p + Vector2(0, 2), 18.0)
    # Base de piedra y cuerpo de latón con engranajes.
    c.draw_rect(Rect2(p.x - 16.0, p.y - 10.0, 32, 10), Color("#3a363c"))
    c.draw_rect(Rect2(p.x - 12.0, p.y - 34.0, 24, 24), Color("#8a6a3a"))
    c.draw_rect(Rect2(p.x - 12.0, p.y - 34.0, 24, 3), Color("#c9a25e"))
    var spin: float = 0.0 if used else t * 2.0
    for side in [-1.0, 1.0]:
        var g: Vector2 = p + Vector2(side * 14.0, -22.0)
        c.draw_circle(g, 5.0, Color("#6a5030"))
        c.draw_line(g + Vector2.from_angle(spin) * 5.0, g - Vector2.from_angle(spin) * 5.0, Color("#c9a25e"), 1.0)
    # Vial con sangre que late; vacío si ya lo usaste.
    var vial := Rect2(p.x - 6.0, p.y - 54.0, 12, 20)
    c.draw_rect(vial, Color(0.6, 0.7, 0.75, 0.35))
    if not used:
        var pulse: float = 0.5 + 0.5 * sin(t * 3.0)
        c.draw_rect(Rect2(vial.position + Vector2(2, 6), Vector2(8, 13)), Color(0.75, 0.08, 0.14).lerp(Color(0.95, 0.2, 0.25), pulse))
        c.draw_circle(vial.get_center(), 14.0, Color(0.9, 0.15, 0.2, 0.08 + 0.06 * pulse))
    c.draw_rect(vial, Color(0.85, 0.85, 0.9, 0.6), false, 1.0)
    c.draw_rect(Rect2(p.x - 8.0, p.y - 57.0, 16, 4), Color("#c9a25e"))


## Altar del conocimiento.
func altar(c: CanvasItem, at: Vector2, tex: Texture2D, t: float) -> void:
    var scale: float = 0.75
    var size := Vector2(tex.get_width(), tex.get_height()) * scale
    # La base visible del sprite está en y=99 de 112.
    var origin := Vector2(at.x - size.x * 0.5, at.y + 22.0 - 99.0 * scale)
    Lienzo.sombra(c, Vector2(at.x, at.y + 20.0), 30.0)
    # Luz cálida de ofrenda: el sprite original es muy oscuro sobre este suelo.
    var flicker: float = 0.5 + 0.5 * sin(t * 3.1) * sin(t * 1.3)
    Lienzo.elipse(c, Vector2(at.x, at.y + 18.0), 48.0, 20.0, Color(0.95, 0.72, 0.38, 0.07 + 0.03 * flicker))
    for r in range(3, 0, -1):
        c.draw_circle(at + Vector2(0.0, -14.0), 10.0 + float(r) * 7.0, Color(0.95, 0.74, 0.42, 0.035 + 0.015 * flicker))
    c.draw_texture_rect(tex, Rect2(origin, size), false, Color(1.55, 1.42, 1.22))
    # Velas a los lados del altar.
    for side in [-1.0, 1.0]:
        var centro := Vector2(at.x + side * 30.0, at.y + 14.0)
        c.draw_rect(Rect2(centro.x - 2.0, centro.y - 9.0, 4.0, 9.0), Color("#d8cfb4"))
        c.draw_circle(centro + Vector2(0.0, -12.0), 2.2 + flicker * 0.6, Color(1.0, 0.78, 0.35, 0.95))
        c.draw_circle(centro + Vector2(0.0, -12.0), 6.0, Color(1.0, 0.7, 0.3, 0.12))


## Libro o carta de la sala (se abre al encontrarla).
func carta(c: CanvasItem, at: Vector2, sheet: Texture2D, letter_found: bool, t: float) -> void:
    var frame: int = 0
    if letter_found:
        frame = 15 + int(t * 10.0) % 86
    else:
        var glow: float = 0.08 + 0.05 * sin(t * 2.4)
        c.draw_circle(at + Vector2(0.0, -8.0), 22.0, Color(0.59, 0.79, 0.55, glow))
    var scale: float = 1.5
    # Celda de 64x64; la base del libro está en y=45.
    # Desde y=26 de la celda: libro y páginas, sin los glifos que flotaban
    # sobre la estatua de detrás.
    var region := Rect2(float(frame * 64) + 4.0, 26.0, 56.0, 22.0)
    var dest := Rect2(at.x - 28.0 * scale, at.y - 19.0 * scale, 56.0 * scale, 22.0 * scale)
    c.draw_texture_rect_region(sheet, dest, region)


## Muro bajo del laberinto: cara superior clara, frente de sillares y musgo.
func muro(c: CanvasItem, r: Rect2) -> void:
    var lift: float = 22.0
    var top := Rect2(r.position.x, r.position.y - lift, r.size.x, r.size.y)
    var front := Rect2(r.position.x, r.position.y - lift + r.size.y, r.size.x, lift)
    c.draw_rect(Rect2(r.position + Vector2(3, 4), r.size), Color(0, 0, 0, 0.35)) # sombra
    c.draw_rect(front, Color("#2c2a2e"))
    var row: int = 0
    var y: float = front.position.y
    while y < front.end.y - 1.0:
        var off: float = 0.0 if row % 2 == 0 else 7.0
        var x: float = front.position.x - off
        while x < front.end.x:
            var bx: float = maxf(x, front.position.x)
            var bw: float = minf(x + 14.0, front.end.x) - bx
            if bw > 1.0:
                c.draw_rect(Rect2(bx + 0.5, y + 0.5, bw - 1.0, 6.0), Color("#3a373c") if (row + int(x)) % 3 else Color("#343136"))
            x += 14.0
        y += 7.0
        row += 1
    c.draw_rect(top, Color("#55505a"))
    c.draw_rect(Rect2(top.position, Vector2(top.size.x, 2)), Color("#6d6772"))
    c.draw_rect(Rect2(front.position.x, front.end.y - 3.0, front.size.x, 3), Color("#3f5236", 0.8)) # musgo
    c.draw_rect(Rect2(top.position.x, top.position.y, top.size.x, top.size.y + lift), Color(0, 0, 0, 0.55), false, 1.0)
