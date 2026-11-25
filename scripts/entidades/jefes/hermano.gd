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


# ------------------------------------------------------------ DIBUJO
const Lienzo := preload("res://scripts/comun/lienzo.gd")


## Dibuja al Hermano Mayor (más grande que un peregrino, con su corona).
## «activo»: luchando; «figura»: la figura tranquila del X-1; «golpe_t»:
## destello de daño. El rótulo AGOTADO lo pone la campaña (_label_center).
func dibujar(c: CanvasItem, hoja: Texture2D, tiempo: float, activo: bool, figura: bool, golpe_t: float) -> void:
    var e: String = estado()
    var cuadro: int = int(tiempo * 2.0) % 2
    match e:
        "walk":
            cuadro = 2 + int(tiempo * 8.0) % 4
        "threads_aim", "roar", "swipe":
            cuadro = 6
        "threads", "gaze":
            cuadro = 7
        "tired":
            cuadro = 0
    if figura:
        cuadro = int(tiempo * 2.0) % 2
    var escala: float = 1.35
    var celda: Vector2 = Lienzo.CELDA * escala
    var pies := Vector2(roundf(position.x), roundf(position.y + 4.0))
    Lienzo.sombra(c, position + Vector2(0, 3), 18.0)
    if activo and e == "roar":
        var k: float = 1.0 - clampf(t / 1.1, 0.0, 1.0)
        Lienzo.elipse(c, position, RADIO_RUGIDO * k, RADIO_RUGIDO * 0.45 * k, Color(1.0, 0.2, 0.2, 0.1 + 0.15 * k))
        c.draw_arc(position, RADIO_RUGIDO, 0, TAU, 64, Color(1.0, 0.3, 0.3, 0.35 + 0.4 * k), 2.0)
    var tinte := Color(1.0, 0.86, 0.7)
    if golpe_t > 0.0:
        tinte = Color(1.0, 0.45, 0.4)
    elif e == "tired":
        tinte = Color(0.8, 0.85, 1.0)
    c.draw_texture_rect_region(hoja, Rect2(pies.x - celda.x * 0.5, pies.y - Lienzo.PIES * escala, celda.x, celda.y), Rect2(float(cuadro) * Lienzo.CELDA.x, float(orientacion) * Lienzo.CELDA.y, Lienzo.CELDA.x, Lienzo.CELDA.y), tinte)
    var cabeza: Vector2 = pies + Vector2(0, -Lienzo.PIES * escala + 12.0)
    c.draw_rect(Rect2(cabeza.x - 10.0, cabeza.y, 20, 3), Color("#e3bd7b"))
    c.draw_colored_polygon(PackedVector2Array([cabeza + Vector2(-3, 0), cabeza + Vector2(3, 0), cabeza + Vector2(0, -6)]), Color("#e3bd7b"))
    if activo and e == "gaze":
        var g: float = 0.6 + 0.4 * sin(tiempo * 10.0)
        c.draw_circle(cabeza + Vector2(-4, 10), 2.5, Color(1.0, 0.3, 0.3, g))
        c.draw_circle(cabeza + Vector2(4, 10), 2.5, Color(1.0, 0.3, 0.3, g))
        for k in range(3, 0, -1):
            c.draw_circle(cabeza + Vector2(0, 10), 8.0 + float(k) * 8.0, Color(1.0, 0.2, 0.2, 0.05))
    if activo and e == "tired":
        c.call("_label_center", "AGOTADO", pies + Vector2(0, -Lienzo.PIES * escala - 14.0), Color("#8fc7d7"))
