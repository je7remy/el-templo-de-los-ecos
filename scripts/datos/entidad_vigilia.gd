extends Resource
## Una entidad que ataca la celda de la Vigilia: datos/vigilia/entidades/*.tres.

## Clave interna («ghoul», «wizard», «angel»…).
@export var id: String = ""
## Nombre con artículo («El Ghoul»), para los avisos.
@export var nombre: String = ""
## Hoja de animación (48 × 64 por cuadro; fila 4: caminar y golpear).
@export var hoja: Texture2D
## Vida respecto a las demás (1 = normal; el Testigo aguanta un 25 % más).
@export var vida: float = 1.0
## Flota sin caminar ni golpear: usa los cuadros 0-3 todo el rato (el Testigo).
@export var flota: bool = false
