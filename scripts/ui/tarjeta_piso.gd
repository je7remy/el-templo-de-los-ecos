extends TextureButton
## Tarjeta de un piso en el menú de pisos. La pantalla de pisos le pasa los
## datos con configurar() y decide qué hacer al tocarla (la primera vez la
## elige; la segunda, desciende).

const Estilo := preload("res://scripts/ui/estilo.gd")

var numero: String = "I"
var nombre: String = "???"
var estado: String = ""
var color_estado: Color = Color("#5d5865")
var abierto: bool = false
var icono: Texture2D = null
var icono_tinte: Color = Color.WHITE
var candado: Texture2D = null
var seleccionada: bool = false:
    set(v):
        seleccionada = v
        queue_redraw()

var _t: float = 0.0


func _ready() -> void:
    Estilo.preparar_fuentes()
    ignore_texture_size = true
    focus_mode = Control.FOCUS_NONE # la selección la lleva la pantalla, no el foco


func configurar(d: Dictionary) -> void:
    numero = str(d.get("numero", "I"))
    nombre = str(d.get("nombre", "???"))
    estado = str(d.get("estado", ""))
    color_estado = d.get("color_estado", Color("#5d5865"))
    abierto = bool(d.get("abierto", false))
    icono = d.get("icono", null)
    icono_tinte = d.get("icono_tinte", Color.WHITE)
    candado = d.get("candado", null)
    queue_redraw()


func _process(delta: float) -> void:
    if seleccionada:
        _t += delta
        queue_redraw()


func _draw() -> void:
    var r := Rect2(Vector2.ZERO, size)
    var relleno := Color("#1c1428") if seleccionada else Color("#0f0c15")
    var borde: Color = Estilo.ORO if seleccionada else (Color("#6a4a8a") if abierto else Estilo.BORDE)
    Estilo.panel(self, r, Color(relleno.r, relleno.g, relleno.b, 0.95), borde)
    if seleccionada:
        draw_rect(r.grow(3.0), Color(Estilo.ORO.r, Estilo.ORO.g, Estilo.ORO.b, 0.25 + 0.15 * sin(_t * 4.0)), false, 2.0)
    var tono: Color = Estilo.CREMA if abierto else Color("#5d5865")
    Estilo.titulo(self, numero, Vector2(0, 52.0), 48, Estilo.ORO if abierto else Color("#4a4452"), r.size.x)
    draw_multiline_string(Estilo.fuente(), Vector2(10.0, 82.0), Estilo.t(nombre), HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 20.0, 13, 3, tono)
    Estilo.texto(self, estado, Vector2(0, r.size.y - 14.0), 10, color_estado, r.size.x)
    if icono != null:
        draw_texture_rect(icono, Rect2(r.get_center() + Vector2(-16, 26), Vector2(32, 32)), false, icono_tinte)
    if candado != null:
        draw_texture_rect(candado, Rect2(Vector2(r.size.x - 26.0, 8.0), Vector2(18, 18)), false, Color(1, 1, 1, 0.35))
