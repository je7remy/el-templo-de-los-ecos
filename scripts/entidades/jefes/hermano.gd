extends "res://scripts/entidades/jefes/jefe.gd"
## El Hermano Mayor (Piso X): primero habla; luego lucha con las reglas que
## robó a las demás entidades. Estados: Habla ("talk"), Camina ("walk"),
## Zarpazo ("swipe"), ApuntaHilos ("threads_aim", líneas de aviso), Hilos
## ("threads", los hilos cortan), Ruge ("roar"), Cansado ("tired", tras
## rugir) y Mira ("gaze", castiga darle la espalda o correr). Su vida, los
## aliados y las piedras de los traidores los lleva la campaña.
## Valores PROVISIONALES.

## Elige su siguiente regla ("hilos", "rugido", "mirada").
signal regla(nombre: String)
## Los hilos dejan de ser aviso y cortan.
signal hilos_activos
## Ruge: «alcanza» si estás cerca y no esquivas.
signal rugido(alcanza: bool)

const VELOCIDAD := 62.0
const REGLAS := ["hilos", "rugido", "mirada"]
const RADIO_RUGIDO := 230.0
const ZARPAZO := 16.0
const HILO := 18.0
const MIRADA := 7.0

var t: float = 0.0
var cd: float = 0.0
var siguiente: int = 0 # índice de la próxima regla
var tick: float = 0.0
var orientacion: int = 3
var hilos: Array = [] # [desde, hasta]


func _ready() -> void:
    nombres = {"talk": "Habla", "walk": "Camina", "swipe": "Zarpazo", "threads_aim": "ApuntaHilos", "threads": "Hilos",
        "roar": "Ruge", "tired": "Cansado", "gaze": "Mira"}
    poner("talk")


## Tiempos y hacia dónde mira; va antes que nada en cada cuadro.
func preparar_cuadro(dt: float) -> void:
    t = maxf(0.0, t - dt)
    cd = maxf(0.0, cd - dt)
    var mira: Vector2 = jugador.position - position
    if mira.length() > 1.0:
        orientacion = (2 if mira.x > 0.0 else 3) if absf(mira.x) > absf(mira.y) else (0 if mira.y > 0.0 else 1)


## Un cuadro de pelea. «ctx»: enfurecido (menos de media vida) y huye (le
## diste la espalda o esquivaste este cuadro).
func actualizar(dt: float, ctx: Dictionary) -> void:
    ctx["mira"] = jugador.position - position
    actuar(dt, ctx)


## Elige la siguiente regla robada y la prepara.
func siguiente_regla(enfurecido: bool) -> void:
    var r: String = REGLAS[siguiente % REGLAS.size()]
    siguiente += 1
    match r:
        "hilos":
            poner("threads_aim")
            t = 0.9
            hilos.clear()
            var p: Vector2 = jugador.position
            hilos.append([Vector2(90, p.y), Vector2(870, p.y)])
            hilos.append([Vector2(p.x, 190), Vector2(p.x, 560)])
            if enfurecido:
                hilos.append([position, position + (p - position).normalized() * 900.0])
        "rugido":
            poner("roar")
            t = 1.1 if not enfurecido else 0.85
        "mirada":
            poner("gaze")
            t = 3.5
            tick = 0.4
    regla.emit(r)
