extends Node2D
## Base de los jefes (Coloso, Hermano Mayor…): una escena con su máquina de
## estados («Maquina»). El estado se guarda con el mismo nombre corto que usan
## los dibujos y las reglas de la campaña ("walk", "stomp"…); «nombres»
## traduce ese valor al nodo del estado.
##
## Los estados mueven al jefe y avisan con señales; la campaña decide el daño,
## los sonidos, los efectos y lo que pasa en la partida. position es dónde
## está el jefe en la sala.

## El jefe te alcanza: la campaña aplica el golpe (cantidad, miedo y
## segundos de invulnerabilidad; -1 = no cambiarla).
signal hiere(cantidad: float, miedo: float, invulnerable: float)

## Valor guardado → nombre del nodo del estado.
var nombres: Dictionary = {}
var jugador: Node2D = null
var _bloqueado: Callable = func(_en: Vector2) -> bool: return false

@onready var maquina: Node = $Maquina


func preparar(el_jugador: Node2D, bloqueado: Callable) -> void:
    jugador = el_jugador
    _bloqueado = bloqueado


func bloqueado(en: Vector2) -> bool:
    return bool(_bloqueado.call(en))


## ¿Puede recibir un golpe el jugador ahora? (ni esquivando ni invulnerable)
func jugador_expuesto() -> bool:
    return float(jugador.esquiva_t) <= 0.0 and float(jugador.invulnerable_t) <= 0.0


## Valor del estado actual ("walk", "stun"…).
func estado() -> String:
    var nodo: StringName = maquina.nombre_actual()
    for v in nombres:
        if StringName(nombres[v]) == nodo:
            return v
    return ""


func poner(valor: String) -> void:
    maquina.cambiar_a(StringName(nombres.get(valor, valor)))


func actuar(dt: float, ctx: Dictionary) -> void:
    if maquina.estado != null:
        maquina.estado.call("actuar", self, dt, ctx)
