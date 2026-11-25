extends Node
## Trampas y peligros de la sala, solo su dibujo: placas de pinchos, rejillas
## de fuego con su llamarada, péndulos (surco, cadena y cuchilla),
## enredaderas (intactas, ardiendo o en ceniza) con sus llamas y los canales
## de almas. Cuándo hieren y a quién lo decide la campaña (main.gd); aquí se
## dibuja lo que ella dice, sobre el lienzo del mundo («c»), en su turno.

const Lienzo := preload("res://scripts/comun/lienzo.gd")


## Pinchos. trampas: [[rect, t del ciclo, ensangrentada], …]; «ciclo»:
## [duración, aviso (asoman), arriba (hieren)].
func pinchos(c: CanvasItem, trampas: Array, ciclo: Array, t: float) -> void:
    var cycle: float = ciclo[0]
    var warn: float = ciclo[1]
    var up: float = ciclo[2]
    for trap in trampas:
        var r: Rect2 = trap[0]
        var k: float = trap[1]
        # Placa de hierro con agujeros.
        c.draw_rect(r.grow(2.0), Color(0.04, 0.04, 0.05, 0.55))
        c.draw_rect(r, Color("#2c2f33"))
        c.draw_rect(Rect2(r.position, Vector2(r.size.x, 2)), Color("#4a4e54"))
        for gx in range(3):
            for gy in range(3):
                var hole := r.position + Vector2(6.0 + gx * 9.0, 6.0 + gy * 9.0)
                c.draw_rect(Rect2(hole, Vector2(4, 3)), Color("#0c0d0f"))
        var rise: float = 0.0
        if k >= up:
            rise = 1.0 if k < cycle - 0.25 else (cycle - k) / 0.25
        elif k >= warn:
            rise = 0.25 + 0.08 * sin(t * 40.0) # asoman y tiemblan: aviso
        if rise <= 0.0:
            continue
        var steel := Color("#c3c9c4")
        for gx in range(3):
            for gy in range(3):
                var base := r.position + Vector2(8.0 + gx * 9.0, 9.0 + gy * 9.0)
                var tip := base + Vector2(0, -11.0 * rise)
                c.draw_colored_polygon(PackedVector2Array([base + Vector2(-3, 0), base + Vector2(3, 0), tip]), steel)
                c.draw_line(base + Vector2(0, -1), tip, Color("#f0f2ee"), 1.0)
                if bool(trap[2]) and rise > 0.6 and (gx + gy) % 2 == 0:
                    c.draw_circle(tip + Vector2(0, 2), 1.5, Color("#9c1c25"))
        if k >= warn and k < up:
            c.draw_rect(r.grow(3.0), Color(1.0, 0.35, 0.3, 0.25 + 0.2 * sin(t * 20.0)), false, 1.0)


## A ras de suelo: rejillas de fuego (rejillas: [[pos, t del ciclo], …];
## ciclo: [aviso, quema]) y el surco y la sombra de cada péndulo
## (pendulos: [[centro, amplitud, cuchilla], …]).
func suelo(c: CanvasItem, rejillas: Array, ciclo: Array, pendulos: Array, t: float) -> void:
    var warn: float = ciclo[0]
    var on: float = ciclo[1]
    for v in rejillas:
        var p: Vector2 = v[0]
        var k: float = v[1]
        var g := Rect2(p - Vector2(15, 11), Vector2(30, 22))
        c.draw_rect(g.grow(3.0), Color(0.03, 0.025, 0.03, 0.6))
        c.draw_rect(g, Color("#2a2522"))
        c.draw_rect(Rect2(g.position, Vector2(g.size.x, 2)), Color("#544a40"))
        var heat: float = 0.0
        if k >= on:
            heat = 1.0
        elif k >= warn:
            heat = (k - warn) / (on - warn)
        for n in range(4):
            var slot := Rect2(g.position + Vector2(4.0 + n * 6.5, 5), Vector2(3.5, 12))
            c.draw_rect(slot, Color(0.06, 0.04, 0.03).lerp(Color(1.0, 0.45, 0.12), heat * (0.7 + 0.3 * sin(t * 18.0 + n))))
        # Hollín alrededor.
        Lienzo.elipse(c, p + Vector2(0, 2), 24.0, 8.0, Color(0.0, 0.0, 0.0, 0.18))
        if k >= warn and k < on:
            c.draw_rect(g.grow(4.0), Color(1.0, 0.5, 0.2, 0.25 + 0.2 * sin(t * 20.0)), false, 1.0)
    for pd in pendulos:
        # Surco en el suelo: dice por dónde pasará la cuchilla.
        var centro: Vector2 = pd[0]
        var a: float = pd[1]
        c.draw_line(centro + Vector2(-a - 10.0, 4), centro + Vector2(a + 10.0, 4), Color(0.0, 0.0, 0.0, 0.35), 6.0)
        c.draw_line(centro + Vector2(-a - 10.0, 3), centro + Vector2(a + 10.0, 3), Color(0.55, 0.5, 0.42, 0.18), 1.0)
        Lienzo.elipse(c, Vector2(pd[2]) + Vector2(0, 6), 18.0, 5.0, Color(0, 0, 0, 0.35))


## Lo que se alza: la columna de fuego (rejillas: [[pos, t del ciclo], …];
## ciclo: [duración, quema]) y la cuchilla con su cadena (pendulos:
## [[pivote, cuchilla, velocidad], …]; velocidad de -1 a 1, para la estela).
func aire(c: CanvasItem, rejillas: Array, ciclo: Array, pendulos: Array, t: float) -> void:
    var cycle: float = ciclo[0]
    var on: float = ciclo[1]
    for v in rejillas:
        var k0: float = v[1]
        if k0 < on:
            continue
        var p: Vector2 = v[0]
        var k: float = clampf((k0 - on) / 0.2, 0.0, 1.0) * clampf((cycle - k0) / 0.25, 0.0, 1.0)
        for i in range(7):
            var h: float = (78.0 + 12.0 * sin(t * 14.0 + float(i))) * k
            var wv: float = (18.0 - float(i) * 2.0) * k
            var y0: float = p.y - h * (float(i) / 6.0)
            var col := Color(1.0, 0.35 + 0.1 * float(i), 0.1 + 0.08 * float(i), 0.55 - float(i) * 0.06)
            c.draw_polygon(PackedVector2Array([p + Vector2(-wv, 2), p + Vector2(wv, 2), Vector2(p.x + wv * 0.3 + sin(t * 11.0 + i) * 3.0, y0 - 14.0)]),
                PackedColorArray([col, col, Color(col.r, col.g, col.b, 0.0)]))
    for pd in pendulos:
        var pivot: Vector2 = pd[0]
        var lift: Vector2 = Vector2(pd[1]) + Vector2(0, -16) # la hoja vuela a la altura del pecho
        # Cadena por eslabones.
        var n: int = 14
        for i in range(n):
            var q: Vector2 = pivot.lerp(lift, float(i) / float(n))
            c.draw_rect(Rect2(q - Vector2(2, 3), Vector2(4, 6)), Color("#14110f"))
            c.draw_rect(Rect2(q - Vector2(1, 2), Vector2(2, 4)), Color("#8a857a") if i % 2 == 0 else Color("#5c5850"))
        var ang: float = (lift - pivot).angle() - PI * 0.5
        Lienzo.xf(c, lift, ang, Vector2.ONE)
        # Media luna de acero con filo brillante y contorno oscuro.
        var blade := PackedVector2Array([Vector2(-30, -2), Vector2(30, -2), Vector2(24, 10), Vector2(10, 17), Vector2(0, 19), Vector2(-10, 17), Vector2(-24, 10)])
        var outline := blade.duplicate()
        outline.append(blade[0])
        c.draw_colored_polygon(blade, Color("#6f767c"))
        c.draw_colored_polygon(PackedVector2Array([Vector2(-26, 0), Vector2(26, 0), Vector2(18, 6), Vector2(-18, 6)]), Color("#4d5358"))
        c.draw_polyline(outline, Color("#101214"), 2.0)
        c.draw_polyline(PackedVector2Array([Vector2(-24, 10), Vector2(-10, 17), Vector2(0, 19), Vector2(10, 17), Vector2(24, 10)]), Color("#eef3f5"), 2.0)
        c.draw_rect(Rect2(-6, -8, 12, 8), Color("#3b2f28"))
        c.draw_rect(Rect2(-6, -8, 12, 8), Color("#101214"), false, 1.0)
        Lienzo.xf(c, Vector2.ZERO, 0.0, Vector2.ONE)
        # Estela al barrer.
        var vel: float = pd[2]
        for k in range(1, 4):
            c.draw_circle(lift + Vector2(-vel * float(k) * 9.0, 8), 10.0 - float(k) * 2.0, Color(0.85, 0.9, 0.95, 0.06 * absf(vel)))


## Enredaderas. celdas: [[centro, datos de la enredadera, vecinas intactas
## (centros)], …]; datos: {state, seed, verde, t}.
func enredaderas(c: CanvasItem, celdas: Array, t: float) -> void:
    for e in celdas:
        var centro: Vector2 = e[0]
        var v: Dictionary = e[1]
        var seed_v: int = int(v["seed"])
        match str(v["state"]):
            "intacta":
                # Tallos que se enlazan con las celdas vecinas, con espinas y hojas secas.
                var base: Color = Color("#3d5a2a") if bool(v["verde"]) else Color("#6b5236")
                var light: Color = Color("#5f8040") if bool(v["verde"]) else Color("#a88452")
                var thick: float = 4.0 if bool(v["verde"]) else 3.0
                var vecinas: Array = e[2]
                for nc in vecinas:
                    var n: Vector2 = (Vector2(nc) - centro).orthogonal().normalized()
                    for k in range(2):
                        var bend: float = (float((seed_v >> (k * 3)) % 9) - 4.0) * 1.4 + float(k) * 3.0 - 1.5
                        var m1: Vector2 = centro.lerp(nc, 0.33) + n * bend
                        var m2: Vector2 = centro.lerp(nc, 0.66) - n * bend
                        c.draw_polyline(PackedVector2Array([centro + n * float(k * 3 - 1), m1, m2, Vector2(nc) + n * float(k * 3 - 1)]), base if k == 0 else light, thick if k == 0 else 1.0)
                if vecinas.is_empty():
                    c.draw_circle(centro, 5.0, base)
                for k in range(3):
                    var t_pos: Vector2 = centro + Vector2(float((seed_v >> k) % 24) - 12.0, float((seed_v >> (k + 3)) % 14) - 7.0)
                    if k == 0:
                        c.draw_line(t_pos, t_pos + Vector2(2, -3), light, 1.0) # espina
                    else:
                        c.draw_rect(Rect2(t_pos.round(), Vector2(3, 2)), Color("#7da04f") if bool(v["verde"]) else Color("#9a7434"))
            "fuego":
                c.draw_rect(Rect2(centro - Vector2(15, 15), Vector2(30, 30)), Color(0.35, 0.08, 0.02, 0.6))
            "ceniza":
                var glow: float = clampf(1.0 - float(v["t"]) / 4.0, 0.0, 1.0)
                c.draw_rect(Rect2(centro - Vector2(14, 12), Vector2(28, 24)), Color(0.08, 0.07, 0.07, 0.75))
                for k in range(3):
                    var em: Vector2 = centro + Vector2(float((seed_v >> k) % 22) - 11.0, float((seed_v >> (k + 2)) % 18) - 9.0)
                    c.draw_rect(Rect2(em.round(), Vector2(2, 1)), Color(1.0, 0.45, 0.15, 0.2 + 0.7 * glow * (0.5 + 0.5 * sin(t * 5.0 + float(k)))))


## Llamas sobre la penumbra, con parpadeo; menguan al final de la quema.
## ardiendo: [[centro de la celda, datos], …]; «quema»: segundos que arde.
func llamas(c: CanvasItem, ardiendo: Array, quema: float, t: float) -> void:
    for e in ardiendo:
        var v: Dictionary = e[1]
        var centro: Vector2 = Vector2(e[0]) + Vector2(0, 8)
        var life: float = float(v["t"]) / quema
        var size: float = clampf(life * 6.0, 0.0, 1.0) * clampf((1.0 - life) * 3.0, 0.25, 1.0)
        for k in range(3):
            var x: float = centro.x - 9.0 + float(k) * 9.0
            var flick: float = 0.75 + 0.25 * sin(t * 17.0 + float(k) * 2.1 + float(v["seed"]))
            var h: float = (16.0 + 8.0 * float((int(v["seed"]) >> k) % 3)) * flick * size
            c.draw_colored_polygon(PackedVector2Array([Vector2(x - 6, centro.y), Vector2(x + 6, centro.y), Vector2(x, centro.y - h)]), Color(1.0, 0.42, 0.12, 0.85))
            c.draw_colored_polygon(PackedVector2Array([Vector2(x - 3, centro.y), Vector2(x + 3, centro.y), Vector2(x, centro.y - h * 0.6)]), Color(1.0, 0.85, 0.4, 0.9))
        c.draw_circle(centro + Vector2(0, -8), 18.0 * size, Color(1.0, 0.5, 0.15, 0.10))


## Canales de almas en el suelo: [[desde, hasta], …].
func canales(c: CanvasItem, lista: Array) -> void:
    for ch in lista:
        c.draw_line(ch[0], ch[1], Color(0.04, 0.05, 0.07, 0.85), 6.0)
        c.draw_line(ch[0], ch[1], Color(0.25, 0.5, 0.6, 0.25), 2.0)
