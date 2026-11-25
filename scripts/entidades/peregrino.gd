extends "res://scripts/entidades/jefes/jefe.gd"
## El Peregrino (Piso V): te acompaña y compite por las almas. Si es traidor,
## en la cripta de la cosecha desenvaina. Estados (guardados como antes):
## Ausente ("none"), Espera ("waiting"), Sigue ("follow"), Desenvaina
## ("tell", aviso), Hostil ("hostile"), Amigo ("friend") y Muerto ("dead").
##
## La escena lo mueve, decide a qué alma va y cuándo tira el tajo; si es
## traidor, su vida, sus almas, lo que dice y lo que pasa al morir los lleva la
## campaña. Usa «hiere» de los jefes para nada: el tajo avisa con «tajo».

## Llega a un alma antes que tú (índice en la lista de la sala).
signal toma_alma(indice: int)
## Se detiene y alza el cuchillo (aviso justo).
signal prepara_tajo
## Descarga el tajo: «alcanza» si estás cerca y no eres invulnerable.
signal tajo(alcanza: bool)

var traidor: bool = true
var anterior: Vector2 = Vector2.ZERO
var orientacion: int = 0
var moviendose: bool = false
var temporizador: float = 0.0 # aviso antes de traicionar / carga del tajo
var cd: float = 0.0
var estocada: float = 0.0
var golpe_t: float = 0.0
var aturdido: float = 0.0


func _ready() -> void:
    nombres = {"none": "Ausente", "waiting": "Espera", "follow": "Sigue", "tell": "Desenvaina", "hostile": "Hostil",
        "friend": "Amigo", "dead": "Muerto"}
    poner("none")


func presente() -> bool:
    return estado() in ["follow", "tell", "hostile", "friend"]


## Un cuadro. «ctx»: almas (posiciones de las almas de la sala) y recogidas.
func actualizar(dt: float, ctx: Dictionary) -> void:
    golpe_t = maxf(0.0, golpe_t - dt)
    cd = maxf(0.0, cd - dt)
    estocada = maxf(0.0, estocada - dt)
    aturdido = maxf(0.0, aturdido - dt)
    actuar(dt, ctx)


## Dirección hacia la que miras (o a la derecha si no hay).
func tu_direccion() -> Vector2:
    var d: Vector2 = jugador.direccion
    return d.normalized() if d.length() > 0.1 else Vector2.RIGHT


func mover_a(destino: Vector2, velocidad: float, dt: float) -> void:
    var delta_v: Vector2 = destino - position
    if delta_v.length() < 12.0:
        moviendose = false
        return
    var paso: Vector2 = delta_v.normalized() * velocidad * dt
    var movido := false
    var nx := Vector2(position.x + paso.x, position.y)
    if not bloqueado(nx):
        position.x = nx.x
        movido = true
    var ny := Vector2(position.x, position.y + paso.y)
    if not bloqueado(ny):
        position.y = ny.y
        movido = true
    # Atascado lejos de ti: retoma el camino detrás de tus pasos.
    if not movido and position.distance_to(jugador.position) > 160.0:
        var detras: Vector2 = jugador.position - (jugador.direccion as Vector2).normalized() * 40.0
        if not bloqueado(detras):
            position = detras
    moviendose = movido
    mirar(paso)


func mirar(v: Vector2) -> void:
    if v.length() < 0.1:
        return
    if absf(v.x) > absf(v.y):
        orientacion = 2 if v.x > 0.0 else 3
    else:
        orientacion = 0 if v.y > 0.0 else 1
