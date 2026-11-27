extends CanvasLayer
## Gestor de pantallas de interfaz.
##
## Cada pantalla (splash, menú, pausa…) es una escena propia en
## scenes/pantallas/ y un estado de la máquina «Maquina»
## (scripts/comun/maquina_estados.gd): solo una se ve a la vez.
##
## La campaña no dibuja estas pantallas: cuando cambia su modo (game_mode)
## llama a mostrar(modo, datos). Lo que elige el jugador vuelve por la señal
## «accion». Las pantallas que aún se dibujan en main.gd se irán moviendo
## aquí por fases (docs/ARQUITECTURA.md).

signal accion(pantalla: StringName, nombre: StringName, valor: Variant)

## Modo de la campaña → estado (nodo hijo de Maquina).
const MODOS := {
    "splash": &"Splash",
    "title": &"Titulo",
    "pause": &"Pausa",
    "eula": &"Acuerdo",
    "floors": &"Pisos",
    "settings": &"Ajustes",
    "dialog": &"Dialogo",
    "choice": &"Eleccion",
    "floor_intro": &"EntradaPiso",
    "floor_summary": &"ResumenPiso",
    "dead": &"Final",
    "victory": &"Final",
    "altar": &"Altar",
    "shop": &"Tienda",
    "intro": &"Intro",
    "create": &"Creacion",
    "abilities": &"Habilidades",
    "map": &"Mapa",
    "inventory": &"Perfil",
    "achievements": &"Logros",
}

@onready var maquina: Node = $Maquina


func _ready() -> void:
    for pantalla in maquina.get_children():
        if pantalla.has_signal("accion"):
            pantalla.accion.connect(_al_elegir.bind(pantalla.name))
    _mando_en_menus()


## ¿Esta pantalla la dibuja una escena del gestor?
func posee(modo: String) -> bool:
    return MODOS.has(modo)


func mostrar(modo: String, datos: Dictionary = {}) -> void:
    maquina.cambiar_a(MODOS.get(modo, &""), datos)


## Datos nuevos para la pantalla visible (si es la de ese modo).
func refrescar(modo: String, datos: Dictionary) -> void:
    var nombre: StringName = MODOS.get(modo, &"")
    if nombre != &"" and maquina.nombre_actual() == nombre:
        maquina.estado.call("refrescar", datos)


func activa() -> StringName:
    return maquina.nombre_actual()


func pantalla(nombre: StringName) -> Node:
    return maquina.get_node_or_null(NodePath(String(nombre)))


func ajustar_margen(m: Vector2) -> void:
    offset = m


func _al_elegir(nombre: StringName, valor: Variant, pantalla: StringName) -> void:
    accion.emit(pantalla, nombre, valor)


## Con mando, A acepta y B vuelve en todos los menús hechos con nodos de
## interfaz (Godot ya mueve el foco con la cruceta y el stick).
func _mando_en_menus() -> void:
    for par in [["ui_accept", JOY_BUTTON_A], ["ui_cancel", JOY_BUTTON_B]]:
        var ya := false
        for ev in InputMap.action_get_events(par[0]):
            if ev is InputEventJoypadButton and (ev as InputEventJoypadButton).button_index == par[1]:
                ya = true
        if not ya:
            var nuevo := InputEventJoypadButton.new()
            nuevo.button_index = par[1]
            InputMap.action_add_event(par[0], nuevo)
