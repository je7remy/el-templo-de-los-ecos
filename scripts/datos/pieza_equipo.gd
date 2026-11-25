extends Resource
## Una pieza de equipo como archivo de datos: datos/equipo/*.tres. Su efecto
## (menos daño, más vida, más velocidad) lo aplica la campaña según la pieza.

## Clave interna ("yelmo", "peto", "botas").
@export var id: String = ""
## Hueco donde se pone: "casco", "peto" o "botas".
@export var hueco: String = ""
@export var nombre: String = ""
@export_multiline var descripcion: String = ""


func como_dict() -> Dictionary:
    return {"slot": hueco, "name": nombre, "desc": descripcion}
