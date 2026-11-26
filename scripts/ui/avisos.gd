extends Control
## Capa de avisos: el mensaje breve bajo el marcador, el rótulo de subida de
## nivel y el del objeto conseguido. Vive en su propia CanvasLayer por encima
## de las pantallas, así se ve aunque esté abierta la pausa o un menú.
##
## La campaña le pasa cada cuadro dónde está el personaje en pantalla
## («ancla») para colocar los rótulos a su lado sin salirse de la pantalla.
## Cualquier nodo puede pedir un mensaje con Eventos.aviso_pedido.emit(texto, s).

const Estilo := preload("res://scripts/ui/estilo.gd")
const Botin := preload("res://scripts/botin.gd")

const ICONOS_DIR := "res://assets/visual/iconos/%s.png"
const NIVEL_DURA := 3.4

## Posición del personaje en pantalla (coordenadas de la pantalla base).
var ancla: Vector2 = Vector2(480, 351)
var zoom: float = 1.0
## Margen de las pantallas anchas (lo que sobra a cada lado).
var margen: Vector2 = Vector2.ZERO
## Solo se descuenta el rótulo del objeto mientras se juega (si lees una
## nota o un diálogo, espera).
var en_juego: bool = false
## En el menú, la creación o la intro no se muestran los rótulos.
var ocultar_rotulos: bool = false
var tactil: bool = false

## Mensaje breve.
var texto: String = ""
var texto_t: float = 0.0
## Subida de nivel.
var nivel: int = 1
var nivel_detalle: String = ""
var nivel_t: float = 0.0
## Objeto conseguido: {key, t, info?, header?}.
var botin: Dictionary = {}

var _siguiente_y: float = -1.0
var _iconos: Dictionary = {}


func _ready() -> void:
    Estilo.preparar_fuentes()
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    size = Vector2(Estilo.ANCHO, Estilo.ALTO)
    Eventos.aviso_pedido.connect(decir)


func _exit_tree() -> void:
    if Eventos.aviso_pedido.is_connected(decir):
        Eventos.aviso_pedido.disconnect(decir)


func decir(mensaje: String, segundos: float = 2.8) -> void:
    texto = mensaje
    texto_t = segundos
    queue_redraw()


func callar() -> void:
    texto_t = 0.0
    queue_redraw()


func mostrar_nivel(n: int, detalle: String) -> void:
    nivel = n
    nivel_detalle = detalle
    nivel_t = NIVEL_DURA


func _process(delta: float) -> void:
    texto_t = maxf(0.0, texto_t - delta)
    nivel_t = maxf(0.0, nivel_t - delta)
    if not botin.is_empty():
        if en_juego:
            botin["t"] = float(botin.get("t", 0.0)) - delta
        if float(botin.get("t", 0.0)) <= 0.0:
            botin = {}
    queue_redraw()


func _draw() -> void:
    if texto_t > 0.0:
        _dibujar_mensaje()
    if ocultar_rotulos:
        return
    _siguiente_y = -1.0
    if nivel_t > 0.0:
        _dibujar_nivel()
    if not botin.is_empty():
        _dibujar_botin()


func _dibujar_mensaje() -> void:
    var a: float = clampf(texto_t * 3.0, 0.0, 1.0)
    var tam: int = 16 if tactil else 14
    var msg: String = Estilo.t(texto)
    var ancho: float = minf(Estilo.fuente().get_string_size(msg, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x + 40.0, Estilo.ANCHO - 40.0)
    var caja := Rect2(roundf((Estilo.ANCHO - ancho) * 0.5), 110.0, ancho, 28.0)
    Estilo.panel(self, caja, Color(0.035, 0.045, 0.06, 0.94 * a), Color(Estilo.ORO.r, Estilo.ORO.g, Estilo.ORO.b, 0.8 * a))
    Estilo.texto(self, msg, Vector2(caja.position.x, caja.position.y + 19.0), tam, Color(Estilo.CREMA.r, Estilo.CREMA.g, Estilo.CREMA.b, a), caja.size.x)


## Dónde poner un rótulo de tamaño «tam»: sobre el personaje (o debajo si no
## cabe arriba), siempre dentro de la pantalla; el segundo, bajo el primero.
func rect_rotulo(tam: Vector2) -> Rect2:
    var x: float = clampf(ancla.x - tam.x * 0.5, -margen.x + 8.0, Estilo.ANCHO + margen.x - tam.x - 8.0)
    var y: float
    if _siguiente_y >= 0.0:
        y = _siguiente_y
    else:
        y = ancla.y - 86.0 * zoom - tam.y
        if y < 118.0:
            y = ancla.y + 22.0 * zoom
        y = clampf(y, 118.0, Estilo.ALTO + margen.y - 70.0 - tam.y * 2.0 - 8.0)
    _siguiente_y = y + tam.y + 6.0
    return Rect2(Vector2(x, y).round(), tam)


func _dibujar_nivel() -> void:
    var a: float = clampf(nivel_t * 2.0, 0.0, 1.0) * clampf((NIVEL_DURA - nivel_t) * 4.0, 0.0, 1.0)
    var caja := rect_rotulo(Vector2(420, 74))
    Estilo.panel(self, caja, Color(0.1, 0.06, 0.12, 0.94 * a), Color(Estilo.ORO.r, Estilo.ORO.g, Estilo.ORO.b, a))
    Estilo.titulo(self, "Nivel %d" % nivel, Vector2(caja.position.x, caja.position.y + 38.0), 36, Color(1.0, 0.9, 0.6, a), caja.size.x)
    Estilo.texto(self, nivel_detalle, Vector2(caja.position.x, caja.position.y + 62.0), 13, Color(Estilo.CREMA.r, Estilo.CREMA.g, Estilo.CREMA.b, a), caja.size.x)


func _icono(nombre: String) -> Texture2D:
    if not _iconos.has(nombre):
        var ruta := ICONOS_DIR % nombre
        _iconos[nombre] = load(ruta) if ResourceLoader.exists(ruta) else null
    return _iconos[nombre]


func _dibujar_botin() -> void:
    var clave: String = str(botin.get("key", ""))
    var info: Array = botin.get("info", Botin.OBJETOS.get(clave, [clave, "", 1, "alma"]))
    var a: float = clampf(float(botin.get("t", 0.0)), 0.0, 1.0)
    var caja := rect_rotulo(Vector2(360, 74))
    var rango: int = clampi(int(info[2]), 1, 4)
    var col: Color = [Color("#9a957f"), Estilo.ALMA, Color("#a988d0"), Color("#e3bd7b")][rango - 1]
    Estilo.panel(self, caja, Color(0.04, 0.035, 0.05, 0.94 * a), Color(col.r, col.g, col.b, a))
    var icono: Texture2D = _icono(str(info[3]))
    if icono != null:
        draw_texture_rect(icono, Rect2(caja.position + Vector2(12, 13), Vector2(48, 48)), false, Color(1, 1, 1, a))
    Estilo.texto(self, str(botin.get("header", "OBJETO ENCONTRADO")) + " · " + ["COMÚN", "POCO COMÚN", "RARO", "ÉPICO"][rango - 1], Vector2(caja.position.x + 70.0, caja.position.y + 22.0), 11, Color(col.r, col.g, col.b, a))
    Estilo.texto(self, str(info[0]), Vector2(caja.position.x + 70.0, caja.position.y + 44.0), 17, Color(Estilo.CREMA.r, Estilo.CREMA.g, Estilo.CREMA.b, a))
    Estilo.texto(self, "Ya está en tu perfil.", Vector2(caja.position.x + 70.0, caja.position.y + 62.0), 10, Color(0.62, 0.6, 0.55, a))
