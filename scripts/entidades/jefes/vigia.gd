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
