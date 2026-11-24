extends Control
## Base de todas las pantallas de interfaz (splash, menú, pausa…).
##
## Una pantalla es un estado de la máquina del gestor de pantallas
## (scripts/comun/maquina_estados.gd): se muestra con entrar(datos) y se
## oculta con salir(). No conoce a la campaña: lo que el jugador elige sale
## por la señal «accion» y el gestor se lo pasa a quien corresponda.
##
## Ocupa la pantalla base (960 × 640). Mientras está visible frena los clics
## para que no lleguen al juego de detrás.

const Estilo := preload("res://scripts/ui/estilo.gd")

## El jugador eligió algo: «jugar», «ajustes», «salir»…
signal accion(nombre: StringName)

## Datos con los que se abrió (nombre del personaje, si se juega con mando…).
var datos: Dictionary = {}


func _init() -> void:
    size = Vector2(Estilo.ANCHO, Estilo.ALTO)
    mouse_filter = Control.MOUSE_FILTER_STOP


func entrar(nuevos: Dictionary) -> void:
    datos = nuevos
    _al_entrar()
    queue_redraw()


func salir() -> void:
    _al_salir()


## Para las pantallas hijas.
func _al_entrar() -> void:
    pass


func _al_salir() -> void:
    pass


func elegir(nombre: StringName) -> void:
    accion.emit(nombre)


## Texto de ayuda según con qué se juega: teclado, toque o mando.
func ayuda(teclado: String, tactil: String, mando: String) -> String:
    match str(datos.get("entrada", "teclado")):
        "mando":
            return mando
        "tactil":
            return tactil
    return teclado
