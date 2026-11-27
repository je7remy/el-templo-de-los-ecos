extends Node
## Logros (autoload «Logros»).
##
## Son de la cuenta, no del personaje: se guardan en su propio archivo y no se
## pierden al morir, al cambiar de personaje ni al borrar el perfil. Las
## pruebas automáticas (Engine.has_meta("modo_prueba")) usan otro archivo.
##
##   Logros.conseguir("primer_paso")   # true si es nuevo
##   Logros.tiene("primer_paso")
##
## Al conseguir uno nuevo se emite Eventos.logro_conseguido(id): la capa de
## avisos muestra el rótulo dorado y suena la campana. Los textos se escriben
## en español; el inglés está en scripts/datos/en/interfaz.gd.

const RUTA := "user://templo_logros.json"
const RUTA_PRUEBA := "user://prueba_logros.json"

## [id, icono, nombre, descripción, oculto]. Los ocultos muestran «???»
## hasta conseguirlos.
const LISTA := [
    # Descenso
    ["primer_paso", "puerta", "El primer paso", "Supera el Piso I.", false],
    ["mitad", "antorcha_encendida", "Mitad del descenso", "Supera el Piso V.", false],
    ["cosecha", "reliquia", "La Cosecha", "Completa los diez pisos del primer arco.", false],
    ["insomne", "lecho", "Insomne", "Desbloquea la Vigilia.", false],
    # Muerte
    ["eco", "calavera", "Eco", "Muere por primera vez.", false],
    ["el_regreso", "eco_memoria", "El regreso", "Vuelve de la muerte con tus recuerdos.", false],
    ["otra_persona", "mascara", "Otra persona", "Que tu alma sea absorbida y despierte alguien nuevo.", false],
    ["costumbre", "bolsa_almas", "Costumbre", "Muere diez veces.", false],
    # Reglas
    ["sin_pestanear", "miedo", "Sin pestañear", "Destierra a un Testigo.", true],
    ["pira", "fosforos", "Pira", "Destierra a una Tejedora mientras arde.", true],
    ["no_apartes", "eco_serena", "No apartes la vista", "Aguanta la mirada de La Que No Aparta la Vista.", false],
    ["portico", "pinchos", "Que caiga el pórtico", "Derriba al Coloso con sus propias columnas.", false],
    ["intocable", "escudo", "Intocable", "Supera un piso sin recibir ni un golpe.", true],
    # Peregrinos
    ["guia", "incienso", "Guía de peregrinos", "Lleva a tres peregrinos contigo.", false],
    ["bendecido", "corazon", "Bendecido", "Gana la bendición de los peregrinos.", false],
    ["maldito", "eco_nuca", "Maldito", "Carga con la maldición de los peregrinos.", true],
    # Personaje
    ["bien_equipado", "peto", "Bien equipado", "Lleva casco, peto y botas a la vez.", false],
    ["veterano", "potenciar", "Veterano", "Llega al nivel 10.", false],
    ["coleccionista", "eco_fuerza", "Coleccionista de ecos", "Reúne cinco Ecos.", false],
    # Vigilia
    ["noche_larga", "campana", "La noche más larga", "Derrota a un jefe de la Vigilia.", false],
]

var _conseguidos: Dictionary = {} # id -> momento (segundos Unix)


static func ruta() -> String:
    return RUTA_PRUEBA if Engine.has_meta("modo_prueba") else RUTA


func _ready() -> void:
    cargar()


func cargar() -> void:
    _conseguidos = {}
    if FileAccess.file_exists(ruta()):
        var leido = JSON.parse_string(FileAccess.get_file_as_string(ruta()))
        if leido is Dictionary:
            for id in leido:
                if existe(str(id)):
                    _conseguidos[str(id)] = int(leido[id])


func _guardar() -> void:
    var archivo := FileAccess.open(ruta(), FileAccess.WRITE)
    if archivo == null:
        push_warning("No se pudieron guardar los logros en %s." % ruta())
        return
    archivo.store_string(JSON.stringify(_conseguidos))
    archivo.close()


func existe(id: String) -> bool:
    for l in LISTA:
        if l[0] == id:
            return true
    return false


func tiene(id: String) -> bool:
    return _conseguidos.has(id)


func cuantos() -> int:
    return _conseguidos.size()


func total() -> int:
    return LISTA.size()


## Datos de un logro: {id, icono, nombre, descripcion, oculto, tiene}.
func info(id: String) -> Dictionary:
    for l in LISTA:
        if l[0] == id:
            return {"id": l[0], "icono": l[1], "nombre": l[2], "descripcion": l[3], "oculto": l[4], "tiene": tiene(id)}
    return {}


func todos() -> Array:
    return LISTA.map(func(l): return info(str(l[0])))


## Consigue un logro. Devuelve true solo la primera vez. Con avisar = false
## no sale el rótulo (logros de partidas anteriores al cargar).
func conseguir(id: String, avisar: bool = true) -> bool:
    if not existe(id) or tiene(id):
        return false
    _conseguidos[id] = int(Time.get_unix_time_from_system())
    _guardar()
    if avisar:
        Eventos.logro_conseguido.emit(id)
    return true


## Solo para las pruebas: vuelve a empezar.
func borrar_prueba() -> void:
    if not Engine.has_meta("modo_prueba"):
        return
    _conseguidos = {}
    if FileAccess.file_exists(ruta()):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(ruta()))
