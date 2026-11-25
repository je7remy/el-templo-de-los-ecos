extends Node
## Una manada: muchas criaturas del mismo tipo (alimañas, mastines, arietes)
## comparten una máquina de estados. Cada criatura es un Dictionary con sus
## datos (los dibuja la campaña) y guarda en «clave» el nombre de su estado;
## los estados son los nodos hijos, con actuar(manada, criatura, dt, ctx).
##
## Así un piso puede tener muchas criaturas sin un nodo por cada una, y cada
## estado se lee y se ajusta por separado, como en las demás máquinas.

## Qué campo de la criatura guarda su estado.
@export var clave: String = "estado"
## Valor guardado → nombre del nodo del estado (si no coinciden).
var nombres: Dictionary = {}

## El jugador (scenes/entidades/jugador.tscn): posición, esquive e
## invulnerabilidad, leídos en el momento.
var jugador: Node2D = null
var _bloqueado: Callable = func(_en: Vector2) -> bool: return false


func preparar(el_jugador: Node2D, bloqueado: Callable) -> void:
    jugador = el_jugador
    _bloqueado = bloqueado


func bloqueado(en: Vector2) -> bool:
    return bool(_bloqueado.call(en))


func estado_de(c: Dictionary) -> String:
    var v: String = str(c.get(clave, ""))
    return str(nombres.get(v, v))


func tiene(nombre: StringName) -> bool:
    return has_node(NodePath(String(nombre)))


## Pone a la criatura en un estado (por su valor guardado).
func poner(c: Dictionary, valor: String) -> void:
    c[clave] = valor


func actuar(c: Dictionary, dt: float, ctx: Dictionary) -> void:
    var nodo: Node = get_node_or_null(NodePath(estado_de(c)))
    if nodo != null:
        nodo.call("actuar", self, c, dt, ctx)


## Mientras se mueve mira hacia donde va; quieta, mira al jugador.
func mirar(c: Dictionary, umbral: float, dt: float, hacia: Variant = null) -> void:
    var movido: Vector2 = Vector2(c["pos"]) - Vector2(c["prev"])
    c["moving"] = movido.length() > umbral * dt
    var mira: Vector2 = hacia if hacia != null else (movido if bool(c["moving"]) else (jugador.position - Vector2(c["pos"])))
    if mira.length() > 0.5:
        if absf(mira.x) > absf(mira.y):
            c["facing"] = 2 if mira.x > 0.0 else 3
        else:
            c["facing"] = 0 if mira.y > 0.0 else 1
    c["prev"] = c["pos"]
