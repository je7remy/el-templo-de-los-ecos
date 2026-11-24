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

## El jugador eligió algo: «jugar», «ajustes», «salir»… «valor» lleva el
## detalle cuando hace falta (qué piso, qué pestaña…).
signal accion(nombre: StringName, valor: Variant)

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


## Datos nuevos sin volver a entrar (pantallas que cambian mientras se ven:
## el diálogo que se escribe, las almas en la tienda…). No toca la selección.
func refrescar(nuevos: Dictionary) -> void:
    datos = nuevos
    _al_refrescar()
    queue_redraw()


func _al_refrescar() -> void:
    pass


## Pinta toda la pantalla (también los márgenes de las pantallas anchas).
func oscurecer(color: Color) -> void:
    var margen: Vector2 = datos.get("margen", Vector2.ZERO)
    draw_rect(Rect2(-margen, size + margen * 2.0), color)


## Tecla de un evento (0 si no es una tecla recién pulsada).
func tecla_de(event: InputEvent) -> int:
    if event is InputEventKey and event.pressed and not event.echo:
        return int((event as InputEventKey).keycode)
    return 0


## Botón del mando recién pulsado (-1 si no lo es).
func boton_de(event: InputEvent) -> int:
    if event is InputEventJoypadButton and event.pressed:
        return (event as InputEventJoypadButton).button_index
    return -1


## Clic o toque recién empezado (posición) o null.
func clic_de(event: InputEvent) -> Variant:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        return (event as InputEventMouseButton).position
    return null


## Para las pantallas hijas.
func _al_entrar() -> void:
    pass


func _al_salir() -> void:
    pass


func elegir(nombre: StringName, valor: Variant = null) -> void:
    accion.emit(nombre, valor)


## Texto de ayuda según con qué se juega: teclado, toque o mando.
func ayuda(teclado: String, tactil: String, mando: String) -> String:
    match str(datos.get("entrada", "teclado")):
        "mando":
            return mando
        "tactil":
            return tactil
    return teclado


## Dirección de menú de un evento: flechas/WASD, cruceta o stick izquierdo
## (el stick cuenta una vez al pasar de 0,6 y se rearma al bajar de 0,35).
## Vector2i.ZERO si el evento no es una dirección.
var _stick: Vector2i = Vector2i.ZERO


func direccion(event: InputEvent) -> Vector2i:
    if event is InputEventKey and event.pressed:
        match (event as InputEventKey).keycode:
            KEY_UP, KEY_W:
                return Vector2i.UP
            KEY_DOWN, KEY_S:
                return Vector2i.DOWN
            KEY_LEFT, KEY_A:
                return Vector2i.LEFT
            KEY_RIGHT, KEY_D:
                return Vector2i.RIGHT
    elif event is InputEventJoypadButton and event.pressed:
        match (event as InputEventJoypadButton).button_index:
            JOY_BUTTON_DPAD_UP:
                return Vector2i.UP
            JOY_BUTTON_DPAD_DOWN:
                return Vector2i.DOWN
            JOY_BUTTON_DPAD_LEFT:
                return Vector2i.LEFT
            JOY_BUTTON_DPAD_RIGHT:
                return Vector2i.RIGHT
    elif event is InputEventJoypadMotion:
        var m := event as InputEventJoypadMotion
        if m.axis in [JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y]:
            var eje: int = 0 if m.axis == JOY_AXIS_LEFT_X else 1
            var v: float = m.axis_value
            var actual: int = _stick.x if eje == 0 else _stick.y
            var nuevo: int = actual
            if absf(v) < 0.35:
                nuevo = 0
            elif absf(v) > 0.6:
                nuevo = 1 if v > 0.0 else -1
            if eje == 0:
                _stick.x = nuevo
            else:
                _stick.y = nuevo
            if nuevo != 0 and nuevo != actual:
                return Vector2i(nuevo, 0) if eje == 0 else Vector2i(0, nuevo)
    return Vector2i.ZERO


func es_aceptar(event: InputEvent) -> bool:
    if event is InputEventKey and event.pressed and not event.echo:
        return (event as InputEventKey).keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_E]
    return event is InputEventJoypadButton and event.pressed and (event as InputEventJoypadButton).button_index == JOY_BUTTON_A


func es_volver(event: InputEvent) -> bool:
    if event is InputEventKey and event.pressed and not event.echo:
        return (event as InputEventKey).keycode == KEY_ESCAPE
    return event is InputEventJoypadButton and event.pressed and (event as InputEventJoypadButton).button_index == JOY_BUTTON_B
