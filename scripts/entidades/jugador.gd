extends Node2D
## El jugador: dónde está, hacia dónde mira y cómo se mueve.
##
## Su máquina de estados («Maquina», scripts/comun/maquina_estados.gd) tiene
## tres estados: Quieto, Camina y Esquiva. Cada uno decide la velocidad del
## cuadro (inercia corta al andar, impulso que se frena al esquivar); aquí se
## aplica el movimiento con las colisiones de la sala, se dejan las siluetas
## del esquive y se cuentan los pasos.
##
## La campaña (main.gd) llama a avanzar() cada cuadro de juego con el eje de
## los controles y la velocidad de paso (que cambia con Ecos y equipo), y
## escucha las señales para el sonido y las partículas. La vida, el vigor y
## el dibujo siguen en main.gd por ahora (docs/ARQUITECTURA.md, fase 3).
##
## position es la posición de los pies en coordenadas de la sala.

## Un paso: suena y levanta polvo.
signal paso(en: Vector2, esquivando: bool)
## Choca de frente contra un objeto sólido.
signal choque(en: Vector2)

const ESQUIVA_TIEMPO := 0.22
const ESQUIVA_PICO := 640.0 # el esquive arranca rápido…
const ESQUIVA_FIN := 170.0 # …y se frena hasta el paso normal
const ACELERACION := 1500.0 # px/s²: a toda velocidad en una décima
const FRENADA := 2100.0
const MOVIENDOSE := 12.0 # px/s: por debajo se considera quieto
const VIDA_SILUETA := 0.22
const CHOQUE_TIEMPO := 0.35

var direccion: Vector2 = Vector2.RIGHT
var velocidad: Vector2 = Vector2.ZERO
var moviendose: bool = false
var esquiva_t: float = 0.0 # tiempo de esquive que queda
var esquiva_dir: Vector2 = Vector2.RIGHT
var siluetas: Array = [] # {pos, dir, t}: lo que deja el esquive
var silueta_t: float = 0.0
var paso_t: float = 0.0
var paso_i: int = 0
var choque_t: float = 0.0 # polvo del choque que queda
var choque_en: Vector2 = Vector2.ZERO

## ¿Se puede estar en ese punto? / ¿Ese punto toca un objeto (no un muro)?
var _bloqueado: Callable = func(_en: Vector2) -> bool: return false
var _choca: Callable = func(_en: Vector2) -> bool: return false

@onready var maquina: Node = $Maquina


func _ready() -> void:
    position = Vector2(120, 355)
    maquina.cambiar_a(&"Quieto")


## La sala dice dónde no se puede pisar.
func preparar(bloqueado: Callable, choca: Callable) -> void:
    _bloqueado = bloqueado
    _choca = choca


func estado() -> StringName:
    return maquina.nombre_actual()


## Para en seco (al entrar en una sala).
func detener() -> void:
    velocidad = Vector2.ZERO
    siluetas.clear()


func esquivar(hacia: Vector2) -> void:
    esquiva_dir = hacia
    esquiva_t = ESQUIVA_TIEMPO


## Un cuadro de juego. «eje»: controles (longitud ≤ 1); «paso»: velocidad al
## andar en px/s.
func avanzar(dt: float, eje: Vector2, paso_vel: float) -> void:
    esquiva_t = maxf(0.0, esquiva_t - dt)
    for s in siluetas:
        s["t"] = float(s["t"]) + dt
    siluetas = siluetas.filter(func(s): return float(s["t"]) < VIDA_SILUETA)
    var quiere: StringName = &"Esquiva" if esquiva_t > 0.0 else (&"Camina" if eje.length_squared() > 0.001 else &"Quieto")
    if quiere != estado():
        maquina.cambiar_a(quiere)
    maquina.estado.call("mover", self, dt, eje, paso_vel)
    moviendose = velocidad.length() > MOVIENDOSE
    if moviendose:
        _desplazar(dt, eje, paso_vel)
    else:
        paso_t = 0.06


func _desplazar(dt: float, eje: Vector2, paso_vel: float) -> void:
    var nx := Vector2(position.x + velocidad.x * dt, position.y)
    var choca_x: bool = absf(velocidad.x) > paso_vel * 0.3 and bool(_choca.call(nx))
    if not bool(_bloqueado.call(nx)):
        position.x = nx.x
    else:
        velocidad.x = 0.0
    var ny := Vector2(position.x, position.y + velocidad.y * dt)
    var choca_y: bool = absf(velocidad.y) > paso_vel * 0.3 and bool(_choca.call(ny))
    if not bool(_bloqueado.call(ny)):
        position.y = ny.y
    else:
        velocidad.y = 0.0
    if esquiva_t > 0.0:
        silueta_t -= dt
        if silueta_t <= 0.0:
            silueta_t = 0.035
            siluetas.append({"pos": position, "dir": direccion, "t": 0.0})
    if (choca_x or choca_y) and choque_t <= 0.0:
        choque_t = CHOQUE_TIEMPO
        choque_en = position + Vector2(signf(eje.x) * 10.0 if choca_x else 0.0, 2.0)
        choque.emit(choque_en)
    # Pasos: más rápidos al esquivar.
    paso_t -= dt
    if paso_t <= 0.0:
        paso_t = 0.33 if esquiva_t <= 0.0 else 0.12
        paso_i += 1
        paso.emit(position, esquiva_t > 0.0)
