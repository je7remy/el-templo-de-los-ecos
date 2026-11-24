extends Control
## Pantalla de carga: fondo negro, el emblema y una barra con el progreso
## real de la carga (la maneja el autoload Escenas).

const Estilo := preload("res://scripts/ui/estilo.gd")
## El emblema se carga al usarse (no con preload): este script es parte de
## un autoload y se analiza al importar el proyecto, antes de que el SVG esté
## importado en una copia recién clonada.
const RUTA_MARCA := "res://assets/branding/icon.svg"
var _marca: Texture2D

var progreso: float = 0.0
var _visto: float = 0.0 # barra suavizada
var _t: float = 0.0


func _ready() -> void:
    Estilo.preparar_fuentes()
    mouse_filter = Control.MOUSE_FILTER_STOP
    set_anchors_preset(Control.PRESET_FULL_RECT)
    if ResourceLoader.exists(RUTA_MARCA):
        _marca = load(RUTA_MARCA)


func empezar() -> void:
    progreso = 0.0
    _visto = 0.0
    modulate.a = 0.0
    visible = true


func poner_opacidad(a: float) -> void:
    modulate.a = a


func poner_progreso(p: float) -> void:
    progreso = clampf(p, 0.0, 1.0)


## Mientras carga, nada pasa a la escena de detrás.
func _gui_input(event: InputEvent) -> void:
    accept_event()


func _process(delta: float) -> void:
    if not visible:
        return
    _t += delta
    _visto = move_toward(_visto, progreso, delta * 2.5)
    queue_redraw()


func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, size), Color(0.01, 0.012, 0.02))
    var c: Vector2 = size * 0.5
    var brillo: float = 0.5 + 0.5 * sin(_t * 2.0)
    for k in range(6):
        draw_circle(c + Vector2(0, -40), (30.0 + float(k) * 12.0) * (1.0 + brillo * 0.05), Color(0.45, 0.75, 0.85, 0.014))
    if _marca != null:
        draw_texture_rect(_marca, Rect2(c + Vector2(-36, -76), Vector2(72, 72)), false)
    Estilo.texto(self, "CARGANDO…", Vector2(0, c.y + 28.0), 16, Estilo.CREMA, size.x)
    var barra := Rect2(c.x - 140.0, c.y + 44.0, 280.0, 10.0)
    Estilo.panel(self, barra.grow(3.0), Color(0.03, 0.035, 0.05, 1.0), Estilo.CLARO)
    draw_rect(Rect2(barra.position, Vector2(barra.size.x * _visto, barra.size.y)), Estilo.ALMA)
