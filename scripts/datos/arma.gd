extends Resource
## Un arma (o la antorcha) como archivo de datos: datos/armas/*.tres.
## Se edita desde el inspector de Godot sin tocar código. La campaña la lee
## con el mismo formato de siempre (scripts/datos/catalogo.gd).
## Valores PROVISIONALES: ajústalos aquí.

## Clave interna ("daga", "espada"…; "" para la antorcha).
@export var id: String = ""
@export var nombre: String = ""
## Multiplicador de daño respecto a la antorcha (1,0).
@export var dano: float = 1.0
## Alcance del golpe en píxeles.
@export var alcance: float = 64.0
## Segundos entre golpes.
@export var ritmo: float = 0.6
## Vigor que gasta cada golpe.
@export var vigor: float = 10.0
## Apertura del golpe: producto escalar mínimo con la dirección (más bajo =
## barre más a los lados; negativo = casi todo alrededor).
@export var arco: float = 0.25
## Segundos que deja aturdida a la entidad.
@export var aturdir: float = 0.3
@export_multiline var descripcion: String = ""


## El formato de diccionario que usa la campaña.
func como_dict() -> Dictionary:
    var d := {"dmg": dano, "range": alcance, "cd": ritmo, "cost": vigor, "arc": arco, "stun": aturdir}
    if id != "":
        d["name"] = nombre
        d["desc"] = descripcion
    return d
