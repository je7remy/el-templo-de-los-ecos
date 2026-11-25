extends "res://scripts/entidades/jefes/jefe.gd"
## El Coloso del Pórtico (Piso IX): estatua viva inmune a golpes. Estados:
## Camina ("walk", hacia ti, más rápido con cada columna que le cae), Alza
## ("raise", aviso del pisotón), Pisa ("stomp") y Aturdido ("stun", tras
## caerle una columna). Las columnas y su derrota las lleva la campaña.
## Valores PROVISIONALES.

## Alza el pie (aviso).
signal alza
## Pisa: «alcanza» si estás dentro del círculo y expuesto.
signal pisoton(alcanza: bool)

const VELOCIDAD := 40.0
const RADIO := 130.0
const ALZA := 0.85

var golpes: int = 0 # columnas que le han caído
var t: float = 0.0
var cd: float = 2.0


func _ready() -> void:
    nombres = {"walk": "Camina", "raise": "Alza", "stomp": "Pisa", "stun": "Aturdido"}
    poner("walk")


func actualizar(dt: float) -> void:
    cd = maxf(0.0, cd - dt)
    t = maxf(0.0, t - dt)
    actuar(dt, {"d": position.distance_to(jugador.position)})


# ------------------------------------------------------------ DIBUJO
const Lienzo := preload("res://scripts/comun/lienzo.gd")
const HOJA := preload("res://assets/visual/enemies/coloso.png")


## Dibuja al Coloso; al alzar el pie, el círculo rojo del pisotón.
func dibujar(c: CanvasItem, tiempo: float) -> void:
    var cuadro: int
    match estado():
        "raise":
            cuadro = 4
        "stomp":
            cuadro = 5
        "stun":
            cuadro = 6
        _:
            cuadro = 2 + int(tiempo * 3.0) % 2
    var pos: Vector2 = position.round()
    Lienzo.sombra(c, pos + Vector2(0, 4), 56.0, 1.2)
    c.draw_texture_rect_region(HOJA, Rect2(pos.x - 64.0, pos.y + 6.0 - 154.0, 128, 160), Rect2(float(cuadro) * 128.0, 0, 128, 160))
    if estado() == "raise":
        var k: float = 1.0 - clampf(t / ALZA, 0.0, 1.0)
        Lienzo.elipse(c, pos, RADIO * k, RADIO * 0.45 * k, Color(1.0, 0.2, 0.2, 0.12 + 0.18 * k))
        c.draw_arc(pos, RADIO, 0, TAU, 48, Color(1.0, 0.3, 0.3, 0.3 + 0.4 * k), 2.0)
