extends Resource
## Una estructura que se construye en la celda de la Vigilia:
## datos/vigilia/estructuras/*.tres. Lo que hace cada una (disparar, dar
## energía, frenar) lo decide la Vigilia según su clave.

## Clave interna («centinela», «generador», «campana»).
@export var id: String = ""
@export var nombre: String = ""
## Nombre del icono (assets/visual/iconos).
@export var icono: String = ""
@export_multiline var descripcion: String = ""
## Ecos que cuesta la primera.
@export var coste: float = 0.0
## Cada una más cuesta esto por la anterior (1,3 = un 30 % más).
@export var factor: float = 1.0
## Ecos de la primera mejora (las siguientes suben un 55 % cada vez).
@export var coste_mejora: float = 0.0


## Formato que usa la Vigilia: [nombre, icono, descripción, coste base,
## factor por cada una más, coste de mejora base].
func como_array() -> Array:
    return [nombre, icono, descripcion, coste, factor, coste_mejora]
