extends Resource
## Un artículo del puesto del Mercader: datos/tienda/*.tres. Lo que hace al
## comprarlo (bolsa, equipar, mejorar) lo decide la campaña según su clave.
## Precios PROVISIONALES: ajústalos aquí.

## Clave interna ("pan", "fosforos", "brazalete"…).
@export var id: String = ""
@export var nombre: String = ""
## Precio base en almas (la campaña lo sube con el nivel en las mejoras).
@export var precio: int = 0
@export_multiline var descripcion: String = ""


## Formato que usa la campaña: [clave, nombre, precio, descripción].
func como_array() -> Array:
    return [id, nombre, precio, descripcion]
