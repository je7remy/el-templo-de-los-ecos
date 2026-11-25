extends Resource
## Un consumible de la bolsa (se usa desde el perfil): datos/bolsa/*.tres. Su
## efecto lo aplica la campaña según su clave.

@export var id: String = ""
@export var nombre: String = ""
@export_multiline var descripcion: String = ""
## Nombre del icono (assets/visual/iconos).
@export var icono: String = ""


## Formato que usa la campaña: [nombre, descripción, icono].
func como_array() -> Array:
    return [nombre, descripcion, icono]
