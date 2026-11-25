extends RefCounted
## Catálogo de datos del juego en archivos .tres (datos/): se editan desde el
## inspector de Godot sin tocar código. Aquí se listan en orden (el orden
## importa: es el de los menús y el de cambiar de arma) y se convierten al
## formato de diccionario que usa la campaña.
##
## Para añadir un arma, una pieza, un artículo o un objeto: crea su .tres
## (duplica uno) y añádelo a su lista de abajo.

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

const TIENDA := [
    preload("res://datos/tienda/pan.tres"),
    preload("res://datos/tienda/fosforos.tres"),
    preload("res://datos/tienda/brazalete.tres"),
    preload("res://datos/tienda/amuleto.tres"),
    preload("res://datos/tienda/resonancia.tres"),
    preload("res://datos/tienda/vigilia.tres"),
]
const BOLSA := [
    preload("res://datos/bolsa/pan.tres"),
    preload("res://datos/bolsa/fosforos_caja.tres"),
    preload("res://datos/bolsa/vial.tres"),
    preload("res://datos/bolsa/incienso.tres"),
    preload("res://datos/bolsa/bolsa_almas.tres"),
    preload("res://datos/bolsa/reliquia.tres"),
]
const BOTIN := [
    preload("res://datos/botin/pan.tres"),
    preload("res://datos/botin/fosforos_caja.tres"),
    preload("res://datos/botin/vial.tres"),
    preload("res://datos/botin/incienso.tres"),
    preload("res://datos/botin/bolsa_almas.tres"),
    preload("res://datos/botin/brazalete_up.tres"),
    preload("res://datos/botin/amuleto_up.tres"),
    preload("res://datos/botin/resonancia_up.tres"),
    preload("res://datos/botin/reliquia.tres"),
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


## Puesto del Mercader, en orden: [clave, nombre, precio, descripción].
static func tienda() -> Array:
    return TIENDA.map(func(a): return a.como_array())


## Consumibles de la bolsa: clave → [nombre, descripción, icono].
static func bolsa() -> Dictionary:
    var d := {}
    for o in BOLSA:
        d[o.id] = o.como_array()
    return d


## Botín de la Vigilia: clave → [nombre, descripción, nivel, icono].
static func botin() -> Dictionary:
    var d := {}
    for o in BOTIN:
        d[o.id] = o.como_array()
    return d
