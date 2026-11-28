extends Node
## Profundidad: sombras proyectadas y manchas de sangre en el suelo.
##
## Sombras: cada personaje proyecta una sombra alargada en sentido contrario a
## las luces fuertes que tiene cerca (la antorcha que llevas, los braseros, el
## fuego). Cuanto más lejos de la luz, más larga y más débil; con la llama
## temblando, la sombra tiembla con ella. Es lo que más hace que la sala se
## lea en volumen sin dejar el pixel art.
##
## Manchas: la sangre de los golpes se queda en el suelo de la sala hasta
## que sales de ella.
##
## Solo dibuja: la campaña (main.gd) le pasa los cuerpos y las luces, sobre el
## lienzo del mundo («c»), antes de los personajes.

const MAX_LUCES_POR_CUERPO := 2
const ALTURA_LUZ := 64.0 # a qué altura imaginamos la llama
const MAX_MANCHAS := 40

## [pos, radio, color] en coordenadas del mundo.
var manchas: Array = []


## cuerpos: [[pies, alto, ancho, luz propia, solo esta luz], …];
## luces: [[suelo, radio, intensidad, id], …].
## Un cuerpo con id de luz propio («propia») no recibe la sombra de esa luz
## (la antorcha que lleva el jugador no le hace sombra a él mismo).
func proyectadas(c: CanvasItem, cuerpos: Array, luces: Array, t: float) -> void:
    for b in cuerpos:
        var pies: Vector2 = b[0]
        var alto: float = b[1]
        var ancho: float = b[2]
        var propia: String = str(b[3]) if b.size() > 3 else ""
        var solo: String = str(b[4]) if b.size() > 4 else ""
        var candidatas: Array = []
        for l in luces:
            if propia != "" and str(l[3]) == propia:
                continue
            if solo != "" and str(l[3]) != solo:
                continue
            var d: Vector2 = pies - Vector2(l[0])
            var dist: float = d.length()
            var alcance: float = float(l[1]) * 1.5
            if dist < 6.0 or dist > alcance:
                continue
            var fuerza: float = float(l[2]) * (1.0 - pow(dist / alcance, 2.0))
            candidatas.append([fuerza, d / dist, dist])
        candidatas.sort_custom(func(x, y): return x[0] > y[0])
        for i in range(mini(MAX_LUCES_POR_CUERPO, candidatas.size())):
            var k: Array = candidatas[i]
            var temblor: float = 1.0 + sin(t * 11.0 + pies.x * 0.05) * 0.04
            _sombra(c, pies, k[1], alto, ancho, float(k[2]), float(k[0]) * (1.0 if i == 0 else 0.6), temblor)


func _sombra(c: CanvasItem, pies: Vector2, dir: Vector2, alto: float, ancho: float, dist: float, fuerza: float, temblor: float) -> void:
    var largo: float = minf(alto * dist / ALTURA_LUZ, alto * 1.4) * temblor + 6.0
    # Vista cenital: la sombra se aplana un poco en vertical.
    var d := Vector2(dir.x, dir.y * 0.75).normalized()
    var perp := Vector2(-d.y, d.x)
    var a: float = clampf(0.62 * fuerza, 0.0, 0.55)
    # Tres capas (núcleo y dos halos) en tramos que se desvanecen hacia la punta.
    # (draw_polygon con colores por vértice no pinta en el renderizador
    # Compatibility: por eso se hace por tramos de color liso.)
    const TRAMOS := 5
    for capa in range(3):
        var w: float = ancho * 0.5 * (1.0 + float(capa) * 0.3)
        var l: float = largo * (1.0 + float(capa) * 0.1)
        var alfa: float = a * (0.7 if capa == 0 else 0.25)
        for j in range(TRAMOS):
            var t0: float = float(j) / float(TRAMOS)
            var t1: float = float(j + 1) / float(TRAMOS)
            var w0: float = w * lerpf(0.7, 1.15, t0)
            var w1: float = w * lerpf(0.7, 1.15, t1)
            var p0: Vector2 = pies + d * l * t0
            var p1: Vector2 = pies + d * l * t1
            var puntos := PackedVector2Array([p0 + perp * w0, p0 - perp * w0, p1 - perp * w1, p1 + perp * w1])
            c.draw_colored_polygon(puntos, Color(0, 0, 0, alfa * (1.0 - (float(j) + 0.5) / float(TRAMOS))))


# ------------------------------------------------------------------ manchas

func mancha(pos: Vector2, cantidad: int = 1) -> void:
    for i in range(cantidad):
        var p := pos + Vector2(randf_range(-14, 14), randf_range(-5, 7))
        manchas.append([p, randf_range(1.5, 4.5), Color(randf_range(0.32, 0.48), 0.02, 0.05, randf_range(0.45, 0.7))])
    while manchas.size() > MAX_MANCHAS:
        manchas.pop_front()


func limpiar() -> void:
    manchas.clear()


func dibujar_manchas(c: CanvasItem) -> void:
    for m in manchas:
        var p: Vector2 = m[0]
        var r: float = m[1]
        var col: Color = m[2]
        c.draw_circle(p, r, col)
        c.draw_circle(p + Vector2(r * 0.7, r * 0.3), r * 0.55, Color(col.r * 0.8, col.g, col.b, col.a * 0.8))
        # Pequeño brillo húmedo.
        c.draw_rect(Rect2(p - Vector2(r * 0.4, r * 0.5), Vector2(1, 1)), Color(0.9, 0.4, 0.4, col.a * 0.5))
