extends Resource
## Un piso: datos/pisos/piso_NN.tres, con sus salas en datos/pisos/piso_NN/.

## Número romano que se muestra («I», «II»…).
@export var numero: String = ""
@export var titulo: String = ""
## Frase del estado del templo en este piso (bajo el título).
@export var estado: String = ""
## Desgaste de la piedra: grietas, polvo y tinte gris (0 = entera).
@export var desgaste: float = 0.0
## Eco que se gana al superarlo (clave de ECHOES en main.gd; vacío = ninguno).
@export var eco: String = ""
## Segundos que dura la antorcha por fósforo (0 = no se consume).
@export var combustible: float = 0.0
## Los compañeros te siguen de sala en sala.
@export var seguidores: bool = false
## Piso VIII: todo mira al otro lado.
@export var espejo: bool = false
## Piso VIII: el Testigo y el sello con la regla invertida.
@export var invertido: bool = false
## Último piso del arco (su puerta termina la partida).
@export var final: bool = false
## Verdad que revela al superarlo.
@export_multiline var verdad: String = ""
## Nota de diseño (no se usa en el juego).
@export_multiline var inspiracion: String = ""
## Salas en orden (scripts/datos/sala.gd): la primera es la entrada.
@export var salas: Array[Resource] = []


## Formato que usa la campaña (las claves opcionales solo si están activas).
func como_dict() -> Dictionary:
    var d := {"number": numero, "title": titulo, "state": estado, "wear": desgaste, "eco": eco}
    if combustible > 0.0:
        d["fuel"] = combustible
    if seguidores:
        d["followers"] = true
    if espejo:
        d["mirror"] = true
    if invertido:
        d["inverted"] = true
    if final:
        d["final"] = true
    d["rooms"] = salas.map(func(s): return s.como_dict())
    return d
