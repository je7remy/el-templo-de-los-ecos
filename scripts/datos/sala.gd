extends Resource
## Una sala de un piso: datos/pisos/piso_NN/sala_N.tres. El piso las lista en
## orden (Piso.salas); la primera es la entrada y la última da a la puerta.

## Escena de la sala: rooms/sala_N.tscn (0 = sala_0.tscn).
@export var escena: int = 0
## Nombre que se muestra al entrar («I-1 · UMBRAL DEL DESPERTAR»).
@export var nombre: String = ""
## Entidad de la sala («ghoul», «testigo», «hechicero»…; vacío = ninguna).
@export var enemigo: String = ""
## Rasgos que activan elementos de la sala («altar», «archivo», «sello»…).
@export var rasgos: Array[String] = []
## Lo que se oye al entrar.
@export_multiline var susurro: String = ""
## Objetos en el suelo: [clave, nombre, posición].
@export var objetos: Array = []
## Misión (opcional): goal, required, reward y text.
@export var mision: Dictionary = {}
## Elementos opcionales de la sala, con la misma clave que lee la campaña:
## chest ([posición, nota]), traps, inscription, vines, walls, hounds, rescue,
## mask, channels, merchant, guides, gaze, seal, letter, rams, colossus,
## pillars, flames, pendulums ([centro, amplitud]), braziers, elder, elder_boss.
@export var extras: Dictionary = {}


## Formato que usa la campaña (copias, para que nadie toque el archivo).
func como_dict() -> Dictionary:
    var t := []
    t.assign(rasgos)
    var d := {"scene": escena, "name": nombre, "enemy": enemigo, "traits": t,
        "whisper": susurro, "items": objetos.duplicate(true)}
    if not mision.is_empty():
        d["mission"] = mision.duplicate(true)
    for k in extras:
        var v: Variant = extras[k]
        d[k] = v.duplicate(true) if v is Array or v is Dictionary else v
    return d
