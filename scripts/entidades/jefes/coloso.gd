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
