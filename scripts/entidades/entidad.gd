extends Node2D
## La entidad de la sala (una por sala): dónde está, su vida, si te ha visto,
## si está aturdida y hacia dónde mira.
##
## Cada tipo tiene su propia máquina de estados, un nodo hijo con su nombre:
##   Ghoul      Reposo (vuelve a su sitio) · Caza (persigue la luz) · Aturdida
##   Testigo    Vigila · Caza (persigue lo que se mueve con el ojo abierto;
##              en el Piso VIII, lo que se queda quieto) · Aturdida
##   Hechicero  Reposo · Conjura (lanza un conjuro a tu luz) · Aturdida
## Los demás tipos (Segador, Tejedora…) usan los datos comunes de este nodo,
## pero su comportamiento sigue en main.gd hasta su parte de la fase 3.
##
## La campaña llama a actualizar() cada cuadro con lo que la entidad puede
## percibir del jugador; la entidad se mueve y avisa con señales. Lo que pasa
## en la partida (bolas de fuego, golpes al jugador, almas, mensajes) lo
## decide la campaña. position es la posición de los pies en la sala.

## La golpean (ya restado de su vida).
signal herida(cantidad: float)
## Se queda sin vida: la campaña la destierra y suelta sus almas.
signal desterrada
## El Hechicero lanza un conjuro desde «desde» hacia «direccion».
signal conjuro(desde: Vector2, direccion: Vector2)
## El Testigo te persigue por su regla (invertida en el Piso VIII).
signal regla(invertida: bool)

const VELOCIDAD := {"ghoul": 132.0, "testigo": 169.0}
const VUELTA_GHOUL := 48.0
const VISTA := {"ghoul": 350.0, "testigo": 490.0, "hechicero": 390.0}
const RECARGA_CONJURO := 2.9

var tipo: String = ""
var hogar: Vector2 = Vector2(788, 370)
var vida: float = 0.0
var vida_max: float = 1.0
var golpe_t: float = 0.0 # destello tras recibir un golpe
var aturdido: float = 0.0
var alerta: bool = false
var orientacion: int = 0 # 0 abajo, 1 arriba, 2 derecha, 3 izquierda
var moviendose: bool = false
var pos_anterior: Vector2 = Vector2.ZERO
var conjuro_cd: float = 2.6

var _bloqueado: Callable = func(_en: Vector2) -> bool: return false


func _ready() -> void:
    position = Vector2(788, 370)


func preparar(bloqueado: Callable) -> void:
    _bloqueado = bloqueado


## Máquina del tipo actual (null si su comportamiento aún está en main.gd).
func maquina() -> Node:
    return get_node_or_null(NodePath(tipo.capitalize()))


func estado() -> StringName:
    var m: Node = maquina()
    return m.nombre_actual() if m != null else &""


func tiene_maquina(de_tipo: String) -> bool:
    return get_node_or_null(NodePath(de_tipo.capitalize())) != null


## Intenta ir a «a»; los muros y objetos la frenan.
func ir_a(a: Vector2) -> void:
    if not bool(_bloqueado.call(a)):
        position = a


## Un cuadro. «ctx»: jugador (posición), se_mueve, antorcha, ojo_abierto e
## invertido (la regla del Testigo en el Piso VIII).
func actualizar(dt: float, ctx: Dictionary) -> void:
    var m: Node = maquina()
    if m == null:
        return
    alerta = _percibe(ctx)
    if tipo == "hechicero":
        conjuro_cd = maxf(0.0, conjuro_cd - dt)
    var quiere: StringName
    if aturdido > 0.0:
        quiere = &"Aturdida"
    elif alerta:
        quiere = &"Conjura" if tipo == "hechicero" else &"Caza"
    else:
        quiere = &"Vigila" if tipo == "testigo" else &"Reposo"
    if quiere != m.nombre_actual():
        m.cambiar_a(quiere)
    m.estado.call("actuar", self, dt, ctx)


func _percibe(ctx: Dictionary) -> bool:
    var d: float = position.distance_to(ctx["jugador"])
    match tipo:
        "ghoul", "hechicero":
            # Cazan la luz: a oscuras no te ven.
            return bool(ctx["antorcha"]) and d < float(VISTA[tipo])
        "testigo":
            # Con el ojo abierto ve lo que se mueve (o lo quieto, invertido).
            return bool(ctx["ojo_abierto"]) and (bool(ctx["se_mueve"]) != bool(ctx["invertido"])) and d < float(VISTA[tipo])
    return false


func herir(cantidad: float) -> void:
    vida -= cantidad
    golpe_t = 0.2
    herida.emit(cantidad)


func desterrar() -> void:
    desterrada.emit()


## Mientras se mueve mira hacia donde va; quieta, mira al jugador.
func seguir_mirada(dt: float, jugador: Vector2) -> void:
    var delta_pos: Vector2 = position - pos_anterior
    moviendose = dt > 0.0 and delta_pos.length() > 8.0 * dt
    var mira: Vector2 = delta_pos if moviendose else (jugador - position)
    if mira.length() > 0.5:
        if absf(mira.x) > absf(mira.y):
            orientacion = 2 if mira.x > 0.0 else 3
        else:
            orientacion = 0 if mira.y > 0.0 else 1
    pos_anterior = position
