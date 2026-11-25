extends RefCounted
## Catálogo de datos de la Vigilia del Claustro en archivos .tres
## (datos/vigilia/): estructuras, entidades, qué sale en cada fase y los pasos
## del tutorial. Se editan desde el inspector de Godot sin tocar código. Aquí
## se listan en orden (el orden importa: es el de los menús y el del tutorial)
## y se convierten al formato que usa scripts/defense.gd.
##
## Para añadir algo: crea su .tres (duplica uno) y añádelo a su lista. Una
## estructura o una entidad nueva necesitan además su comportamiento en
## defense.gd; un paso de tutorial nuevo, su condición en _tut_done.

const ESTRUCTURAS := [
    preload("res://datos/vigilia/estructuras/centinela.tres"),
    preload("res://datos/vigilia/estructuras/generador.tres"),
    preload("res://datos/vigilia/estructuras/campana.tres"),
]
const ENTIDADES := [
    preload("res://datos/vigilia/entidades/ghoul.tres"),
    preload("res://datos/vigilia/entidades/wizard.tres"),
    preload("res://datos/vigilia/entidades/angel.tres"),
    preload("res://datos/vigilia/entidades/mastin.tres"),
    preload("res://datos/vigilia/entidades/segador.tres"),
    preload("res://datos/vigilia/entidades/tejedora.tres"),
    preload("res://datos/vigilia/entidades/ariete.tres"),
]
const OLEADAS := preload("res://datos/vigilia/oleadas.tres")
const TUTORIAL := [
    preload("res://datos/vigilia/tutorial/paso_01.tres"),
    preload("res://datos/vigilia/tutorial/paso_02.tres"),
    preload("res://datos/vigilia/tutorial/paso_03.tres"),
    preload("res://datos/vigilia/tutorial/paso_04.tres"),
    preload("res://datos/vigilia/tutorial/paso_05.tres"),
    preload("res://datos/vigilia/tutorial/paso_06.tres"),
    preload("res://datos/vigilia/tutorial/paso_07.tres"),
    preload("res://datos/vigilia/tutorial/paso_08.tres"),
    preload("res://datos/vigilia/tutorial/paso_09.tres"),
    preload("res://datos/vigilia/tutorial/paso_10.tres"),
    preload("res://datos/vigilia/tutorial/paso_11.tres"),
    preload("res://datos/vigilia/tutorial/paso_12.tres"),
    preload("res://datos/vigilia/tutorial/paso_13.tres"),
    preload("res://datos/vigilia/tutorial/paso_14.tres"),
    preload("res://datos/vigilia/tutorial/paso_15.tres"),
]


## Estructuras: clave → [nombre, icono, descripción, coste base, factor por
## cada una más, coste de mejora base].
static func estructuras() -> Dictionary:
    var d := {}
    for e in ESTRUCTURAS:
        d[e.id] = e.como_array()
    return d


## Entidades por clave (recurso entero: nombre, hoja, vida, flota).
static func entidades() -> Dictionary:
    var d := {}
    for e in ENTIDADES:
        d[e.id] = e
    return d


## Hojas de animación: clave → textura.
static func hojas() -> Dictionary:
    var d := {}
    for e in ENTIDADES:
        d[e.id] = e.hoja
    return d


## Entidades de la fase 1, de las siguientes y jefes (listas de claves).
static func primera_fase() -> Array:
    return _lista(OLEADAS.primera_fase)


static func fases() -> Array:
    return _lista(OLEADAS.fases)


static func jefes() -> Array:
    return _lista(OLEADAS.jefes)


static func _lista(a: Array) -> Array:
    var l := []
    l.assign(a)
    return l


## Pasos del tutorial, en orden: [título, texto].
static func tutorial() -> Array:
    return TUTORIAL.map(func(p): return [p.titulo, p.texto])
