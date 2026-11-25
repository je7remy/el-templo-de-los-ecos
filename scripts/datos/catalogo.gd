extends RefCounted
## Catálogo de datos del juego en archivos .tres (datos/): se editan desde el
## inspector de Godot sin tocar código. Aquí se listan en orden (el orden
## importa: es el de los menús y el de cambiar de arma) y se convierten al
## formato de diccionario que usa la campaña.
##
## Para añadir un arma o una pieza: crea su .tres (duplica uno) y añádelo a
## la lista de abajo.

const ARMAS := [
    preload("res://datos/armas/daga.tres"),
    preload("res://datos/armas/espada.tres"),
    preload("res://datos/armas/lanza.tres"),
    preload("res://datos/armas/hacha.tres"),
    preload("res://datos/armas/maza.tres"),
]
const ANTORCHA := preload("res://datos/armas/antorcha.tres")
const EQUIPO := [
    preload("res://datos/equipo/yelmo.tres"),
    preload("res://datos/equipo/peto.tres"),
    preload("res://datos/equipo/botas.tres"),
]


static func armas() -> Dictionary:
    var d := {}
    for a in ARMAS:
        d[a.id] = a.como_dict()
    return d


static func antorcha() -> Dictionary:
    return ANTORCHA.como_dict()


static func equipo() -> Dictionary:
    var d := {}
    for p in EQUIPO:
        d[p.id] = p.como_dict()
    return d
