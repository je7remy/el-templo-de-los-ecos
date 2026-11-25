extends "res://scripts/entidades/jefes/jefe.gd"
## La Vigía (la Mirada, Piso VII): orbita la sala y te observa; hay que
## sostenerle la mirada el tiempo que pide la sala. Estados (guardados como
## antes): Mira ("mira"), Aviso ("aviso", te va a golpear), Golpe ("golpe"),
## Caza ("caza", va a por un peregrino que huye) y Vencida ("vencida").
##
## La escena la mueve, lleva el tiempo de mirada, los amagos y los ruidos a tu
## espalda; la campaña decide qué pasa al provocarla, el pánico de los
## aliados, el golpe, la presa y la victoria.

## Le diste la espalda o corriste («razon» para el aviso).
signal provocada(razon: String)
## Amago: se lanza sin aviso rojo y vuelve.
signal amago
## Ruido a tu espalda para que te des la vuelta.
signal ruido_hecho(en: Vector2)
## Un cuadro de mirada sostenida (la campaña revisa el pánico y la victoria).
signal mirando(dt: float)
## Arranca el golpe tras el aviso.
signal ataca
## El golpe te alcanza.
signal alcanza
## Alcanza al peregrino que huía.
signal presa_alcanzada

const CENTRO := Vector2(480, 350)
const RADIO := Vector2(250, 130)
const GRACIA := 0.7 # segundos de espalda que tolera

var angulo: float = 0.0
var mirada_t: float = 0.0 # tiempo que le has sostenido la mirada
var necesita: float = 0.0
var estado_t: float = 0.0
var espalda_t: float = 0.0
var objetivo: Vector2 = Vector2.ZERO
var amago_t: float = 0.0
var amago_k: float = 0.0
var ruido_t: float = 0.0
var ruido: Dictionary = {}
var presa: Dictionary = {}
## Un estado puede cortar el resto del cuadro (como un «return»).
var cortar: bool = false


func _ready() -> void:
    nombres = {"mira": "Mira", "aviso": "Aviso", "golpe": "Golpe", "caza": "Caza", "vencida": "Vencida"}
    poner("mira")


func orbita() -> Vector2:
    return CENTRO + Vector2(cos(angulo) * RADIO.x, sin(angulo) * RADIO.y)


## Un cuadro. «ctx»: la_miras (no le das la espalda).
func actualizar(dt: float, ctx: Dictionary) -> void:
    cortar = false
    actuar(dt, ctx)
    if cortar:
        return
    if not ruido.is_empty():
        ruido["t"] = float(ruido["t"]) - dt
        if float(ruido["t"]) <= 0.0:
            ruido = {}


# ------------------------------------------------------------ DIBUJO
const Lienzo := preload("res://scripts/comun/lienzo.gd")
const HOJA := preload("res://assets/visual/enemies/vigia.png")
const CELDA := Vector2(64, 96)
const BASE := 92.0


## Dibuja a la Vigía (flota y se transparenta al ser vencida).
func dibujar(c: CanvasItem, t: float) -> void:
    var e: String = estado()
    var cuadro: int = int(t * 1.5) % 2
    if e == "aviso" or e == "caza":
        cuadro = 2
    elif e == "golpe" or amago_k > 0.0:
        cuadro = 3
    var tinte := Color(1, 1, 1, 0.45) if e == "vencida" else Color.WHITE
    var vaiven: float = sin(t * 2.0) * 2.0
    Lienzo.sombra(c, position + Vector2(0, 4), 18.0, 0.6)
    c.draw_texture_rect_region(HOJA, Rect2(position.x - CELDA.x * 0.5, position.y + 2.0 + vaiven - BASE, CELDA.x, CELDA.y),
        Rect2(float(cuadro) * CELDA.x, 0, CELDA.x, CELDA.y), tinte)
