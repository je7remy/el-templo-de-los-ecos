extends Resource
## Qué entidades salen en cada fase de la Vigilia: datos/vigilia/oleadas.tres.
## Son claves de datos/vigilia/entidades/.

## Fase 1: por turnos, en este orden.
@export var primera_fase: Array[String] = []
## Fases siguientes: se recorre la lista según la fase y la oleada.
@export var fases: Array[String] = []
## Jefe de cada quinta fase, en orden (fase 5, 10, 15…; luego vuelve a empezar).
@export var jefes: Array[String] = []
