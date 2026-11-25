extends Node
## Personajes secundarios de la sala, dibujados en su turno del orden por
## profundidad: aliados (peregrinos que guías), traidores del Hermano Mayor,
## el peregrino enjaulado del rescate, el Mercader y el muñeco de
## entrenamiento. Lo que hacen lo decide la campaña; aquí solo se dibujan
## sobre el lienzo del mundo («c»).

const Lienzo := preload("res://scripts/comun/lienzo.gd")
const TINTES_ALIADOS := [Color(0.86, 1.0, 0.9), Color(1.0, 0.88, 0.84), Color(0.86, 0.92, 1.08)]
const MERCADER := preload("res://assets/visual/enemies/mercader.png")
const MERCADER_CELDA := Vector2(64, 96)
const MERCADER_BASE := 92.0
const MUNECO := Vector2(480, 300)


func aliado(c: CanvasItem, i: int, ally: Dictionary, hoja: Texture2D, t: float) -> void:
    var cuadro: int = 2 + int(t * 8.0 + float(i)) % 4 if bool(ally["moving"]) else int(t * 2.0 + float(i)) % 2
    var region := Rect2(float(cuadro) * Lienzo.CELDA.x, float(ally["facing"]) * Lienzo.CELDA.y, Lienzo.CELDA.x, Lienzo.CELDA.y)
    var pos: Vector2 = ally["pos"]
    var pies := Vector2(roundf(pos.x), roundf(pos.y + 4.0))
    Lienzo.sombra(c, pos + Vector2(0.0, 3.0), 12.0)
    Lienzo.elipse(c, pos + Vector2(0.0, 3.0), 17.0, 6.0, Color(0.45, 0.85, 0.6, 0.16))
    Lienzo.contorno(c, hoja, Rect2(pies.x - Lienzo.CELDA.x * 0.5, pies.y - Lienzo.PIES, Lienzo.CELDA.x, Lienzo.CELDA.y), region, TINTES_ALIADOS[i % TINTES_ALIADOS.size()])


## Traidor del Hermano Mayor: alza la piedra poco antes de tirarla.
func traidor(c: CanvasItem, i: int, tr: Dictionary, hoja: Texture2D, t: float) -> void:
    var en: Vector2 = tr["pos"]
    var cuadro: int = 6 if float(tr["cd"]) < 0.6 else int(t * 2.0 + float(i)) % 2
    Lienzo.sombra(c, en + Vector2(0, 3), 12.0)
    Lienzo.elipse(c, en + Vector2(0, 3), 17.0, 6.0, Color(0.9, 0.2, 0.25, 0.18))
    c.draw_texture_rect_region(hoja, Rect2(en.x - Lienzo.CELDA.x * 0.5, en.y + 4.0 - Lienzo.PIES, Lienzo.CELDA.x, Lienzo.CELDA.y), Rect2(float(cuadro) * Lienzo.CELDA.x, 3.0 * Lienzo.CELDA.y, Lienzo.CELDA.x, Lienzo.CELDA.y), Color(1.0, 0.7, 0.7))


## Peregrino del rescate: enjaulado (se agita) o ya libre.
func rescate(c: CanvasItem, en: Vector2, hoja: Texture2D, libre: bool, t: float) -> void:
    var cuadro: int = int(t * 2.0) % 2 if libre else (6 if int(t * 3.0) % 3 == 0 else 0)
    Lienzo.sombra(c, en + Vector2(0, 3), 12.0)
    c.draw_texture_rect_region(hoja, Rect2(en.x - Lienzo.CELDA.x * 0.5, en.y + 4.0 - Lienzo.PIES, Lienzo.CELDA.x, Lienzo.CELDA.y),
        Rect2(float(cuadro) * Lienzo.CELDA.x, 0, Lienzo.CELDA.x, Lienzo.CELDA.y), Color(0.95, 0.9, 1.0))
    if not libre:
        var g := Rect2(en.x - 22.0, en.y - 18.0, 44.0, 20.0)
        for k in range(6):
            c.draw_line(Vector2(g.position.x + float(k) * 8.0 + 2.0, g.position.y), Vector2(g.position.x + float(k) * 8.0 - 4.0, g.end.y), Color("#5b5f63"), 2.0)
        c.draw_line(g.position, Vector2(g.end.x, g.position.y + 4.0), Color("#7a7f84"), 2.0)


## El Mercader con su cuenco; abre los brazos mientras atiende.
func mercader(c: CanvasItem, m: Vector2, abierto: bool, t: float) -> void:
    var cuenco: Vector2 = m + Vector2(0, 30)
    Lienzo.sombra(c, cuenco + Vector2(0, 4), 14.0)
    c.draw_rect(Rect2(cuenco.x - 6.0, cuenco.y - 6.0, 12, 8), Color("#3a3036"))
    Lienzo.elipse(c, cuenco + Vector2(0, -8), 15.0, 5.0, Color("#6a5440"))
    Lienzo.elipse(c, cuenco + Vector2(0, -9), 12.0, 3.5, Color("#1a1420"))
    var cuadro: int = 2 if abierto else int(t * 1.2) % 2
    Lienzo.sombra(c, m + Vector2(0, 2), 22.0)
    c.draw_texture_rect_region(MERCADER, Rect2(m.x - MERCADER_CELDA.x * 0.5, m.y + 2.0 - MERCADER_BASE, MERCADER_CELDA.x, MERCADER_CELDA.y),
        Rect2(float(cuadro) * MERCADER_CELDA.x, 0, MERCADER_CELDA.x, MERCADER_CELDA.y))


## Muñeco de entrenamiento: tiembla al golpearlo y lleva la cuenta.
func muneco(c: CanvasItem, golpes: int, sacudida: float, t: float) -> void:
    var p := MUNECO + Vector2(sin(t * 50.0) * 3.0 * sacudida * 4.0, 0.0)
    Lienzo.sombra(c, MUNECO + Vector2(0, 3), 14.0)
    c.draw_rect(Rect2(p.x - 2.0, p.y - 40.0, 4, 42), Color("#5c3a22"))
    c.draw_rect(Rect2(p.x - 16.0, p.y - 34.0, 32, 6), Color("#5c3a22"))
    c.draw_rect(Rect2(p.x - 11.0, p.y - 50.0, 22, 26), Color("#b89a5e"))
    c.draw_rect(Rect2(p.x - 11.0, p.y - 50.0, 22, 4), Color("#d8bd80"))
    c.draw_circle(p + Vector2(0, -60), 9.0, Color("#b89a5e"))
    c.draw_circle(p + Vector2(0, -37), 6.0, Color("#8a1620"))
    c.draw_circle(p + Vector2(0, -37), 3.0, Color("#e2dccb"))
    for k in range(golpes):
        c.draw_rect(Rect2(p.x - 8.0 + float(k) * 6.0, p.y - 46.0, 3, 3), Color("#3a2f2a"))
