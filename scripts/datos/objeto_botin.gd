extends Resource
## Un objeto del botín de la Vigilia: datos/botin/*.tres. Cuanto más alto su
## nivel, en fases más altas sale (scripts/botin.gd).

@export var id: String = ""
@export var nombre: String = ""
@export_multiline var descripcion: String = ""
## Nivel de botín (1-4): desde qué fase puede salir.
@export_range(1, 4) var nivel: int = 1
## Nombre del icono (assets/visual/iconos).
@export var icono: String = ""


## Formato que usa la campaña: [nombre, descripción, nivel, icono].
func como_array() -> Array:
    return [nombre, descripcion, nivel, icono]
