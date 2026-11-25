extends RefCounted
## Ajustes del jugador, compartidos por la campaña (main.gd) y la Vigilia
## (defense.gd). Se guardan en user://ajustes.cfg, separados del progreso.
##
## Uso:  const Ajustes := preload("res://scripts/ajustes.gd")
##       Ajustes.cargar(); Ajustes.aplicar_audio(); Ajustes.tecla("golpe")

const RUTA := "user://ajustes.cfg"
## Las pruebas automáticas usan archivos propios para no tocar tu configuración.
const RUTA_PRUEBA := "user://prueba_ajustes.cfg"


static func ruta() -> String:
    return RUTA_PRUEBA if Engine.has_meta("modo_prueba") else RUTA

## Acciones reasignables: [nombre visible ES, nombre visible EN, tecla por defecto].
## El movimiento acepta además las flechas siempre.
const ACCIONES := {
    "arriba": ["Mover arriba", "Move up", KEY_W],
    "abajo": ["Mover abajo", "Move down", KEY_S],
    "izquierda": ["Mover izquierda", "Move left", KEY_A],
    "derecha": ["Mover derecha", "Move right", KEY_D],
    "interactuar": ["Interactuar / golpear", "Interact / strike", KEY_E],
    "antorcha": ["Antorcha", "Torch", KEY_F],
    "esquivar": ["Esquivar", "Dodge", KEY_SPACE],
    "resonancia": ["Resonancia", "Resonance", KEY_Q],
    "perfil": ["Perfil", "Profile", KEY_I],
    "habilidades": ["Habilidades", "Abilities", KEY_K],
    "pausa": ["Pausa", "Pause", KEY_ESCAPE],
}
const ORDEN := ["arriba", "abajo", "izquierda", "derecha", "interactuar", "antorcha", "esquivar", "resonancia", "perfil", "habilidades", "pausa"]

static var datos: Dictionary = {}
static var cargado: bool = false


static func valores_por_defecto() -> Dictionary:
    var teclas := {}
    for accion in ACCIONES:
        teclas[accion] = int(ACCIONES[accion][2])
    return {
        "volumen_general": 0.9, "volumen_musica": 0.8, "volumen_efectos": 0.9, "silencio": false,
        "pantalla_completa": true, # en PC el juego arranca a pantalla completa
        "pantalla_v2": true,
        "buscar_actualizaciones": true, # mira en GitHub si hay versión nueva al abrir
        "teclas": teclas, "tactil": "auto", # auto, siempre, nunca
        "zoom_movil": "cerca", # en el móvil: cerca, medio o lejos (toda la sala)
        "idioma": "es",
        "acuerdo_aceptado": false, "acuerdo_version": 0,
        "intro_vista": false, "tutorial_hecho": false,
    }


static func cargar() -> void:
    datos = valores_por_defecto()
    cargado = true
    var cfg := ConfigFile.new()
    if cfg.load(ruta()) != OK:
        return
    for clave in datos:
        if clave == "teclas":
            continue
        datos[clave] = cfg.get_value("ajustes", clave, datos[clave])
    for accion in ACCIONES:
        datos["teclas"][accion] = int(cfg.get_value("teclas", accion, datos["teclas"][accion]))
    # Ajustes guardados antes de la v0.5.6 (ventana por defecto): pasan una vez
    # a pantalla completa; luego se respeta lo que elija el jugador.
    if not cfg.has_section_key("ajustes", "pantalla_v2"):
        datos["pantalla_completa"] = true
        datos["pantalla_v2"] = true


static func guardar() -> void:
    var cfg := ConfigFile.new()
    for clave in datos:
        if clave != "teclas":
            cfg.set_value("ajustes", clave, datos[clave])
    for accion in datos["teclas"]:
        cfg.set_value("teclas", accion, datos["teclas"][accion])
    cfg.save(ruta())


static func obtener(clave: String, defecto = null):
    if not cargado:
        cargar()
    return datos.get(clave, defecto)


static func poner(clave: String, valor) -> void:
    if not cargado:
        cargar()
    datos[clave] = valor
    guardar()


static func tecla(accion: String) -> int:
    if not cargado:
        cargar()
    return int(datos["teclas"].get(accion, ACCIONES[accion][2]))


static func asignar_tecla(accion: String, codigo: int) -> void:
    if not cargado:
        cargar()
    # Si otra acción ya usaba esa tecla, se intercambian para no dejar huecos.
    for otra in datos["teclas"]:
        if otra != accion and int(datos["teclas"][otra]) == codigo:
            datos["teclas"][otra] = int(datos["teclas"][accion])
    datos["teclas"][accion] = codigo
    guardar()


static func restablecer_teclas() -> void:
    datos["teclas"] = valores_por_defecto()["teclas"]
    guardar()


static func nombre_tecla(accion: String) -> String:
    var codigo: int = tecla(accion)
    match codigo:
        KEY_SPACE:
            return "ESPACIO" if obtener("idioma") == "es" else "SPACE"
        KEY_ESCAPE:
            return "ESC"
    return OS.get_keycode_string(codigo).to_upper()


## Buses de audio: Música y Efectos cuelgan del general.
static func preparar_buses() -> void:
    for nombre in ["Musica", "Efectos"]:
        if AudioServer.get_bus_index(nombre) == -1:
            AudioServer.add_bus()
            var i: int = AudioServer.bus_count - 1
            AudioServer.set_bus_name(i, nombre)
            AudioServer.set_bus_send(i, "Master")
    aplicar_audio()


static func aplicar_audio() -> void:
    var general: int = AudioServer.get_bus_index("Master")
    AudioServer.set_bus_volume_db(general, linear_to_db(maxf(float(obtener("volumen_general")), 0.0001)))
    AudioServer.set_bus_mute(general, bool(obtener("silencio")))
    for par in [["Musica", "volumen_musica"], ["Efectos", "volumen_efectos"]]:
        var i: int = AudioServer.get_bus_index(par[0])
        if i != -1:
            AudioServer.set_bus_volume_db(i, linear_to_db(maxf(float(obtener(par[1])), 0.0001)))


## Borra progreso y ajustes del equipo (pestaña Privacidad).
static func borrar_todo(ruta_progreso: String) -> void:
    for ruta in [ruta_progreso, ruta()]:
        if FileAccess.file_exists(ruta):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(ruta))
    cargar()
